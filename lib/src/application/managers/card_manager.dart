import 'package:firebase_database/firebase_database.dart';

import 'package:kompot/lc_manager.dart';
import 'package:kompot/stamp_manager.dart';
import 'package:kompot/language_manager.dart';
import 'package:kompot/database_manager.dart';

Future<dynamic> fetchCard(String title) async {
  DatabaseReference cardsRef = databaseReference.child('cards');

  if (currentLanguage == 'bg') {
    cardsRef = databaseReference.child('cards');
  } else if (currentLanguage == 'en') {
    cardsRef = databaseReference.child('cardsBgEn');
  } else if (currentLanguage == 'nl') {
    //trqq se smeni kat imame karti na niderlanski
    //sa go ostavqm shot she dava init error na ref dolu
    cardsRef = databaseReference.child('cardsBgEn');
  } else {
    cardsRef = databaseReference.child('cardsBgEn');
  }

  try {
    DatabaseEvent databaseEvent = await cardsRef.once();
    DataSnapshot dataSnapshot = databaseEvent.snapshot;

    if (dataSnapshot.value != null &&
        dataSnapshot.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> data = dataSnapshot.value as Map<dynamic, dynamic>;

      var filteredData = data.values.firstWhere(
        (entry) => entry['titleInfo'] == title,
        orElse: () => null,
      );

      if (filteredData != null) {
        return filteredData;
      } else {
        print("Entry with title '$title' not found.");
      }
    } else {
      print("Data is null or not in the correct format.");
    }
  } catch (error) {
    print("Error fetching data: $error");
  }
}

Future<void> saveCard(String title) async {
  dynamic cardData = await fetchCard(title);

  int stampCount = await getStampCount(title);

  cardData['stampCount'] = stampCount;
  cardData['showReview'] = false;

  addCardToStorage(title, cardData);

  moveCardToStart(title);
}

void updateShowReview(String title, bool showReview) {
  dynamic cardData = getCard(title);

  cardData['showReview'] = showReview;

  updateCard(title, cardData);
}
