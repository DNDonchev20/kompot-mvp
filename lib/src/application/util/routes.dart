import 'package:flutter/material.dart';

import 'package:kompot/nfc_data.dart';

import 'pages/start_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/menu_page.dart';
import 'pages/category_page.dart';
import 'pages/card_page.dart';
import 'pages/rewards_list_page.dart';
import 'pages/reward_page.dart';

import 'pages/auth/email_page.dart';
import 'pages/auth/password_page.dart';
import 'pages/auth/name_page.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

String initialRoute = StartPage.routeName;
String currentRoute = initialRoute;

var routes = <String, WidgetBuilder>{
  StartPage.routeName: (context) => const StartPage(),
  EmailPage.routeName: (context) => const EmailPage(),
  PasswordPage.routeName: (context) => const PasswordPage(email: ''),
  NamePage.routeName: (context) => const NamePage(email: '', password: ''),
  HomePage.routeName: (context) => const HomePage(),
  MenuPage.routeName: (context) => const MenuPage(),
  CategoryPage.routeName: (context) => CategoryPage(
        title: ModalRoute.of(context)!.settings.arguments as String,
        cards: ModalRoute.of(context)!.settings.arguments as List<dynamic>,
      ),
  SettingsPage.routeName: (context) => const SettingsPage(),
  CardPage.routeName: (context) => CardPage(
        cardData:
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
        rotations: ModalRoute.of(context)!.settings.arguments as List<double>,
        offsets: ModalRoute.of(context)!.settings.arguments as List<Offset>,
      ),
  RewardsListPage.routeName: (context) => const RewardsListPage(),
  RewardPage.routeName: (context) => RewardPage(
        logo: ModalRoute.of(context)!.settings.arguments as String,
        stamp: ModalRoute.of(context)!.settings.arguments as String,
        textReward: ModalRoute.of(context)!.settings.arguments as String,
      ),
};

void navigateTo(dynamic page, [bool animated = false]) {
  if (animated == false) {
    navigatorKey.currentState!.push(page);
  } else {
    navigatorKey.currentState!.pushReplacement(page);
  }
}

void navigateWithMPR(Widget page, String routeName, [bool animated = false]) {
  navigateTo(
    MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (context) => page,
    ),
    animated,
  );
}

void navigateWithPRB(
    Widget page, String routeName, int duration, dynamic transitionBuilder,
    [bool animated = false]) {
  navigateTo(
    PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      transitionDuration: Duration(milliseconds: duration),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: transitionBuilder,
    ),
    animated,
  );
}

void navigateWithCallback(Widget page, String routeName, Function callback) {
  navigatorKey.currentState!
      .push(MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (context) => page,
      ))
      .then((_) => callback());
}

void navigatePop() {
  showReview = false;
  navigatorKey.currentState!.pop();
}

void clearCache() {
  navigatorKey.currentState!.pushNamedAndRemoveUntil(
    getCurrentRoute(),
    (r) => false,
  );
}

String getCurrentRoute() {
  navigatorKey.currentState?.popUntil((route) {
    currentRoute = route.settings.name ?? '';
    return true;
  });

  return currentRoute;
}
