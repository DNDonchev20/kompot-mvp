import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:infinite_carousel/infinite_carousel.dart';

import 'package:kompot/utils.dart';
import 'package:kompot/routes.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/card_manager.dart';

import 'package:kompot/pages/home_page.dart';

import 'package:kompot/pages/components/header.dart';
import 'package:kompot/pages/components/menu_item.dart';
import 'package:kompot/pages/components/background.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({
    Key? key,
    required this.title,
    required this.cards,
  }) : super(key: key);

  static const routeName = '/category_page';

  final String title;
  final List<dynamic> cards;

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late InfiniteScrollController controller;
  double itemExtent = 100;
  double get screenWidth => MediaQuery.of(context).size.width;

  int currentIndex = 0;
  String selectedTitleInfo = '';

  bool canSaveCard = true;

  @override
  void initState() {
    super.initState();

    canSaveCard = true;

    removeChosenCards();

    currentIndex = [0, 0, 1, 2][(widget.cards.length - 1).clamp(0, 3)];
    controller = InfiniteScrollController(initialItem: currentIndex);
  }

  void removeChosenCards() {
    dynamic chosenCards = getCardsList();

    widget.cards.removeWhere((value) {
      return chosenCards.contains(value['titleInfo']);
    });
  }

  void chooseCard() async {
    canSaveCard = false;

    await saveCard(selectedTitleInfo);

    // ignore: use_build_context_synchronously
    navigateWithMPR(
      const HomePage(),
      HomePage.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    void onCarouselIndexChanged(int newIndex) {
      setState(() {
        currentIndex = newIndex;
      });
    }

    double calculateOpacity(int itemIndex) {
      const double activeOpacity = 1.0;
      const double topAndBottomOpacity = 0.7;
      const double otherOpacity = 0.5;

      if (itemIndex == currentIndex) {
        return activeOpacity;
      }

      if (itemIndex == currentIndex - 1 || itemIndex == currentIndex + 1) {
        return topAndBottomOpacity;
      }

      return otherOpacity;
    }

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
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Header(),
                        const SizedBox(height: 30),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: SizedBox(
                            height: 450,
                            width: screenWidth - 20,
                            child: InfiniteCarousel.builder(
                              itemCount: widget.cards.length,
                              itemExtent: itemExtent,
                              axisDirection: Axis.vertical,
                              center: true,
                              velocityFactor: 0.75,
                              scrollBehavior: kIsWeb
                                  ? ScrollConfiguration.of(context).copyWith(
                                      dragDevices: {
                                        PointerDeviceKind.touch,
                                        PointerDeviceKind.mouse,
                                      },
                                    )
                                  : null,
                              loop: false,
                              controller: controller,
                              onIndexChanged: onCarouselIndexChanged,
                              itemBuilder: (context, itemIndex, realIndex) {
                                final currentOffset = itemExtent * realIndex;
                                final Map<dynamic, dynamic> data =
                                    widget.cards.elementAt(realIndex);

                                final String titleInfo =
                                    data['titleInfo'] ?? 'No Title';
                                final String descriptionInfo =
                                    data['descriptionInfo'] ?? 'No Description';
                                final String imageUrl =
                                    data['logo'] as String? ?? '';
                                final Color textColor =
                                    data['textColor'] != null
                                        ? parseColor(data['textColor']!)
                                        : Colors.black;
                                final Color backgroundColor =
                                    data['backgroundColor'] != null
                                        ? parseColor(data['backgroundColor']!)
                                        : Colors.white;

                                final double opacity =
                                    calculateOpacity(itemIndex);

                                return Opacity(
                                  opacity: opacity,
                                  child: AnimatedBuilder(
                                    animation: controller,
                                    builder: (context, child) {
                                      final diff =
                                          (controller.offset - currentOffset);
                                      const maxPadding = 15.0;
                                      final carouselRatio =
                                          itemExtent / maxPadding;

                                      double ratio =
                                          (diff / carouselRatio).abs();
                                      const double verticalPadding = 7.5;
                                      final double horizontalPadding =
                                          ratio.clamp(0, 10) * 1.5;

                                      return GestureDetector(
                                        onTap: () {
                                          if (!canSaveCard) {
                                            return;
                                          }

                                          final Map<dynamic, dynamic> data =
                                              widget.cards.elementAt(realIndex);

                                          selectedTitleInfo =
                                              data['titleInfo'] ?? '';

                                          chooseCard();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            horizontalPadding,
                                            verticalPadding,
                                            horizontalPadding,
                                            verticalPadding,
                                          ),
                                          child: MenuItem(
                                            titleInfo: titleInfo,
                                            descriptionInfo: descriptionInfo,
                                            imageUrl: imageUrl,
                                            textColor: textColor,
                                            backgroundColor: backgroundColor,
                                            ratio: ratio,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 45),
                      ],
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
}
