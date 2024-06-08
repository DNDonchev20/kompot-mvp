import 'dart:io';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:kompot/database_manager.dart';

List<String> masterCardIdentifiers = [];

Future<void> getMasterIdentifiers() async {
  final masterReference = databaseReference.child('master');

  try {
    DatabaseEvent event = await masterReference.once();
    DataSnapshot snapshot = event.snapshot;

    if (!snapshot.exists) {
      await masterReference.set({});

      masterReference.child('identifiers').set(['']);
    } else {
      DatabaseEvent masterEvent =
          await masterReference.child('identifiers').once();
      DataSnapshot masterSnapshot = masterEvent.snapshot;
      dynamic masterData = masterSnapshot.value;

      if (masterData != null && masterData is List<dynamic>) {
        for (var i = 0; i < masterData.length; i++) {
          masterCardIdentifiers.add(masterData[i].toString());
        }
      }
    }
  } catch (error) {
    print('Error getting master card identifiers: $error');
  }
}

String getTagIdentifier(NfcTag tag) {
  dynamic rawIdentifier = 'NFC chip not recognized';

  if (Platform.isAndroid) {
    rawIdentifier = tag.data['nfca']['identifier'] ?? '';
  } else if (Platform.isIOS) {
    rawIdentifier = tag.data['mifare']['identifier'] ?? '';
  }

  String identifier = rawIdentifier[0].toString();

  for (var i = 1; i < rawIdentifier.length; i++) {
    identifier += ',${rawIdentifier[i].toString()}';
  }

  return identifier;
}

Future<bool> isTagMaster(String tagIdentifier) async {
  if (masterCardIdentifiers.isEmpty) {
    await getMasterIdentifiers();
  }

  return masterCardIdentifiers.contains(tagIdentifier);
}

bool isTagValid(String tagIdentifier, List<String> cardIdentifier) {
  return cardIdentifier.contains(tagIdentifier);
}
