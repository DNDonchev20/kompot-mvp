import 'package:flutter/material.dart';
import 'package:kompot/pages/components/background.dart';
import 'package:kompot/pages/components/review_card.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

import 'package:kompot/nfc.dart';
import 'package:kompot/routes.dart';
import 'package:kompot/nfc_data.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/stamp_manager.dart';

import 'package:kompot/pages/components/front_card.dart';
import 'package:kompot/pages/components/back_card.dart';
import 'package:kompot/pages/components/header.dart';

class CardPage extends StatefulWidget {
  const CardPage({
    Key? key,
    required this.cardData,
    required this.rotations,
    required this.offsets,
  }) : super(key: key);

  static const routeName = '/card_page';

  final Map<String, dynamic> cardData;
  final List<double> rotations;
  final List<Offset> offsets;

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> frontAnimation;
  late Animation<double> backAnimation;
  bool isTurnedRight = true;
  bool isTurned = true;
  bool isFlipping = false;
  bool shouldUpdateStampCount = true;
  int stampCount = -1;
  bool storedAnimation = storage.getItem('animation') ?? false;

  @override
  void initState() {
    super.initState();
    shouldUpdateStampCount = true;
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    frontAnimation = Tween(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.5),
      ),
    );
    backAnimation = Tween(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0),
      ),
    );
    _initAnimations();
  }

  void _initAnimations() {
    if (storedAnimation) {
      Future.delayed(const Duration(seconds: 1), () {
        animationController.forward().whenComplete(() {
          Future.delayed(const Duration(milliseconds: 500), () {
            animationController.reverse();
          });
        });
      });
      storage.setItem('animation', false);
      storedAnimation = storage.getItem('animation');
    }
  }

  Future<void> getCardStampCount() async {
    if (!shouldUpdateStampCount) {
      return;
    }
    stampCount = await getStampCount(widget.cardData['titleInfo']);
    shouldUpdateStampCount = false;
  }

  void flipCard(bool turnedRight) {
    if (!isFlipping && !storedAnimation) {
      isTurnedRight = turnedRight;
      isFlipping = true;
      if (animationController.isAnimating) {
        animationController.stop(canceled: false);
      } else {
        if (isTurned) {
          animationController.forward().whenComplete(() {
            isFlipping = false;
          });
        } else {
          animationController.reverse().whenComplete(() {
            isFlipping = false;
          });
        }
      }
      setState(() {
        isTurned = !isTurned;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NFCReader>(
      builder: (context, nfcreader, child) {
        if (nfcreader.shouldUpdateCard) {
          shouldUpdateStampCount = true;
          nfcreader.cardIsUpdated = true;
          if (nfcreader.homeIsUpdated) {
            nfcreader.shouldUpdateCard = false;
            nfcreader.cardIsUpdated = false;
            nfcreader.homeIsUpdated = false;
          }
        }

        return FutureBuilder<void>(
          future: getCardStampCount(),
          builder: (context, snapshot) {
            if (stampCount == -1) {
              return _buildLoadingScreen();
            }
            return _buildCardPage();
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: const IntrinsicHeight(
                    child: Center(
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardPage() {
    return Scaffold(
      body: SafeArea(
        child: Background(
          child: Column(
            children: [
              const Header(),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! > 0) {
                        navigatePop();
                      }
                    },
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!showReview) _buildFrontCard(),
                          if (!showReview) _buildBackCard(),
                          if (showReview) ReviewCard(cardData: widget.cardData),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return AnimatedBuilder(
      animation: frontAnimation,
      builder: (context, child) {
        double frontRotation = frontAnimation.value * math.pi;
        if (isTurnedRight) {
          frontRotation *= -1;
        }
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(frontRotation),
          child: FrontCard(
            cardData: widget.cardData,
            stampCount: stampCount,
            rotations: widget.rotations,
            offsets: widget.offsets,
            flipCard: flipCard,
          ),
        );
      },
    );
  }

  Widget _buildBackCard() {
    return AnimatedBuilder(
      animation: backAnimation,
      builder: (context, child) {
        double backRotation = (backAnimation.value - 0.5) * math.pi;
        if (isTurnedRight) {
          backRotation *= -1;
        }
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(backRotation),
          child: BackCard(
            cardData: widget.cardData,
            flipCard: flipCard,
          ),
        );
      },
    );
  }
}
