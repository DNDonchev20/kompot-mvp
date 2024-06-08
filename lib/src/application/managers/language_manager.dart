import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_translate/flutter_translate.dart';

import 'package:kompot/network.dart';
import 'package:kompot/lc_manager.dart';

String currentCountry = 'Bulgaria';
String currentLanguage = 'null';

List<String> languageCodes = ['bg', 'en', 'nl'];
List<String> countryCodes = ['bg', 'gb', 'nl'];
List<String> languageNames = ['Български', 'English', 'Nederlands'];

Map<String, String> languageMap = {
  'Bulgaria': 'bg',
  'Netherlands': 'nl',
};

Future<String> getCountry() async {
  Network n = Network("http://ip-api.com/json");

  var locationSTR = (await n.getData());
  var locationx = jsonDecode(locationSTR);

  return locationx["country"];
}

String getCodeForCountryName(String countryName) {
  if (languageMap.containsKey(countryName)) {
    return languageMap[countryName]!;
  } else {
    return 'en';
  }
}

Future<void> changeLanguage(BuildContext context, String languageCode) async {
  currentLanguage = languageCode;

  setLanguage(languageCode);

  await changeLocale(context, languageCode);
}
