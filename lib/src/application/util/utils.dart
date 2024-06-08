import 'package:flutter/material.dart';

Color parseColor(String colorString) {
  if (colorString.startsWith('#')) {
    colorString = colorString.substring(1);
  }

  return Color(int.parse(colorString, radix: 16)).withOpacity(1.0);
}

double mapRange(double number, double inputStart, double inputEnd,
    double outputStart, double outputEnd) {
  double inputPercentage = (number - inputStart) / (inputEnd - inputStart);

  double outputNumber =
      outputStart + (inputPercentage * (outputEnd - outputStart));

  return outputNumber;
}

int getAge(String dateOfBirth) {
  List<int> dateParts = dateOfBirth.split('/').map(int.parse).toList();

  DateTime inputDateTime = DateTime(dateParts[2], dateParts[1], dateParts[0]);
  DateTime currentDate = DateTime.now();

  Duration difference = currentDate.difference(inputDateTime);

  int yearsPassed = difference.inDays ~/ 365;
  return yearsPassed;
}
