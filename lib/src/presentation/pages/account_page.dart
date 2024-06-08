import 'package:flutter/material.dart';

import 'package:kompot/routes.dart';
import 'package:kompot/lc_manager.dart';

import 'package:kompot/pages/settings_page.dart';

import 'package:flutter_translate/flutter_translate.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  static const routeName = '/account_page';

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String email = getItem('email') ?? '';

  String firstName = getItem('firstName') ?? '';
  String lastName = getItem('lastName') ?? '';

  String get name => '$firstName $lastName';

  String gender = getItem('gender') ?? '';
  String dateOfBirth = getItem('dateOfBirth') ?? '';

  String title = translate('account_page.title');

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

  Widget buildField(Widget icon, String text) {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(width: 16),
          icon,
          const SizedBox(width: 24),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
                      Padding(
                        padding: const EdgeInsets.only(top: 64, bottom: 40),
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
                      buildField(const Icon(Icons.person), name),
                      buildField(const Icon(Icons.email_outlined), email),
                      gender == "Male"
                          ? buildField(const Icon(Icons.male), gender)
                          : buildField(const Icon(Icons.female), gender),
                      buildField(
                        const Icon(Icons.calendar_month),
                        dateOfBirth,
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
