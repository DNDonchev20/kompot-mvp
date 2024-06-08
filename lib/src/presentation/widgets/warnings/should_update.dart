import 'package:flutter/material.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_translate/flutter_translate.dart';

class ShouldUpdate extends StatelessWidget {
  ShouldUpdate({Key? key}) : super(key: key);

  final String title = translate('no_nfc_warning.title');
  final String subtitle = translate('no_nfc_warning.subtitle');

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 55.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontFamily: 'VarelaRound',
                  color: Color(0x80000000),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              String storeURL = '';
              if (Platform.isAndroid) {
                storeURL = 'market://details?id=com.kompot.loyalty';
              }

              Uri uri = Uri.parse(storeURL);

              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              backgroundColor: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.all(0),
            ),
            child: Container(
              height: 45,
              width: 240,
              color: const Color(0x42D9D9D9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: SizedBox(
                      width: 28,
                      child: Image(
                        image: AssetImage(
                          'assets/icons/download.png',
                        ),
                      ),
                    ),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 15),
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
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
