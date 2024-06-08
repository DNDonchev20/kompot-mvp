import 'package:flutter/material.dart';

import 'package:kompot/reward_manager.dart';

class RewardItem extends StatelessWidget {
  const RewardItem({
    Key? key,
    required this.titleInfo,
    required this.textReward,
    required this.date,
    required this.logo,
    required this.stamp,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  final String titleInfo;
  final String textReward;
  final String date;
  final String logo;
  final String stamp;
  final String backgroundColor;
  final String textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 55,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 0.3),
            ),
            child: CircleAvatar(
              radius: 23,
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
              child: ClipOval(
                child: Image.network(
                  logo,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return const Icon(Icons.error);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Center(
              child: Text(
                textReward,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      getDaysLeft(date).toString(),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Days Left',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
