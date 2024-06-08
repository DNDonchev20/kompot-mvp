import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:kompot/lc_manager.dart';
import 'package:kompot/database_manager.dart';

final email = getItem('email') ?? '';

Future<void> createOrUpdateTotalRewards(String titleName) async {
  final DatabaseEvent event =
      await databaseReference.child('totalRewards').once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? totalRewardsData =
      snapshot.value as Map<dynamic, dynamic>?;

  totalRewardsData ??= {};

  if (totalRewardsData.containsKey(titleName)) {
    int currentCount = totalRewardsData[titleName]['count'];
    totalRewardsData[titleName]['count'] = currentCount + 1;
  } else {
    totalRewardsData[titleName] = {'titleInfo': titleName, 'count': 1};
  }

  await databaseReference.child('totalRewards').set(totalRewardsData);
}

Future<void> createOrUpdateUserTotalRewards() async {
  final DatabaseEvent event =
      await databaseReference.child('userTotalRewards').once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? userTotalRewardsData =
      snapshot.value as Map<dynamic, dynamic>?;

  userTotalRewardsData ??= {};

  String encodedEmail = email.hashCode.toString();

  if (userTotalRewardsData.containsKey(encodedEmail)) {
    int currentCount = userTotalRewardsData[encodedEmail]['count'];
    userTotalRewardsData[encodedEmail]['count'] = currentCount + 1;
  } else {
    userTotalRewardsData[encodedEmail] = {'email': email, 'count': 1};
  }

  await databaseReference.child('userTotalRewards').set(userTotalRewardsData);
}

void createReward(String titleInfo) async {
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Map<String, dynamic> rewardData = {
    'email': email,
    'titleInfo': titleInfo,
    'date': currentDate,
  };

  databaseReference.child('rewards').push().set(rewardData).then((_) {
    print('Reward data pushed successfully: $rewardData');
  }).catchError((error) {
    print('Error pushing reward data: $error');
  });

  createOrUpdateTotalRewards(titleInfo);
  createOrUpdateUserTotalRewards();
}

Future<void> deleteReward(String titleInfo, String date) async {
  try {
    final claimedRewardsDataReference =
        databaseReference.child('rewards').orderByChild('email').equalTo(email);

    final claimedRewardsDataSnapshot = await claimedRewardsDataReference.once();

    final claimedRewardsData = claimedRewardsDataSnapshot.snapshot.value;

    if (claimedRewardsData == null) {
      print('No claimed rewards data found for email: $email');
      return;
    }
    if (claimedRewardsData is Map<dynamic, dynamic>) {
      final claimedRewardsDataKeys = claimedRewardsData.keys;
      final claimedRewardsDataValues = claimedRewardsData.values;

      final claimedRewardsDataKeysList = claimedRewardsDataKeys.toList();

      for (int i = 0; i < claimedRewardsDataKeysList.length; i++) {
        final key = claimedRewardsDataKeysList[i];
        final value = claimedRewardsDataValues.elementAt(i);

        if (value['titleInfo'] == titleInfo && value['date'] == date) {
          databaseReference.child('rewards').child(key).remove();

          print('Reward deleted successfully!');
          break;
        }
      }
    }
  } catch (error) {
    print('Error deleting reward data: $error');
  }
}

int getDaysLeft(String date, [int daysToClaim = 30]) {
  final creationDate = DateTime.parse(date);
  final currentDate = DateTime.now();

  final daysLeft = daysToClaim - currentDate.difference(creationDate).inDays;

  return daysLeft;
}

bool isRewardValid(String date) {
  final daysLeft = getDaysLeft(date);

  return daysLeft > 0;
}
