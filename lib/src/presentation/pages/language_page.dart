import 'package:flutter/material.dart';

import 'package:circle_flags/circle_flags.dart';

import 'package:kompot/routes.dart';
import 'package:kompot/language_manager.dart';

import 'package:kompot/pages/settings_page.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  static const routeName = '/account_page';

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final double flagSize = 32;

  void goToSettingsPage() {
    navigateWithPRB(
      const SettingsPage(),
      SettingsPage.routeName,
      600,
      (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
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

  Widget buildLanguage(int index) {
    return Container(
      height: 50,
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          await changeLanguage(context, languageCodes[index]);

          goToSettingsPage();
        },
        child: Row(
          children: [
            const SizedBox(width: 16),
            SizedBox(
              height: flagSize,
              width: flagSize,
              child: CircleFlag(countryCodes[index]),
            ),
            const SizedBox(width: 24),
            Text(
              languageNames[index],
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 64, bottom: 40),
                        child: Text(
                          'Languages',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (int i = 0; i < languageCodes.length; i++)
                        Column(
                          children: [
                            buildLanguage(i),
                            if (i != languageCodes.length - 1)
                              const Divider(
                                height: 0,
                                thickness: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      goToSettingsPage();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
