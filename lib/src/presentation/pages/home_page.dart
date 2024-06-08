import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'dart:math' as math;

import 'package:provider/provider.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:kompot/nfc.dart';
import 'package:kompot/utils.dart';
import 'package:kompot/routes.dart';
import 'package:kompot/nfc_data.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/database_manager.dart';

import 'package:kompot/pages/menu_page.dart';
import 'package:kompot/pages/card_page.dart';
import 'package:kompot/pages/settings_page.dart';
import 'package:kompot/pages/rewards_list_page.dart';

import 'package:kompot/pages/components/home_item.dart';
import 'package:kompot/pages/components/background.dart';

import 'package:kompot/pages/warnings/no_cards.dart';
import 'package:kompot/pages/warnings/no_nfc.dart';
import 'package:kompot/pages/warnings/should_update.dart';

import 'package:flutter_translate/flutter_translate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String menus = translate('home_page.menu_button');
  String reward = translate('home_page.reward_button');

  late InfiniteScrollController controller;

  int selectedIndex = 0;
  double itemExtent = 225;
  bool loop = false;

  int hour = DateTime.now().hour;

  late String user = getItem('firstName') ?? 'Guest';
  late String greeting;

  dynamic items;
  double maxRotation = 32;
  List<List<double>> rotations = [];
  List<List<Offset>> offsets = [];

  bool clearStorageAtLoad = false;

  bool isDeveloper = false;
  bool requiresUpdate = false;

  @override
  void initState() {
    super.initState();

    controller = InfiniteScrollController(initialItem: 0);

    showReview = false;

    if (!versionDataFetched) {
      checkVersion();

      versionDataFetched = true;
    }

    loadData();
    getGreeting();

    BackButtonInterceptor.add(interceptBackButton, context: context);
  }

  Future<void> checkVersion() async {
    final DatabaseEvent event = await databaseReference.child('version').once();
    Map<dynamic, dynamic>? versionData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (versionData != null) {
      checkAndUpdateVersion(versionData);
    }
  }

  void checkAndUpdateVersion(Map<dynamic, dynamic> versionData) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String currentVersion = packageInfo.version;
    String fetchedVersion = isDeveloper
        ? versionData['versionDevelopers']
        : versionData['versionUsers'];

    print("Current version: $currentVersion");
    print("Fetched version: $fetchedVersion");

    int currentVersionNumber = int.parse(currentVersion.replaceAll('.', ''));
    int fetchedVersionNumber = int.parse(fetchedVersion.replaceAll('.', ''));

    requiresUpdate = fetchedVersionNumber > currentVersionNumber;
  }

  void loadData() {
    List<String> cards = getCardsList();

    items = cards.isNotEmpty ? cards : null;

    const maxOffset = 3;

    if (items != null) {
      for (int i = 0; i < items.length; i++) {
        rotations.add(
          List.generate(
            9,
            (_) =>
                ((math.Random().nextDouble() * maxRotation * 2) - maxRotation) *
                math.pi /
                180,
          ),
        );
        offsets.add(
          List.generate(
            9,
            (index) => Offset(
              (math.Random().nextDouble() * maxOffset * 2) - maxOffset,
              (math.Random().nextDouble() * maxOffset * 2) - maxOffset,
            ),
          ),
        );
      }
    }
  }

  void getGreeting() {
    if (hour >= 6 && hour < 12) {
      greeting = translate('home_page.title_one');
    } else if (hour >= 12 && hour < 18) {
      greeting = translate('home_page.title_two');
    } else {
      greeting = translate('home_page.title_three');
    }

    greeting += ',\n$user';
  }

  bool interceptBackButton(bool stopDefaultButtonEvent, RouteInfo info) {
    if (info.ifRouteChanged(context)) return false;

    return true;
  }

  void goToCard(Map<String, dynamic> cardData, int index) {
    setCard(cardData['titleInfo'], cardData['identifier']);

    navigateWithPRB(
      CardPage(
        cardData: cardData,
        rotations: rotations[index],
        offsets: offsets[index],
      ),
      CardPage.routeName,
      700,
      (context, animation, secondaryAnimation, child) {
        var begin = 0.0;
        var end = 1.0;
        var curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var scaleAnimation = animation.drive(tween);

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }

  void goToSettings() {
    navigateWithPRB(
      const SettingsPage(),
      SettingsPage.routeName,
      600,
      (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;

        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  void goToMenuPage() {
    navigateWithPRB(
      const MenuPage(),
      MenuPage.routeName,
      600,
      (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);

        final slideAnimation = animation.drive(tween);

        final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: opacityAnimation,
            child: child,
          ),
        );
      },
    );
  }

  void goToRewardsListPage() {
    navigateWithPRB(
      const RewardsListPage(),
      RewardsListPage.routeName,
      600,
      (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);

        final slideAnimation = animation.drive(tween);

        final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: opacityAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    controller.dispose();

    BackButtonInterceptor.remove(interceptBackButton);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NFCReader>(
      builder: (context, nfcreader, child) {
        if (nfcreader.shouldUpdateCard) {
          var currentCard = getCurrentCard();

          var cardData = getCard(currentCard);

          int circleCount = int.tryParse(cardData['circleNumber'] ?? '') ?? 0;

          if (cardData['stampCount'] == circleCount - 1) {
            cardData['stampCount'] = 0;
          } else {
            cardData['stampCount']++;
          }

          updateCard(currentCard, cardData);

          nfcreader.homeIsUpdated = true;

          if (nfcreader.cardIsUpdated) {
            nfcreader.shouldUpdateCard = false;

            nfcreader.cardIsUpdated = false;
            nfcreader.homeIsUpdated = false;
          }
        }

        return Scaffold(
          body: SafeArea(
            child: Background(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          onPressed: goToSettings,
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.white.withOpacity(0),
                            padding: const EdgeInsets.all(0),
                          ),
                          child: const SizedBox(
                            width: 32,
                            child: Image(
                              alignment: Alignment.centerLeft,
                              image: AssetImage('assets/icons/settings.png'),
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: SizedBox(
                          width: 172,
                          height: 54,
                          child: Image(
                            image: AssetImage('assets/images/kompot.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: mapRange(
                      MediaQuery.of(context).size.height,
                      600,
                      850,
                      0,
                      35,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Text(
                        greeting,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  FutureBuilder<bool>(
                    future: NfcManager.instance.isAvailable(),
                    builder: (context, snapshot) {
                      if (snapshot.data != true) {
                        return NoNFC();
                      }

                      return FutureBuilder(
                        future: checkVersion(),
                        builder: (context, snapshot) {
                          if (requiresUpdate) {
                            return ShouldUpdate();
                          }

                          return FutureBuilder(
                            future: isStorageReady(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                );
                              }

                              if (clearStorageAtLoad) {
                                clearStorage();
                              }

                              loadData();

                              return Expanded(
                                child: Column(children: [
                                  if (items != null)
                                    FractionallySizedBox(
                                      widthFactor: 1,
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: InfiniteCarousel.builder(
                                          itemCount: items.length,
                                          itemExtent: itemExtent,
                                          center: true,
                                          velocityFactor: 0.75,
                                          scrollBehavior: kIsWeb
                                              ? ScrollConfiguration.of(context)
                                                  .copyWith(
                                                  dragDevices: {
                                                    PointerDeviceKind.touch,
                                                    PointerDeviceKind.mouse
                                                  },
                                                )
                                              : null,
                                          loop: loop,
                                          controller: controller,
                                          onIndexChanged: (index) {
                                            if (selectedIndex != index) {
                                              setState(() {
                                                selectedIndex = index;
                                              });
                                            }
                                          },
                                          itemBuilder:
                                              (context, itemIndex, realIndex) {
                                            final currentOffset =
                                                itemExtent * realIndex;

                                            return AnimatedBuilder(
                                              animation: controller,
                                              builder: (context, child) {
                                                final diff =
                                                    (controller.offset -
                                                        currentOffset);
                                                const maxPadding = 10.0;
                                                final carouselRatio =
                                                    itemExtent / maxPadding;

                                                double ratio =
                                                    (diff / carouselRatio)
                                                        .abs();

                                                dynamic card =
                                                    getCard(items[itemIndex]);

                                                return Hero(
                                                  tag: card['titleInfo'],
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      top:
                                                          (diff / carouselRatio)
                                                              .abs(),
                                                      bottom:
                                                          (diff / carouselRatio)
                                                              .abs(),
                                                      right: 5,
                                                      left: 5,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        goToCard(
                                                          card,
                                                          itemIndex,
                                                        );

                                                        moveCardToStart(
                                                            card['titleInfo']);

                                                        Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500),
                                                          () {
                                                            setState(() {
                                                              controller
                                                                  .jumpTo(0.0);
                                                            });
                                                          },
                                                        );
                                                      },
                                                      child: HomeItem(
                                                        cardData: card,
                                                        rotations: rotations[
                                                            itemIndex],
                                                        offsets:
                                                            offsets[itemIndex],
                                                        ratio: ratio,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  else
                                    NoCards(),
                                  const SizedBox(height: 25),
                                  Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: goToMenuPage,
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor:
                                              const Color(0xFFFFFFFF),
                                          padding: const EdgeInsets.all(0),
                                        ),
                                        child: Container(
                                          height: 45,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          color: const Color(0x42D9D9D9),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: SizedBox(
                                                  width: 28,
                                                  child: Image(
                                                    image: AssetImage(
                                                      'assets/icons/add.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                menus,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 15),
                                                child: SizedBox(
                                                  width: 8,
                                                  height: 13,
                                                  child: Image(
                                                    image: AssetImage(
                                                      'assets/icons/arrow.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      ElevatedButton(
                                        onPressed: goToRewardsListPage,
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor:
                                              const Color(0xFFFFFFFF),
                                          padding: const EdgeInsets.all(0),
                                        ),
                                        child: Container(
                                          height: 45,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          color: const Color(0x42D9D9D9),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: SizedBox(
                                                  width: 28,
                                                  child: Image(
                                                    image: AssetImage(
                                                      'assets/icons/gift.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                reward,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 15),
                                                child: SizedBox(
                                                  width: 8,
                                                  height: 13,
                                                  child: Image(
                                                    image: AssetImage(
                                                      'assets/icons/arrow.png',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Navbar(
                                  //   currentIndex: 0,
                                  //   onTap: (index) {},
                                  // ),
                                  if (items == null)
                                    SizedBox(
                                      height: mapRange(
                                        MediaQuery.of(context).size.height,
                                        600,
                                        850,
                                        0,
                                        45,
                                      ),
                                    )
                                ]),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
