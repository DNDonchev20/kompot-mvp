import 'package:flutter/material.dart';

import 'package:kompot/routes.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                navigatePop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.white.withOpacity(0),
                padding: const EdgeInsets.all(0),
              ),
              child: const SizedBox(
                width: 32,
                child: Image(
                  alignment: Alignment.centerLeft,
                  image: AssetImage('assets/icons/back.png'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                navigatePop();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.white.withOpacity(0),
                padding: const EdgeInsets.all(0),
              ),
              child: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: SizedBox(
                  width: 172,
                  height: 54,
                  child: Image(
                    image: AssetImage('assets/images/kompot.png'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
