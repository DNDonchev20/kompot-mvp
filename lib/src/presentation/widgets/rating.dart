import 'package:flutter/material.dart';

import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// ignore: must_be_immutable
class Rating extends StatelessWidget {
  Rating({
    Key? key,
    required this.question,
  }) : super(key: key);

  final String question;

  double rating = 3;

  double getRating() {
    return rating;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'VarelaRound',
            ),
          ),
          const SizedBox(height: 10),
          RatingBar.builder(
            initialRating: 3,
            itemCount: 5,
            unratedColor: Colors.grey[300],
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.red,
                  );
                case 1:
                  return const Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.redAccent,
                  );
                case 2:
                  return const Icon(
                    Icons.sentiment_neutral,
                    color: Colors.amber,
                  );
                case 3:
                  return const Icon(
                    Icons.sentiment_satisfied,
                    color: Colors.lightGreen,
                  );
                case 4:
                  return const Icon(
                    Icons.sentiment_very_satisfied,
                    color: Colors.green,
                  );
              }

              return const Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
              );
            },
            onRatingUpdate: (rating) {
              this.rating = rating;
            },
          ),
        ],
      ),
    );
  }
}
