import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:translit/translit.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';

import 'package:kompot/routes.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/pages/server/user.router.dart';

import 'package:kompot/pages/home_page.dart';
import 'package:kompot/pages/auth/password_page.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NamePage extends StatefulWidget {
  const NamePage({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  static const routeName = '/name_page';

  final String email;
  final String password;

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  String title = translate('name_page.title');
  String fieldTitleOne = translate('name_page.field_title_one');
  String fieldTitleTwo = translate('name_page.field_title_two');
  String fieldTitleThree = translate('name_page.field_title_three');
  String nextButton = translate('name_page.next_button');
  String beforeButton = translate('name_page.before_button');
  String nameError = translate('name_page.name_error');
  String lNameError = translate('name_page.last_name_error');
  String yearError = translate('name_page.year_error');
  String maleButton = translate('name_page.male_button');
  String femaleButton = translate('name_page.female_button');

  List<String> illegalWordsCyrillic = [];
  List<String> illegalWordsLatin = [];

  bool firstNameError = false;
  bool lastNameError = false;

  bool isMaleSelected = true;

  bool dateOfBirthError = false;

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    dateOfBirthController.addListener(_formatDateOfBirth);
  }

  @override
  void dispose() {
    super.dispose();

    dateOfBirthController.removeListener(_formatDateOfBirth);

    firstNameController.dispose();
    lastNameController.dispose();
    dateOfBirthController.dispose();
  }

  void submit() async {
    await loadData();

    String email = widget.email;
    String password = widget.password;

    String firstName = firstNameController.text.toLowerCase();
    String lastName = lastNameController.text.toLowerCase();

    firstName = firstName[0].toUpperCase() + firstName.substring(1);
    lastName = lastName[0].toUpperCase() + lastName.substring(1);

    String dateOfBirth = dateOfBirthController.text;
    String gender = isMaleSelected ? 'Male' : 'Female';

    bool isValid = true;

    if (firstName.isEmpty ||
        (!isValidName(firstName) || hasIllegalWords(firstName))) {
      setState(() {
        firstNameError = true;
      });

      print('$firstName is empty or invalid');

      isValid = false;
    } else {
      setState(() {
        firstNameError = false;
      });
    }

    if (lastName.isEmpty || !isValidName(lastName)) {
      setState(() {
        lastNameError = true;
      });

      isValid = false;
    } else {
      setState(() {
        lastNameError = false;
      });
    }

    if (dateOfBirth.isEmpty || !isValidDate(dateOfBirth)) {
      setState(() {
        dateOfBirthError = true;
      });

      isValid = false;
    } else {
      setState(() {
        dateOfBirthError = false;
      });
    }

    if (isValid) {
      await isStorageReady();

      addUserData(email, firstName, lastName, gender, dateOfBirth);

      signUpWithEmailAndPassword(
          email, password, firstName, lastName, dateOfBirth, gender);

      // ignore: use_build_context_synchronously

      navigateWithPRB(
        const HomePage(),
        HomePage.routeName,
        300,
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
        true,
      );

      storage.setItem('animation', true);

      clearCache();
    }
  }

  bool isValidDate(String date) {
    RegExp dateRegex =
        RegExp(r"^(0[1-9]|[1-2][0-9]|3[0-1])/(0[1-9]|1[0-2])/(\d{4})$");
    if (!dateRegex.hasMatch(date)) {
      return false;
    }

    List<String> dateParts = date.split('/');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);

    if (day < 1 || day > 31 || month < 1 || month > 12) {
      return false;
    }

    if (year < 1900 || year > DateTime.now().year || year > 2013) {
      return false;
    }

    return true;
  }

  bool isValidName(String name) {
    RegExp nameRegex = RegExp(r"^[\p{L}\s]+$", unicode: true);

    if (!nameRegex.hasMatch(name)) {
      return false;
    }

    if (name.contains(' ')) {
      return false;
    }

    return true;
  }

  bool hasIllegalWords(String name) {
    String nameLatin = Translit().toTranslit(source: name);

    for (int i = 0; i < illegalWordsCyrillic.length; i++) {
      if (name.toLowerCase().contains(illegalWordsCyrillic[i]) ||
          nameLatin.toLowerCase().contains(illegalWordsLatin[i])) {
        return true;
      }
    }

    return false;
  }

  void _formatDateOfBirth() {
    String input = dateOfBirthController.text;
    String formattedDate = '';

    if (input.isNotEmpty) {
      String digitsOnly = input.replaceAll(RegExp(r'[^\d]'), '');

      if (digitsOnly.length >= 3) {
        formattedDate += '${digitsOnly.substring(0, 2)}/';

        if (digitsOnly.length >= 5) {
          formattedDate += '${digitsOnly.substring(2, 4)}/';

          if (digitsOnly.length >= 9) {
            formattedDate += digitsOnly.substring(4, 8);
          } else {
            formattedDate += digitsOnly.substring(4);
          }
        } else {
          formattedDate += digitsOnly.substring(2);
        }
      } else {
        formattedDate = digitsOnly;
      }
    }

    dateOfBirthController.value = dateOfBirthController.value.copyWith(
      text: formattedDate,
      selection: TextSelection.fromPosition(
        TextPosition(offset: formattedDate.length),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await DatePicker.showSimpleDatePicker(
      context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      dateFormat: "dd-MM-yyyy",
      locale: DateTimePickerLocale.th,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateOfBirthController.text =
            DateFormat('dd/MM/yyyy').format(selectedDate!);
      });
    }
  }

  Future<void> loadData() async {
    var data = await rootBundle.loadString("assets/data/illegal.json");

    setState(() {
      for (var word in jsonDecode(data)) {
        illegalWordsCyrillic.add(word.toString());
      }

      for (var word in illegalWordsCyrillic) {
        illegalWordsLatin.add(Translit().toTranslit(source: word));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double availableWidth = constraints.maxWidth;
              double containerWidth = availableWidth * 0.9;
              double imageWidth = availableWidth * 0.4;

              return Stack(
                children: [
                  SizedBox(
                    width: containerWidth,
                    child: Column(
                      children: [
                        const SizedBox(height: 45),
                        SizedBox(
                          width: imageWidth,
                          height: imageWidth * 0.5,
                          child: const Image(
                            image: AssetImage('assets/images/logo.png'),
                          ),
                        ),
                        const SizedBox(height: 65),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 55),
                        SizedBox(
                          width: containerWidth * 0.8,
                          child: TextField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              hintText: fieldTitleOne,
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
                              errorText:
                                  firstNameError ? nameError : null,
                              errorStyle: const TextStyle(
                                color: Color(
                                    0xFFE91515), // Red color for error message
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: containerWidth * 0.8,
                          child: TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              hintText: fieldTitleTwo,
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
                              errorText:
                                  lastNameError ? lNameError : null,
                              errorStyle: const TextStyle(
                                color: Color(0xFFE91515),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: containerWidth * 0.8,
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: Stack(
                              children: [
                                AbsorbPointer(
                                  child: TextField(
                                    controller: dateOfBirthController,
                                    decoration: InputDecoration(
                                      hintText: fieldTitleThree,
                                      isCollapsed: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 1.0,
                                        vertical: 5.0,
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 2.0),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 2.0),
                                      ),
                                      errorText: dateOfBirthError
                                          ? yearError
                                          : null,
                                      errorStyle: const TextStyle(
                                        color: Color(0xFFE91515),
                                      ),
                                    ),
                                    keyboardType: TextInputType.datetime,
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  top: -20,
                                  bottom: 0,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Transform.translate(
                                      offset: const Offset(0, 10),
                                      child: const SizedBox(
                                        width: 30,
                                        child: Icon(Icons.calendar_today),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isMaleSelected = true;
                                });
                              },
                              child: Container(
                                width: 78,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: isMaleSelected
                                      ? Colors.black
                                      : const Color(0xFFF5F5F5),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    maleButton,
                                    style: TextStyle(
                                      color: isMaleSelected
                                          ? const Color(0xFFF5F5F5)
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isMaleSelected = false;
                                });
                              },
                              child: Container(
                                width: 78,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: isMaleSelected
                                      ? const Color(0xFFF5F5F5)
                                      : Colors.black,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    femaleButton,
                                    style: TextStyle(
                                      color: isMaleSelected
                                          ? Colors.black
                                          : const Color(0xFFF5F5F5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),
                        ElevatedButton(
                          onPressed: submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: const Color(0xFFEA4934),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            nextButton,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            navigateWithPRB(
                              PasswordPage(email: widget.email),
                              PasswordPage.routeName,
                              850,
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(-1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                final tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 1,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildDots(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    int maxSteps = 3;
    double dotSize = 8.0;
    double spacing = 3.0;

    Color activeColor = Colors.red;
    Color inactiveColor = Colors.grey;

    List<Widget> dots = [];

    for (int i = 1; i <= maxSteps; i++) {
      dots.add(
        Container(
          width: dotSize,
          height: dotSize,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == 3 ? activeColor : inactiveColor,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }
}
