import 'package:flutter/material.dart';

import 'package:kompot/routes.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/language_manager.dart';

import 'package:kompot/pages/home_page.dart';
import 'package:kompot/pages/auth/email_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  static const routeName = '/start_page';

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  bool showLogo = false;
  bool showStartPage = false;

  String? email;
  String? firstName;

  @override
  void initState() {
    super.initState();

    setupLanguage();

    Future.delayed(const Duration(milliseconds: 750), () {
      setState(() {
        showLogo = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          showStartPage = true;
          fetchDataAndShowContents();
        });
      });
    });
  }

  void setupLanguage() async {
    await isStorageReady();

    currentLanguage = getLanguage();

    if (currentLanguage == 'None') {
      String country = await getCountry();

      currentLanguage = getCodeForCountryName(country);

      print("Language based on country set to: $currentLanguage");
    } else {
      print("Language was already saved as: $currentLanguage");
    }

    // ignore: use_build_context_synchronously
    await changeLanguage(context, currentLanguage);
  }

  Future<void> fetchDataAndShowContents() async {
    await isStorageReady();

    email = getItem('email') ?? '';
    firstName = getItem('firstName') ?? '';
  }

  void _navigateToNextPage() {
    if (email == '') {
      navigateWithPRB(
        const EmailPage(),
        EmailPage.routeName,
        850,
        (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    } else {
      navigateWithPRB(
        const HomePage(),
        HomePage.routeName,
        850,
        (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: showLogo ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Center(
              child: Image.asset(
                'assets/images/kompot.png',
                width: 274,
                height: 175,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: showStartPage ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 1000),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 154,
                      height: 155,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Kompot',
                      style: TextStyle(
                        fontFamily: 'VarelaRound',
                        fontSize: 48,
                      ),
                    ),
                    const Opacity(
                      opacity: 0.65,
                      child: Text(
                        'The loyalty card solution',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 180),
                    GestureDetector(
                      onTap: _navigateToNextPage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                            ),
                            children: [
                              const TextSpan(text: 'Collect the stamps'),
                              WidgetSpan(
                                child: SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: Image.asset('assets/icons/arrow.png'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
