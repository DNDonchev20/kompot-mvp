import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kompot/routes.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/pages/home_page.dart';
import 'package:kompot/pages/start_page.dart';
import 'package:kompot/pages/account_page.dart';
import 'package:kompot/pages/language_page.dart';
import 'package:flutter_translate/flutter_translate.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const routeName = '/settings_page';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String title = translate('settings_page.title');
  String subtitle = translate('settings_page.subtitle');
  String howWorks = translate('settings_page.how_works');
  String language = translate('settings_page.language');
  String contact = translate('settings_page.contact');
  String clear = translate('settings_page.clear');
  String exit = translate('settings_page.exit');
  String termsOfUse = translate('settings_page.terms_of_use');
  String privacyPolicy = translate('settings_page.privacy_policy');
  String titleLanguage = translate('settings_page.title_language');

  void goToHomePage() {
    navigateWithPRB(
      const HomePage(),
      HomePage.routeName,
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

  Future<void> launchInBrowser(String stringUrl) async {
    final Uri url = Uri.parse(stringUrl);

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();

    clearStorage();

    navigateWithMPR(
      const StartPage(),
      StartPage.routeName,
    );

    clearCache();
  }

  Future<void> changeLanguage(String newLanguage) async {
    final delegate = LocalizedApp.of(context).delegate;

    await delegate.changeLocale(Locale(newLanguage));

    setState(() {});
  }

  Widget buildSetting(Widget icon, String text, Function onPressed,
      [IconData proceed = Icons.arrow_forward_ios]) {
    return Container(
      height: 50,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          onPressed();
        },
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
            const Spacer(),
            Icon(proceed),
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
                      buildSetting(
                        const Icon(Icons.person),
                        subtitle,
                        () {
                          navigateWithPRB(
                            const AccountPage(),
                            AccountPage.routeName,
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
                        },
                      ),
                      buildSetting(
                        const Icon(Icons.emoji_objects_outlined),
                        howWorks,
                        () {
                          launchInBrowser(
                              "https://www.kompotloyalty.com/howtouse");
                        },
                      ),
                      buildSetting(
                        const Icon(Icons.email_outlined),
                        contact,
                        () {
                          launchInBrowser(
                              "https://www.kompotloyalty.com/contact");
                        },
                        Icons.open_in_new_outlined,
                      ),
                      const SizedBox(height: 45),
                      buildSetting(
                        const Icon(Icons.language),
                        language,
                        () {
                          navigateWithMPR(
                            const LanguagePage(),
                            LanguagePage.routeName,
                          );
                        },
                      ),
                      buildSetting(
                        const Icon(Icons.delete_outline_rounded),
                        clear,
                        () {
                          clearCards();

                          navigateWithMPR(
                            const HomePage(),
                            HomePage.routeName,
                          );
                        },
                      ),
                      buildSetting(
                        const Icon(Icons.person),
                        exit,
                        () {
                          signOut();
                        },
                        Icons.logout,
                      ),
                      const SizedBox(height: 45),
                      buildSetting(
                        const Icon(Icons.info_outline),
                        termsOfUse,
                        () {
                          launchInBrowser(
                            "https://doc-hosting.flycricket.io/kompot-loyalty-terms-of-use/88210240-6c4f-4e7e-90f7-74713047b230/terms",
                          );
                        },
                      ),
                      buildSetting(
                        const Icon(Icons.lock_outline),
                        privacyPolicy,
                        () {
                          launchInBrowser(
                            "https://doc-hosting.flycricket.io/kompot-loyalty-privacy-policy/5b7bc52b-9d9c-4ad6-bd67-0fce7ff2f658/privacy",
                          );
                        },
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
                      goToHomePage();
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
