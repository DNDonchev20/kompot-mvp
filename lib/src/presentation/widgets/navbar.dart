import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home), // Replace with your home icon
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add), // Replace with your add icon
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard), // Replace with your rewards icon
          label: 'Rewards',
        ),
      ],
    );
  }
}
