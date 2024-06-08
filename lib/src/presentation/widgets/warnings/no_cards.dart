import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NoCards extends StatelessWidget {
  NoCards({Key? key}) : super(key: key);

  final String title = translate('no_cards_warning.title');

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 55.0),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontFamily: 'VarelaRound',
            color: Color(0x80000000),
          ),
        ),
      ),
    );
  }
}
