import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:kompot/lc_manager.dart';
import 'package:kompot/reward_manager.dart';
import 'package:kompot/database_manager.dart';
import 'package:kompot/developer_manager.dart';

import 'package:intl/date_symbol_data_local.dart';

final email = getItem('email') ?? '';

String getStampKey(String titleInfo) {
  final emailWithoutInvalidChars = email.replaceAll('.', '-');
  final titleInfoWithoutInvalidChars = titleInfo.replaceAll(' ', '-');

  return '${emailWithoutInvalidChars}_$titleInfoWithoutInvalidChars';
}

Future<int> getStampCount(String titleInfo) async {
  final stampKey = getStampKey(titleInfo);
  final stampsReference = databaseReference.child('stamps');

  try {
    DatabaseEvent event = await stampsReference.once();
    DataSnapshot snapshot = event.snapshot;

    if (!snapshot.exists) {
      await stampsReference.set({});

      return 0;
    } else {
      DatabaseEvent stampEvent = await stampsReference.child(stampKey).once();
      DataSnapshot stampSnapshot = stampEvent.snapshot;
      dynamic stampData = stampSnapshot.value;

      if (stampData != null && stampData is Map<dynamic, dynamic>) {
        int stampCount = stampData['stampCount'] as int? ?? 0;

        return stampCount;
      }
    }
  } catch (error) {
    print('ERROR: Error getting stamp count: $error');
  }

  return 0;
}

Future<bool> getCanGetStamp(String titleInfo) async {
  final stampKey = getStampKey(titleInfo);
  final stampsReference = databaseReference.child('stamps');

  final cardCooldown = getCard(titleInfo)['cooldown'] as int? ?? 0;

  try {
    DatabaseEvent event = await stampsReference.once();
    DataSnapshot snapshot = event.snapshot;

    if (!snapshot.exists) {
      await stampsReference.set({});

      return true;
    } else {
      DatabaseEvent stampEvent = await stampsReference.child(stampKey).once();
      DataSnapshot stampSnapshot = stampEvent.snapshot;
      dynamic stampData = stampSnapshot.value;

      if (stampData != null && stampData is Map<dynamic, dynamic>) {
        String lastStamp = stampData['lastStamp'] as String? ?? '';

        if (lastStamp != '') {
          DateTime lastStampDate =
              DateFormat('yyyy-MM-dd-HH-mm').parse(lastStamp);
          DateTime now = DateTime.now();

          Duration difference = now.difference(lastStampDate);

          int differenceInSeconds = difference.inSeconds;

          int timeLeft = cardCooldown * 3600 - differenceInSeconds;

          print(
              'INFO: Time left: ${timeLeft ~/ 3600}:${(timeLeft % 3600) ~/ 60}:${timeLeft % 60}');

          if (timeLeft <= 0) {
            return true;
          } else if (lastStampDate.day != now.day) {
            return true;
          } else {
            return false;
          }
        } else {
          return true;
        }
      } else {
        return true;
      }
    }
  } catch (error) {
    print('Error checking/storing stamp data: $error');
  }

  return false;
}

Future<void> createOrUpdateTotalStamps(String titleName) async {
  final DatabaseEvent event =
      await databaseReference.child('totalStamps').once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? totalStampsData =
      snapshot.value as Map<dynamic, dynamic>?;

  totalStampsData ??= {};

  if (totalStampsData.containsKey(titleName)) {
    int currentCount = totalStampsData[titleName]['count'];
    totalStampsData[titleName]['count'] = currentCount + 1;
  } else {
    totalStampsData[titleName] = {'titleInfo': titleName, 'count': 1};
  }

  await databaseReference.child('totalStamps').set(totalStampsData);
}

Future<void> createOrUpdateUserTotalStamps() async {
  final DatabaseEvent event =
      await databaseReference.child('userTotalStamps').once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? userTotalStampsData =
      snapshot.value as Map<dynamic, dynamic>?;

  userTotalStampsData ??= {};

  String encodedEmail = email.hashCode.toString();

  if (userTotalStampsData.containsKey(encodedEmail)) {
    int currentCount = userTotalStampsData[encodedEmail]['count'];
    userTotalStampsData[encodedEmail]['count'] = currentCount + 1;
  } else {
    userTotalStampsData[encodedEmail] = {'email': email, 'count': 1};
  }

  await databaseReference.child('userTotalStamps').set(userTotalStampsData);
}

Future<void> handleStamp(String titleInfo) async {
  initializeDateFormatting('en_US', null);

  final stampKey = getStampKey(titleInfo);
  final stampsReference = databaseReference.child('stamps');

  try {
    DatabaseEvent event = await stampsReference.once();
    DataSnapshot snapshot = event.snapshot;

    if (!snapshot.exists) {
      await stampsReference.set({});

      updateStamp(titleInfo, stampKey);
    } else {
      DatabaseEvent stampEvent = await stampsReference.child(stampKey).once();
      DataSnapshot stampSnapshot = stampEvent.snapshot;
      dynamic stampData = stampSnapshot.value;

      if (stampData != null && stampData is Map<dynamic, dynamic>) {
        int stampCount = stampData['stampCount'] as int? ?? 0;

        updateStamp(titleInfo, stampKey, stampCount);
      } else {
        updateStamp(titleInfo, stampKey);
      }
    }
  } catch (error) {
    print('ERROR: Error checking/storing stamp data: $error');
  }

  if (await isAccountDeveloper()) {
    return;
  }

  createOrUpdateTotalStamps(titleInfo);
  createOrUpdateUserTotalStamps();
}

void updateStamp(String titleInfo, String stampKey, [int stampCount = 0]) {
  Map<String, dynamic> cardData = getCard(titleInfo);

  int circleNumber = int.tryParse(cardData['circleNumber'] ?? '') ?? 0;

  if (stampCount == circleNumber - 1) {
    stampCount = 0;

    createReward(titleInfo);
  } else {
    stampCount++;
  }

  Map<String, dynamic> stampData = {
    'email': email,
    'titleInfo': titleInfo,
    'stampCount': stampCount,
    'lastStamp': DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now()),
  };

  databaseReference.child('stamps').child(stampKey).set(stampData).then((_) {
    print('INFO: Successfully updated stamp: $stampData');
  }).catchError((error) {
    print('ERRROR: Error updating stamp: $error');
  });
}
