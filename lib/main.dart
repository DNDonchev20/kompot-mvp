import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:kompot/nfc.dart';
import 'package:kompot/routes.dart';

import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting('en_US', null);

  WidgetsFlutterBinding.ensureInitialized();

  var apiKey = (Platform.isAndroid)
      ? 'AIzaSyCzl-eRuodu7QhZCBe-DzYbShqVshWwHn0'
      : 'AIzaSyAo5JE5USw9Lyto1jsy17jAij4UVRyuoDE';

  var appId = (Platform.isAndroid)
      ? '1:745257287690:android:b4e48f92f72ce0eb7f1ff3'
      : '1:745257287690:ios:7f56c700230195897f1ff3';

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: '745257287690',
      projectId: 'kompot-13c90',
      databaseURL:
          'https://kompot-13c90-default-rtdb.europe-west1.firebasedatabase.app/',
    ),
  );

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_US',
    supportedLocales: ['en_US', 'bg_BG', 'nl_NL'],
  );

  NFCReader nfcReader = NFCReader();

  if (Platform.isAndroid) {
    await nfcReader.initState();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => nfcReader,
        ),
      ],
      child: LocalizedApp(
        delegate,
        MaterialApp(
          title: 'Kompot',
          navigatorKey: navigatorKey,
          initialRoute: initialRoute,
          routes: routes,
        ),
      ),
    ),
  );
}

class Kompot extends StatelessWidget {
  const Kompot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Kompot',
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}
