import 'dart:convert';

import 'package:localstorage/localstorage.dart';

import 'package:kompot/card_manager.dart';

final LocalStorage storage = LocalStorage('kompot_storage.json');

void addCardToStorage(String title, dynamic content) {
  final info = json.encode(content);

  storage.setItem(title, info);

  addCardToList(title);
}

void removeCard(String title) {
  storage.deleteItem(title);

  removeCardFromList(title);
}

void updateCard(String title, dynamic content) {
  final info = json.encode(content);

  storage.setItem(title, info);
}

Map<String, dynamic> getCard(String title) {
  final info = storage.getItem(title);

  return json.decode(info);
}

void addCardToList(String title) {
  final info = storage.getItem('cards');

  if (info == null) {
    storage.setItem('cards', json.encode([title]));
    return;
  }

  final cards = json.decode(info);

  cards.add(title);

  storage.setItem('cards', json.encode(cards));
}

void removeCardFromList(String title) {
  final info = storage.getItem('cards');
  final cards = json.decode(info);

  cards.remove(title);

  storage.setItem('cards', json.encode(cards));
}

List<String> getCardsList() {
  final info = storage.getItem('cards');

  if (info == null) {
    return [];
  }

  final cards = json.decode(info);

  return List<String>.from(cards);
}

void moveCardToStart(String title) {
  removeCardFromList(title);

  final cards = getCardsList();

  cards.insert(0, title);

  storage.setItem('cards', json.encode(cards));
}

void addUserData(String email, String firstName, String lastName, String gender,
    String dateOfBirth) {
  storage.setItem('email', email);

  storage.setItem('firstName', firstName);
  storage.setItem('lastName', lastName);

  storage.setItem('gender', gender);
  storage.setItem('dateOfBirth', dateOfBirth);
}

void setLanguage(String language) {
  storage.setItem('language', language);
}

String getLanguage() {
  return storage.getItem('language') ?? 'None';
}

dynamic getItem(String key) {
  return storage.getItem(key);
}

Future<void> reloadStorage() async {
  var cards = getCardsList();

  for (var card in cards) {
    storage.deleteItem(card);

    await saveCard(card);
  }
}

void clearCards() {
  final cards = getCardsList();

  for (var card in cards) {
    storage.deleteItem(card);
  }

  storage.deleteItem('cards');
}

Future<bool> isStorageReady() {
  return storage.ready;
}

void clearStorage() {
  storage.clear();
}
