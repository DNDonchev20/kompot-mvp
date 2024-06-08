import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:kompot/language_manager.dart';

import 'package:kompot/utils.dart';
import 'package:kompot/routes.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/database_manager.dart';

import 'package:kompot/pages/category_page.dart';

import 'package:kompot/pages/components/header.dart';
import 'package:kompot/pages/components/background.dart';
import 'package:kompot/pages/components/category_item.dart';

import 'package:kompot/pages/warnings/no_banners.dart';
import 'package:flutter_translate/flutter_translate.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  static const routeName = '/menu_page';

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String title = translate('menu_page.title');

  late InfiniteScrollController controller;
  double itemExtent = 100;
  double get screenWidth => MediaQuery.of(context).size.width;

  Map<dynamic, dynamic>? _fetchedData;
  bool _dataFetched = false;
  int currentIndex = 0;
  String selectedTitleInfo = '';

  List<String> categories = [];

  bool canSaveCard = true;

  @override
  void initState() {
    super.initState();

    canSaveCard = true;

    _fetchDataAndInitializeState();
  }

  void _fetchDataAndInitializeState() async {
    await _fetchBannersData();

    if (_fetchedData != null && _fetchedData!.isNotEmpty) {
      getCategories();
      removeEmptyCategories();
    }

    currentIndex = [0, 0, 1, 2][(_fetchedData!.length - 1).clamp(0, 3)];
    controller = InfiniteScrollController(initialItem: currentIndex);
  }

  Future<void> _fetchBannersData() async {
    try {
      DatabaseReference bannersRef;

      if(currentLanguage == 'bg'){
        bannersRef = databaseReference.child('banners');
      }
      else if(currentLanguage == 'en'){
        bannersRef = databaseReference.child('bannersBgEn');
      }
      else if(currentLanguage == 'nl'){
        //trqq se smeni kat imame karti na niderlanski
        //sa go ostavqm shot she dava init error na ref dolu
        bannersRef = databaseReference.child('bannersBgEn');
      }
      else{
        bannersRef = databaseReference.child('bannersBgEn');
      }

      DatabaseEvent event = await bannersRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> dataSnapshot =
            snapshot.value as Map<dynamic, dynamic>;

        var sortedData = Map.fromEntries(dataSnapshot.entries.toList()
          ..sort((a, b) => (a.value['titleInfo'] ?? '')
              .compareTo(b.value['titleInfo'] ?? '')));

        setState(() {
          _fetchedData = sortedData;
          _dataFetched = true;
        });
      } else {
        setState(() {
          _dataFetched = true;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        _dataFetched = true;
      });
    }
  }

  void getCategories() {
    List<dynamic> allCards = _fetchedData!.values.toList();

    for (var i = 0; i < allCards.length; i++) {
      allCards[i] = allCards[i]['titleInfo'];
    }

    Map<String, List<String>> categoriesMap = {};

    for (var i = 0; i < allCards.length; i++) {
      String card = allCards[i];

      List<String> words = card.split(' ');

      String firstWord = words[0];

      if (!categoriesMap.containsKey(firstWord)) {
        categoriesMap[firstWord] = [];
      }

      categoriesMap[firstWord]!.add(card);
    }

    for (var i = 0; i < categoriesMap.keys.length; i++) {
      String key = categoriesMap.keys.elementAt(i);

      List<String> cards = categoriesMap[key]!;

      String category = key;

      if (cards.length > 1) {
        for (var j = 1; true; j++) {
          if (j >= cards[0].split(' ').length) break;

          String currentWord = cards[0].split(' ')[j];

          bool isSame = true;

          for (var k = 1; k < cards.length; k++) {
            String cardWord = cards[k].split(' ')[j];

            if (cardWord != currentWord) {
              isSame = false;
              break;
            }
          }

          if (!isSame) break;

          category += ' $currentWord';
        }
      } else {
        category = cards[0];
      }

      categories.add(category);
    }
  }

  void removeEmptyCategories() {
    dynamic chosenCards = getCardsList();

    for (var i = 0; i < categories.length; i++) {
      String category = categories[i];

      List<String> cards = getCardsInCategory(category);

      bool shouldRemoveCategory = true;

      for (var j = 0; j < cards.length; j++) {
        if (!chosenCards.contains(cards[j])) {
          shouldRemoveCategory = false;
          break;
        }
      }

      if (shouldRemoveCategory) {
        categories.remove(category);
        i--;
      }
    }
  }

  List<String> getCardsInCategory(String category) {
    dynamic categoryCards = _fetchedData!.values
        .where((element) => element['titleInfo'].contains(category))
        .toList();

    List<String> cards = [];

    for (var i = 0; i < categoryCards.length; i++) {
      cards.add(categoryCards[i]['titleInfo']);
    }

    return cards;
  }

  void chooseCategory() async {
    dynamic categoryCards = _fetchedData!.values
        .where((element) => element['titleInfo'].contains(selectedTitleInfo))
        .toList();

    // ignore: use_build_context_synchronously
    navigateWithMPR(
      CategoryPage(
        title: selectedTitleInfo,
        cards: categoryCards,
      ),
      CategoryPage.routeName,
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
                          title,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (_dataFetched)
                          _fetchedData == null || _fetchedData!.isEmpty
                              ? NoBanners()
                              : Expanded(
                                  child: SizedBox(
                                    height: 450,
                                    width: screenWidth - 20,
                                    child: InfiniteCarousel.builder(
                                      itemCount: categories.length,
                                      itemExtent: itemExtent,
                                      axisDirection: Axis.vertical,
                                      center: true,
                                      velocityFactor: 0.75,
                                      scrollBehavior: kIsWeb
                                          ? ScrollConfiguration.of(context)
                                              .copyWith(
                                              dragDevices: {
                                                PointerDeviceKind.touch,
                                                PointerDeviceKind.mouse,
                                              },
                                            )
                                          : null,
                                      loop: false,
                                      controller: controller,
                                      onIndexChanged: onCarouselIndexChanged,
                                      itemBuilder:
                                          (context, itemIndex, realIndex) {
                                        final currentOffset =
                                            itemExtent * realIndex;
                                        Map<dynamic, dynamic> data = {};

                                        for (var i = 0;
                                            i < _fetchedData!.values.length;
                                            i++) {
                                          data = _fetchedData!.values
                                              .elementAt(realIndex + i);

                                          if (data['titleInfo'].contains(
                                              categories[realIndex])) {
                                            break;
                                          }
                                        }

                                        final String titleInfo =
                                            categories[realIndex];
                                        final String imageUrl =
                                            data['logo'] as String? ?? '';
                                        final Color textColor =
                                            data['textColor'] != null
                                                ? parseColor(data['textColor']!)
                                                : Colors.black;
                                        final Color backgroundColor =
                                            data['backgroundColor'] != null
                                                ? parseColor(
                                                    data['backgroundColor']!)
                                                : Colors.white;

                                        final double opacity =
                                            calculateOpacity(itemIndex);

                                        return Opacity(
                                          opacity: opacity,
                                          child: AnimatedBuilder(
                                            animation: controller,
                                            builder: (context, child) {
                                              final diff = (controller.offset -
                                                  currentOffset);
                                              const maxPadding = 15.0;
                                              final carouselRatio =
                                                  itemExtent / maxPadding;

                                              double ratio =
                                                  (diff / carouselRatio).abs();
                                              const double verticalPadding =
                                                  7.5;
                                              final double horizontalPadding =
                                                  ratio.clamp(0, 10) * 1.5;

                                              return GestureDetector(
                                                onTap: () {
                                                  if (!canSaveCard) {
                                                    return;
                                                  }

                                                  selectedTitleInfo =
                                                      categories[realIndex];

                                                  chooseCategory();
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                    horizontalPadding,
                                                    verticalPadding,
                                                    horizontalPadding,
                                                    verticalPadding,
                                                  ),
                                                  child: CategoryItem(
                                                    titleInfo: titleInfo,
                                                    imageUrl: imageUrl,
                                                    textColor: textColor,
                                                    backgroundColor:
                                                        backgroundColor,
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
                                )
                        else
                          const Expanded(
                            child: Center(
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: CircularProgressIndicator(),
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
