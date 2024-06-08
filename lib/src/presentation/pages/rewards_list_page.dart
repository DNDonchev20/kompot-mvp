import 'package:flutter/material.dart';
import 'dart:async';

import 'package:kompot/routes.dart';
import 'package:kompot/nfc_data.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/card_manager.dart';
import 'package:kompot/reward_manager.dart';
import 'package:kompot/database_manager.dart';

import 'package:kompot/pages/home_page.dart';
import 'package:kompot/pages/reward_page.dart';

import 'package:kompot/pages/components/background.dart';
import 'package:kompot/pages/components/reward_item.dart';
import 'package:flutter_translate/flutter_translate.dart';

class RewardData {
  RewardData({
    required this.titleInfo,
    required this.textReward,
    required this.date,
    required this.logo,
    required this.stamp,
    required this.backgroundColor,
    required this.textColor,
  });

  final String titleInfo;
  final String textReward;
  final String date;
  final String logo;
  final String stamp;
  final String backgroundColor;
  final String textColor;
}

class RewardsListPage extends StatefulWidget {
  const RewardsListPage({Key? key}) : super(key: key);

  static const routeName = '/rewards_list_page';

  @override
  State<RewardsListPage> createState() => _RewardsListPageState();
}

class _RewardsListPageState extends State<RewardsListPage> {
  String title = translate('reward_list_page.title');

  String email = getItem('email') ?? '';

  List<RewardData> rewardsList = [];

  @override
  void initState() {
    super.initState();

    fetchRewards();
  }

  Future<void> fetchRewards() async {
    try {
      final claimedRewardsDataReference = databaseReference
          .child('rewards')
          .orderByChild('email')
          .equalTo(email);

      final claimedRewardsDataSnapshot =
          await claimedRewardsDataReference.once();

      if (claimedRewardsDataSnapshot.snapshot.value == null) {
        print('No claimed rewards data found for email: $email');
        return;
      }

      final claimedRewardsData = claimedRewardsDataSnapshot.snapshot.value;

      final cardsReference = databaseReference.child('cards');
      final cardsSnapshot = await cardsReference.once();

      if (cardsSnapshot.snapshot.value == null) {
        print('No cards data found');
        return;
      }

      final cardsData = cardsSnapshot.snapshot.value;

      final List<RewardData> fetchedRewardsList = [];

      if (cardsData != null && cardsData is Map<dynamic, dynamic>) {
        if (claimedRewardsData != null &&
            claimedRewardsData is Map<dynamic, dynamic>) {
          claimedRewardsData.forEach((claimedKey, claimedValue) async {
            final claimedRewardTitleInfo = claimedValue['titleInfo'];

            if (!isRewardValid(claimedValue['date'])) {
              await deleteReward(
                  claimedValue['titleInfo'], claimedValue['date']);
            }

            cardsData.forEach((cardKey, cardValue) {
              if (cardKey != 'rewards' && cardKey != 'stamps') {
                final rewardTitleInfo = cardValue['titleInfo'];

                if (claimedRewardTitleInfo == rewardTitleInfo) {
                  fetchedRewardsList.add(RewardData(
                    titleInfo: cardValue['titleInfo'] ?? '',
                    textReward: cardValue['textReward'] ?? '',
                    date: claimedValue['date'] ?? '',
                    logo: cardValue['logo'] ?? '',
                    stamp: cardValue['stamp'] ?? '',
                    backgroundColor: cardValue['backgroundColor'] ?? '',
                    textColor: cardValue['textColor'] ?? '',
                  ));
                }
              }
            });
          });
        }
      }

      setState(() {
        rewardsList = fetchedRewardsList;
      });
    } catch (e) {
      print('Error fetching rewards: $e');
    }
  }

  void goToHomePage() {
    navigateWithPRB(
      const HomePage(),
      HomePage.routeName,
      600,
      (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, -1.0);
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

  void chooseReward(String titleInfo, String? date) async {
    dynamic cardData = await fetchCard(titleInfo);

    List<dynamic> identifier = cardData['identifier'];

    setCard(titleInfo, identifier, date);

    navigateWithMPR(
      RewardPage(
        stamp: cardData['stamp'],
        logo: cardData['logo'],
        textReward: cardData['textReward'],
      ),
      RewardPage.routeName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 48, bottom: 16),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...rewardsList.map((reward) {
                      return ElevatedButton(
                        onPressed: () {
                          chooseReward(reward.titleInfo, reward.date);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Colors.white.withOpacity(0),
                          padding: const EdgeInsets.all(0),
                        ),
                        child: RewardItem(
                          titleInfo: reward.titleInfo,
                          textReward: reward.textReward,
                          date: reward.date,
                          logo: reward.logo,
                          stamp: reward.stamp,
                          backgroundColor: reward.backgroundColor,
                          textColor: reward.textColor,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  goToHomePage();
                },
              ),
            ),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  goToHomePage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
