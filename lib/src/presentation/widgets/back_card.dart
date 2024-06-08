import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';

import 'package:kompot/utils.dart';

class BackCard extends StatelessWidget {
  const BackCard({
    Key? key,
    required this.cardData,
    required this.flipCard,
  }) : super(key: key);

  final Map<String, dynamic> cardData;
  final Function flipCard;

  Widget buildButton(Widget icon, String text, bool isNull, Function onTap) {
    if (isNull) {
      return const SizedBox();
    }

    const double buttonWidth = 200;
    const double buttonHeight = 40;

    const double leftPadding = 10;

    return ElevatedButton(
      onPressed: () {
        onTap();
      },
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        backgroundColor: Colors.white.withOpacity(0),
        padding: const EdgeInsets.all(0),
      ),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: Row(
          children: [
            const SizedBox(width: leftPadding),
            icon,
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> launchInBrowser(String stringUrl) async {
    final Uri url = Uri.parse(stringUrl);

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      cardData['phoneTextInfo'],
      cardData['websiteTextInfo'],
      cardData['instagramTextInfo'],
      cardData['addressInfo'],
    ];

    int buttonCount = 0;

    for (final String button in buttons) {
      if (button != 'nullValue') {
        buttonCount++;
      }
    }

    const double iconSize = 25;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double marginBeforeLogo = mapRange(screenHeight, 600, 900, 0, 80);
    final double marginAfterLogo = mapRange(screenHeight, 600, 900, 0, 35);

    final double upperMargin =
        [100, 80, 60, 30][(buttonCount - 1).clamp(0, 4)].toDouble() - 10;
    final double marginBeforeButtons =
        mapRange(screenHeight, 600, 900, 0, upperMargin);

    final double titleFontSize = screenHeight * 0.034;
    final double descriptionFontSize = screenHeight * 0.024;

    final double radius = screenHeight * 0.068;

    return SwipeDetector(
      onSwipeRight: (offset) {
        flipCard(false);
      },
      onSwipeLeft: (offset) {
        flipCard(true);
      },
      child: Container(
        width: screenHeight * 0.4,
        height: screenHeight * 0.75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: marginBeforeLogo),
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
                    cardData['logo'],
                  ),
                ),
              ),
              SizedBox(height: marginAfterLogo),
              Text(
                cardData['titleInfo'],
                style: TextStyle(
                  fontFamily: 'VarelaRound',
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        cardData['descriptionInfo'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: descriptionFontSize,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: marginBeforeButtons / 2),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildButton(
                            const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: iconSize,
                            ),
                            cardData['phoneTextInfo'],
                            cardData['phoneTextInfo'] == 'nullValue',
                            () {
                              launchInBrowser(
                                  "tel:${cardData['phoneTextInfo']}");
                            },
                          ),
                          buildButton(
                            const Icon(
                              Icons.language,
                              color: Colors.white,
                              size: iconSize,
                            ),
                            "Open Website",
                            cardData['websiteTextInfo'] == 'nullValue',
                            () {
                              launchInBrowser(cardData['websiteTextInfo']);
                            },
                          ),
                          buildButton(
                            const Image(
                              image: AssetImage('assets/icons/instagram.png'),
                              color: Colors.white,
                              width: iconSize,
                            ),
                            "Instagram",
                            cardData['instagramTextInfo'] == 'nullValue',
                            () {
                              launchInBrowser(cardData['instagramTextInfo']);
                            },
                          ),
                          buildButton(
                            const Icon(
                              Icons.map,
                              color: Colors.white,
                              size: iconSize,
                            ),
                            "Google Maps",
                            cardData['addressInfo'] == 'nullValue',
                            () {
                              launchInBrowser(cardData['addressInfo']);
                            },
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                    SizedBox(height: marginBeforeButtons / 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
