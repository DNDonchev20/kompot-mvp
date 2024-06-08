import 'package:flutter/material.dart';

import 'dart:math' as math;
import 'dart:io';

import 'package:nfc_manager/nfc_manager.dart';

import 'package:kompot/routes.dart';
import 'package:kompot/nfc_data.dart';
import 'package:kompot/stamp_manager.dart';
import 'package:kompot/reward_manager.dart';
import 'package:kompot/identifier_manager.dart';

class NFCReader extends ChangeNotifier {
  static final NFCReader _nfcreader = NFCReader._internal();

  factory NFCReader() {
    return _nfcreader;
  }

  NFCReader._internal();

  int delay = 1;
  bool canCallUpdate = true;

  bool shouldUpdateCard = false;
  bool shouldUpdateReward = false;

  bool cardIsUpdated = false;
  bool homeIsUpdated = false;

  Future<void> initState() async {
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        update(tag);
      },
    );
  }

  void update(NfcTag tag) {
    if (!canCallUpdate) {
      return;
    }

    String tagIdentifier = getTagIdentifier(tag);

    if (getCurrentRoute() == '/card_page') {
      handleCardScan(tagIdentifier);
    } else if (getCurrentRoute() == '/reward_page') {
      handleRewardScan(tagIdentifier);
    }

    if(Platform.isIOS){
      NfcManager.instance.stopSession();
    }
  
    canCallUpdate = false;

    Future.delayed(Duration(seconds: delay), () {
      canCallUpdate = true;
    });
  }

  void handleCardScan(String tagIdentifier) async {
    String titleInfo = getCurrentCard();
    List<String> cardIdentifiers = getCardIdentifiers();

    if (!(await isTagMaster(tagIdentifier))) {
      if (!isTagValid(tagIdentifier, cardIdentifiers)) {
        print("ERROR: Couldn't get stamp. Tag is not valid");
        return;
      }

      if (!(await getCanGetStamp(titleInfo))) {
        print("ERROR: Couldn't get stamp. Stamp is in timeout");
        return;
      }
    }

    await handleStamp(titleInfo);

    shouldUpdateCard = true;

    var boolValue = math.Random().nextBool();

    if (boolValue) {
      showReview = true;
    } else {
      showReview = false;
    }

    notifyListeners();

    print("INFO: Scanned card with title info: $titleInfo");
  }

  void handleRewardScan(String tagIdentifier) async {
    String titleInfo = getCurrentCard();
    List<String> cardIdentifiers = getCardIdentifiers();
    String date = getCardData();

    if (!(await isTagMaster(tagIdentifier))) {
      if (!isTagValid(tagIdentifier, cardIdentifiers)) {
        return;
      }
    }

    deleteReward(titleInfo, date);

    shouldUpdateReward = true;

    notifyListeners();

    print("INFO: Scanned reward with title info: $titleInfo");
  }
}
