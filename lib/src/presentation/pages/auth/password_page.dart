import 'package:flutter/material.dart';

import 'package:kompot/routes.dart';

import 'package:kompot/pages/auth/name_page.dart';
import 'package:kompot/pages/auth/email_page.dart';

import 'package:flutter_translate/flutter_translate.dart';

class PasswordPage extends StatefulWidget {
  final String email;

  const PasswordPage({Key? key, required this.email}) : super(key: key);

  static const routeName = '/password_page';

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController controller = TextEditingController();

  String title = translate('password_page.title');
  String subtitle = translate('password_page.subtitle');
  String fieldTitle = translate('password_page.field_title');
  String nextButton = translate('password_page.next_button');
  String beforeButton = translate('password_page.before_button');
  String passwordEmpty = translate('password_page.password_empty');
  String passwordSmallLetter = translate('password_page.password_small_letter');
  String passwordNumber = translate('password_page.password_number');
  String passwordLength = translate('password_page.password_length');
  String passwordValid = translate('password_page.password_invalid');

  bool obscureText = true;
  bool passwordInvalid = false;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  bool passwordIsValid(String password) {
    return RegExp(r"[a-z]").hasMatch(password) &&
        RegExp(r"\d").hasMatch(password) &&
        password.length >= 8;
  }

  String getInvalidPasswordMessage(String password) {
    if (password.isEmpty) {
      return passwordEmpty;
    } else if (!RegExp(r"[a-z]").hasMatch(password)) {
      return passwordSmallLetter;
    } else if (!RegExp(r"\d").hasMatch(password)) {
      return passwordNumber;
    } else if (password.length < 8) {
      return passwordLength;
    }
    return passwordValid;
  }

  void submit() {
    String password = controller.text;
    bool isValid = passwordIsValid(password);

    if (isValid) {
      navigateTo(
        PageRouteBuilder(
          settings: const RouteSettings(name: NamePage.routeName),
          pageBuilder: (context, animation, secondaryAnimation) => NamePage(
            email: widget.email,
            password: password,
          ),
          transitionDuration: const Duration(milliseconds: 850),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        ),
      );
    } else {
      setState(() {
        passwordInvalid = true;
      });
    }
  }

  double reducedOpacity = 0.75;
  Color activeColor = Colors.red;
  Color inactiveColor = Colors.grey;
  double spacing = 3.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double verticalSpacing = screenHeight * 0.08;
    double logoSize = screenWidth * 0.25;
    double fontSizeTitle = screenWidth * 0.07;
    double fontSizeRegister = screenWidth * 0.05;
    double buttonPaddingHorizontal = screenWidth * 0.2;
    double buttonPaddingVertical = screenHeight * 0.03;
    double buttonFontSize = screenWidth * 0.05;
    double buttonSpacing = screenHeight * 0.02;
    double dotSize = screenWidth * 0.025;
    int maxSteps = 3;

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
              const SizedBox(height: 8),
              Opacity(
                opacity: reducedOpacity,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSizeRegister,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              SizedBox(
                width: screenWidth * 0.5,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextField(
                      controller: controller,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: fieldTitle,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 1.0,
                          vertical: 5.0,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (passwordInvalid)
                SizedBox(
                  width: screenWidth * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (String error
                          in getInvalidPasswordMessage(controller.text)
                              .split('\n'))
                        Text(
                          error,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                    ],
                  ),
                ),
              SizedBox(height: screenHeight * 0.2),
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
                    fontSize: buttonFontSize,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              SizedBox(height: buttonSpacing),
              GestureDetector(
                onTap: () {
                  navigateTo(
                    PageRouteBuilder(
                      settings: const RouteSettings(name: EmailPage.routeName),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const EmailPage(),
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
                },
                child: Text(
                  beforeButton,
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < maxSteps; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing),
                        child: Icon(
                          i == 1 ? Icons.circle : Icons.circle,
                          size: dotSize,
                          color: i == 1 ? activeColor : inactiveColor,
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
