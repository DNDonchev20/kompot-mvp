import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:kompot/utils.dart';
import 'package:kompot/lc_manager.dart';
import 'package:kompot/database_manager.dart';

final email = getItem('email') ?? '';
final firstName = getItem('firstName') ?? '';
final lastName = getItem('lastName') ?? '';

final gender = getItem('gender') ?? '';
final dateOfBirth = getItem('dateOfBirth') ?? '';

final age = getAge(dateOfBirth);

Future<void> createReview(String titleName, List<double> ratings) async {
  final review = {
    'email': email,
    'name': '$firstName $lastName',
    'gender': gender,
    'age': age,
    'titleInfo': titleName,
    'date': DateFormat('dd/MM/yyyy').format(DateTime.now()),
    'review': {
      'food': ratings[0],
      'service': ratings[1],
      'atmosphere': ratings[2],
    },
  };

  await createOrUpdateTotalReviews(titleName, review);
  await createOrUpdateUserTotalReviews(review);

  print('INFO: Created new review for $titleName');
}

Future<void> createOrUpdateTotalReviews(
    String titleName, dynamic review) async {
  final DatabaseEvent event =
      await databaseReference.child('totalReviews').once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? totalReviewsData =
      snapshot.value as Map<dynamic, dynamic>?;

  totalReviewsData ??= {};

  if (totalReviewsData.containsKey(titleName)) {
    int currentCount = totalReviewsData[titleName]['count'];

    totalReviewsData[titleName]['count'] = currentCount + 1;
  } else {
    totalReviewsData[titleName] = {
      'titleInfo': titleName,
      'count': 1,
      'reviews': List.empty(growable: true),
    };
  }

  totalReviewsData[titleName]['reviews'] = [
    ...totalReviewsData[titleName]['reviews'],
    review,
  ];

  await databaseReference.child('totalReviews').set(totalReviewsData);
}

Future<void> createOrUpdateUserTotalReviews(dynamic review) async {
  final DatabaseEvent event =
      await databaseReference.child('userTotalReviews').once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? userTotalReviewsData =
      snapshot.value as Map<dynamic, dynamic>?;

  userTotalReviewsData ??= {};

  String encodedEmail = email.hashCode.toString();

  if (userTotalReviewsData.containsKey(encodedEmail)) {
    int currentCount = userTotalReviewsData[encodedEmail]['count'];

    userTotalReviewsData[encodedEmail]['count'] = currentCount + 1;
  } else {
    userTotalReviewsData[encodedEmail] = {
      'email': email,
      'count': 1,
      'reviews': List.empty(growable: true),
    };
  }

  userTotalReviewsData[encodedEmail]['reviews'] = [
    ...userTotalReviewsData[encodedEmail]['reviews'],
    review,
  ];

  await databaseReference.child('userTotalReviews').set(userTotalReviewsData);
}
