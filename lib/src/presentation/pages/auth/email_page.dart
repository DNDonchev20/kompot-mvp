import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:kompot/routes.dart';

import 'package:kompot/pages/start_page.dart';

import 'package:kompot/pages/auth/password_page.dart';
import 'package:kompot/pages/auth/password_login_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_translate/flutter_translate.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({Key? key}) : super(key: key);

  static const routeName = '/email_page';

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final TextEditingController controller = TextEditingController();

  String title = translate('email_page.title');
  String fieldTitle = translate('email_page.field_title');
  String nextButton = translate('email_page.next_button');
  String beforeButton = translate('email_page.before_button');
  String validEmail = translate('email_page.valid_email');

  bool emailInvalid = false;
  bool emailSent = false;

  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }

  bool emailIsValid(String email) {
    return EmailValidator.validate(email);
  }

  Future<bool> checkEmailExistence(String email) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  void submit() async {
    String email = controller.text.toLowerCase().trim();

    bool isValid = emailIsValid(email);

    if (isValid) {
      bool emailExists = await checkEmailExistence(email);

      if (emailExists) {
        navigateWithPRB(
          PasswordLoginPage(email: email),
          PasswordLoginPage.routeName,
          750,
          (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
      } else {
        navigateWithPRB(
          PasswordPage(email: email),
          PasswordPage.routeName,
          750,
          (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
      }
    } else {
      setState(() {
        emailInvalid = true;
      });
    }
  }

  Color activeColor = Colors.red;
  Color inactiveColor = Colors.grey;
  double spacing = 3.0;

  @override
  Widget build(BuildContext context) {
    int currentStep = 0;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double verticalSpacing = screenHeight * 0.08;
    double logoSize = screenWidth * 0.25;
    double fontSizeTitle = screenWidth * 0.07;
    double fontSizeButton = screenWidth * 0.05;
    double buttonPaddingHorizontal = screenWidth * 0.2;
    double buttonPaddingVertical = screenHeight * 0.03;
    double dotSize = screenWidth * 0.025;
    double maxSteps = 3.0;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: verticalSpacing),
              SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset('assets/images/logo.png'),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSizeTitle,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 55),
              SizedBox(
                width: 0.7 * screenWidth,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: fieldTitle,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 1.0,
                      vertical: 5.0,
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                    errorText:
                        emailInvalid ? validEmail : null,
                    errorStyle: const TextStyle(
                      color: Color(0xFFE91515),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 180),
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: const Color(0xFFEA4934),
                  padding: EdgeInsets.symmetric(
                    horizontal: buttonPaddingHorizontal,
                    vertical: buttonPaddingVertical,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  nextButton,
                  style: TextStyle(
                    fontSize: fontSizeButton,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  navigateTo(
                    PageRouteBuilder(
                      settings: const RouteSettings(name: StartPage.routeName),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const StartPage(),
                      transitionDuration: const Duration(milliseconds: 850),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0);
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
                    ),
                    true,
                  );

                  navigateWithPRB(
                    const StartPage(),
                    StartPage.routeName,
                    850,
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-1.0, 0.0);
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
                    true,
                  );
                },
                child: Text(
                  beforeButton,
                  style: TextStyle(
                    fontSize: fontSizeButton,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < maxSteps; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing),
                        child: Icon(
                          i <= currentStep ? Icons.circle : Icons.circle,
                          size: dotSize,
                          color: i <= currentStep ? activeColor : inactiveColor,
                        ),
                      ),
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
