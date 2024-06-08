String currentCard = '';
String currentCardData = '';
List<String> currentCardIdentifiers = [];

bool showReview = false;

void setCard(String title, List<dynamic> identifiers, [String? date]) {
  currentCard = title;

  currentCardIdentifiers.clear();

  for (var id in identifiers) {
    currentCardIdentifiers.add(id);
  }

  if (date != null) {
    currentCardData = date;
  }
}

String getCurrentCard() {
  return currentCard;
}

List<String> getCardIdentifiers() {
  return currentCardIdentifiers;
}

String getCardData() {
  return currentCardData;
}
