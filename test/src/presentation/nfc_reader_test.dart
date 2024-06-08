testWidgets('NFC initialization is skipped on iOS', (WidgetTester tester) async {
  Platform.isIOS = true; // Temporarily override the platform
  expect(await nfcReader.initState(), isNull); // Assuming initState returns null or similar on iOS
});

test('NFC tag read validity', () async {
  var tag = NfcTag(data: {'nfca': {'identifier': [0, 1, 2]}});
  var identifier = getTagIdentifier(tag);
  expect(isTagValid(identifier, ['0,1,2']), true);
});
