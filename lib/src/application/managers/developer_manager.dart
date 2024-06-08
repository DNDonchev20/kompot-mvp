import 'package:firebase_database/firebase_database.dart';

import 'package:kompot/lc_manager.dart';
import 'package:kompot/database_manager.dart';

List<String> developerAccounts = [];

final email = getItem('email') ?? '';

Future<void> getDeveloperAccounts() async {
  final developerReference = databaseReference.child('developers');

  try {
    DatabaseEvent event = await developerReference.once();
    DataSnapshot snapshot = event.snapshot;

    if (!snapshot.exists) {
      await developerReference.set({});

      developerReference.child('accounts').set(['']);
    } else {
      DatabaseEvent developerEvent =
          await developerReference.child('accounts').once();
      DataSnapshot developerSnapshot = developerEvent.snapshot;
      dynamic developerData = developerSnapshot.value;

      if (developerData != null && developerData is List<dynamic>) {
        for (var i = 0; i < developerData.length; i++) {
          developerAccounts.add(developerData[i].toString());
        }
      }
    }
  } catch (error) {
    print('Error getting developer accounts: $error');
  }
}

Future<bool> isAccountDeveloper() async {
  if (developerAccounts.isEmpty) {
    await getDeveloperAccounts();
  }

  return developerAccounts.contains(email);
}
