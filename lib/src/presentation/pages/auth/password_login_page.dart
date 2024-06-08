import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:kompot/routes.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/database_manager.dart';

import 'package:kompot/pages/home_page.dart';
import 'package:kompot/pages/auth/email_page.dart';

import 'package:flutter_translate/flutter_translate.dart';

class PasswordLoginPage extends StatefulWidget {
  final String email;

  const PasswordLoginPage({Key? key, required this.email}) : super(key: key);

  static const routeName = '/password_login_page';

  @override
  State<PasswordLoginPage> createState() => _PasswordLoginPageState();
}

class _PasswordLoginPageState extends State<PasswordLoginPage> {
  final TextEditingController controller = TextEditingController();

  String title = translate('passwordLogin_page.title');
  String subtitle = translate('passwordLogin_page.subtitle');
  String fieldTitle = translate('passwordLogin_page.field_title');
  String nextButton = translate('passwordLogin_page.next_button');
  String beforeButton = translate('passwordLogin_page.before_button');
  String passwordError = translate('passwordLogin_page.password_error');

  late String firstName;
  late String lastName;

  late String gender;
  late String dateOfBirth;

  bool obscureText = true;
  bool passwordInvalid = false;

  Future<bool?> checkPasswordCorrectness(String email, String password) async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return false;
      } else {
        print('Error checking password correctness: $e');
        return null;
      }
    } catch (e) {
      print('Error checking password correctness: $e');
      return null;
    }
  }

  Future<void> getUserNamesByEmail(String email) async {
    try {
      final userDataReference =
          databaseReference.child('users').orderByChild('email').equalTo(email);

      DatabaseEvent userDataSnapshot = await userDataReference.once();
      DataSnapshot snapshot = userDataSnapshot.snapshot;

      dynamic userData = snapshot.value;

      if (userData == null) {
        print('User data not found for email: $email');
        return;
      }

      firstName = userData.values.first['firstName'] ?? '';
      lastName = userData.values.first['lastName'] ?? '';

      gender = userData.values.first['gender'] ?? '';
      dateOfBirth = userData.values.first['dateOfBirth'] ?? '';
    } catch (e) {
      print('Error fetching user data: $e');
      return;
    }
  }

  void submit() async {
    String password = controller.text;

    bool? isPasswordCorrect =
        await checkPasswordCorrectness(widget.email, password);

    await getUserNamesByEmail(widget.email);

    if (isPasswordCorrect == true) {
      if ('$firstName $lastName' != ' ') {
        // ignore: use_build_context_synchronously
        navigateWithMPR(
          const HomePage(),
          HomePage.routeName,
        );
      } else {
        print('Name not found for email: ${widget.email}');
      }
    } else {
      setState(() {
        passwordInvalid = true;
      });
    }

    addUserData(widget.email, firstName, lastName, gender, dateOfBirth);

    storage.setItem('animation', true);

    clearCache();
  }

  @override
  Widget build(BuildContext context) {
    double logoSize = MediaQuery.of(context).size.width * 0.25;
    double titleFontSize = MediaQuery.of(context).size.width * 0.07;
    double loginFontSize = MediaQuery.of(context).size.width * 0.05;
    double textFieldWidth = MediaQuery.of(context).size.width * 0.5;
    double buttonFontSize = MediaQuery.of(context).size.width * 0.05;
    double buttonPaddingHorizontal = MediaQuery.of(context).size.width * 0.2;
    double buttonPaddingVertical = MediaQuery.of(context).size.height * 0.03;
    double dotSize = MediaQuery.of(context).size.width * 0.03;
    double spacing = MediaQuery.of(context).size.width * 0.01;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.095),
              SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset('assets/images/logo.png'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.065),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.008),
              Opacity(
                opacity: 0.75,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: loginFontSize,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.055),
              SizedBox(
                width: textFieldWidth,
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
                        errorText: passwordInvalid ? passwordError : null,
                        errorStyle: const TextStyle(
                          color: Color(0xFFE91515),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.18),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              GestureDetector(
                onTap: () {
                  navigateWithPRB(
                    const EmailPage(),
                    EmailPage.routeName,
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
                    fontSize: buttonFontSize,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 2; i++)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing),
                        child: Icon(
                          i == 1 ? Icons.circle : Icons.circle,
                          size: dotSize,
                          color: i == 1 ? Colors.red : Colors.grey,
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
