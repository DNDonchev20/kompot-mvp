import 'package:flutter/material.dart';
import 'package:kompot/pages/card_page.dart';
import 'package:kompot/review_manager.dart';
import 'package:kompot/routes.dart';

import 'package:kompot/utils.dart';

import 'package:kompot/pages/components/rating.dart';
import 'package:flutter_translate/flutter_translate.dart';

String title = translate('review_card_component.title');
String firstSubtitle = translate('review_card_component.first_subtitle');
String secondSubtitle = translate('review_card_component.second_subtitle');
String thirdSubtitle = translate('review_card_component.third_subtitle');

class ReviewCard extends StatefulWidget {
  const ReviewCard({
    Key? key,
    required this.cardData,
  }) : super(key: key);

  final Map<String, dynamic> cardData;

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  List<Rating> ratings = [
    Rating(question: firstSubtitle),
    Rating(question: secondSubtitle),
    Rating(question: thirdSubtitle),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double radius = screenHeight * 0.06;

    final double marginBeforeLogo = mapRange(screenHeight, 600, 900, 0, 60);
    final double marginAfterLogo = mapRange(screenHeight, 600, 900, 0, 40);

    final double marginBeforeRatings = mapRange(screenHeight, 600, 900, 0, 40);

    final double marginBetweenRatings = mapRange(screenHeight, 600, 900, 0, 20);

    final double marginAfterRatings = mapRange(screenHeight, 600, 900, 0, 30);

    return Container(
      width: screenHeight * 0.4,
      height: screenHeight * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: Colors.white,
      ),
      child: Center(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: marginBeforeLogo),
                Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 0.75,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: radius,
                    backgroundImage: NetworkImage(
                      widget.cardData['logo'],
                    ),
                  ),
                ),
                SizedBox(height: marginAfterLogo),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: parseColor(widget.cardData['textColor']),
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: marginBeforeRatings),
                Expanded(
                  child: ListView.builder(
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ratings[index],
                          SizedBox(height: marginBetweenRatings),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: marginAfterRatings),
                GestureDetector(
                  onTap: () {
                    createReview(
                      widget.cardData['titleInfo'],
                      ratings.map((rating) => rating.getRating()).toList(),
                    );

                    Navigator.of(context).pop();
                  },
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                      ),
                      children: [
                        const TextSpan(text: 'Изпрати'),
                        WidgetSpan(
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: Image.asset('assets/icons/arrow.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
