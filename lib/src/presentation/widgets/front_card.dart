import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:kompot/nfc.dart';

import 'package:kompot/utils.dart';
import 'package:kompot/routes.dart';
import 'package:kompot/lc_manager.dart';

import 'package:kompot/pages/home_page.dart';
import 'package:kompot/pages/components/delete_popup.dart';

class FrontCard extends StatefulWidget {
  const FrontCard({
    Key? key,
    required this.cardData,
    required this.stampCount,
    required this.rotations,
    required this.offsets,
    required this.flipCard,
  }) : super(key: key);

  final Map<String, dynamic> cardData;
  final int stampCount;
  final List<double> rotations;
  final List<Offset> offsets;
  final Function flipCard;

  @override
  State<FrontCard> createState() => _FrontCardState();
}

class _FrontCardState extends State<FrontCard> with TickerProviderStateMixin {
  late AnimationController _animationController;

  bool _showDeletePopup = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void onClickDelete(bool hasDeleted) {
    _toggleDeletePopup();

    if (hasDeleted) {
      removeCard(widget.cardData['titleInfo']);

      navigateWithMPR(
        const HomePage(),
        HomePage.routeName,
      );

      clearCache();
    }
  }

  void _toggleDeletePopup() {
    setState(() {
      _showDeletePopup = !_showDeletePopup;
      if (_showDeletePopup) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final int circleCount =
        int.tryParse(widget.cardData['circleNumber'] ?? '') ?? 0;

    final int stampsOnLine = [1, 2, 3, 2, 3][(circleCount - 1).clamp(0, 4)];

    final double circleSpacing = 14.0 - screenHeight * 0.005;
    final double circleSize =
        (280 - (stampsOnLine - 1) * circleSpacing) / stampsOnLine;

    final double marginAfterLogo = mapRange(screenHeight, 600, 900, 0, 35);

    final double radius = screenHeight * 0.068;
    const double borderWidth = 0.7;

    final String description =
        widget.cardData['text'].toString().replaceAll('\\n', '\n');

    final double padding =
        [0, 50, 15, 40, 15][(circleCount - 1).clamp(0, 4)].toDouble();

    final double marginTop =
        [0, 100, 100, 50, 50, 30][(circleCount - 1).clamp(0, 5)].toDouble();

    return SwipeDetector(
      onSwipeLeft: (offset) {
        widget.flipCard(false);
      },
      onSwipeRight: (offset) {
        widget.flipCard(true);
      },
      child: Container(
        width: screenHeight * 0.4,
        height: screenHeight * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (Platform.isIOS)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              NFCReader nfcReader = NFCReader();

                              nfcReader.initState();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Colors.white.withOpacity(0),
                              padding: const EdgeInsets.all(0),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 34,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    Container(),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            _toggleDeletePopup();
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.white.withOpacity(0),
                            padding: const EdgeInsets.all(0),
                          ),
                          child: const SizedBox(
                            width: 34,
                            child: Image(
                              image: AssetImage('assets/icons/trash.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 0.75,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: radius,
                    backgroundImage: NetworkImage(
                      widget.cardData['logo'],
                    ),
                  ),
                ),
                SizedBox(height: marginAfterLogo),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: parseColor(widget.cardData['textColor']),
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: marginTop),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Center(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: stampsOnLine,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: circleCount,
                        itemBuilder: (context, index) {
                          if (index < widget.stampCount) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: circleSize,
                                  height: circleSize,
                                  margin: EdgeInsets.all(circleSpacing),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: borderWidth,
                                    ),
                                    color: Colors.transparent,
                                  ),
                                ),
                                SizedBox(
                                  width: circleSize,
                                  height: circleSize,
                                  child: Transform.rotate(
                                    angle: widget.rotations[index],
                                    child: Transform.translate(
                                      offset: widget.offsets[index] * 1.5,
                                      child: Image.network(
                                        widget.cardData['stamp'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: circleSize,
                                  height: circleSize,
                                  margin: EdgeInsets.all(circleSpacing),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: borderWidth,
                                    ),
                                    color: Colors.transparent,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animationController.value,
                  child: Center(
                    child: child,
                  ),
                );
              },
              child: Visibility(
                visible: _showDeletePopup,
                child: DeletePopup(
                  onClickDelete: onClickDelete,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
