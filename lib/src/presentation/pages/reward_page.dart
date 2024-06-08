import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kompot/nfc.dart';
import 'package:kompot/routes.dart';

import 'package:kompot/pages/home_page.dart';
import 'package:kompot/pages/rewards_list_page.dart';

import 'package:kompot/pages/components/background.dart';

import 'package:flutter_translate/flutter_translate.dart';

class RewardPage extends StatelessWidget {
  RewardPage(
      {Key? key,
      required this.logo,
      required this.stamp,
      required this.textReward})
      : super(key: key);

  static const routeName = '/reward_page';

  final String logo;
  final String stamp;
  final String textReward;

  final String title = translate('reward_page.title');

  @override
  Widget build(BuildContext context) {
    return Consumer<NFCReader>(builder: (context, nfcreader, child) {
      if (nfcreader.shouldUpdateReward) {
        nfcreader.shouldUpdateReward = false;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigateWithMPR(
            const HomePage(),
            HomePage.routeName,
            true,
          );
        });
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF2EFEF),
        body: Stack(
          children: [
            Background(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 74),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 75,
                      child: ClipOval(
                        child: Image.network(
                          logo,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 45),
                  Text(
                    textReward,
                    style: const TextStyle(
                      fontFamily: 'VarelaRound',
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 65),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Container(
                      width: 3,
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            stamp,
                            width: 180,
                            height: 194,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 61,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    navigateWithMPR(
                      const RewardsListPage(),
                      RewardsListPage.routeName,
                      true,
                    );
                  });
                },
              ),
            ),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    navigateWithMPR(
                      const RewardsListPage(),
                      RewardsListPage.routeName,
                      true,
                    );
                  });
                }
              },
            ),
          ],
        ),
      );
    });
  }
}
