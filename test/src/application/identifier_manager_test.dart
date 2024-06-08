test('Error in fetching master identifiers is handled', () async {
  final mockDatabaseRef = MockDatabaseReference();
  when(mockDatabaseRef.once()).thenThrow(Exception('Failed to fetch'));
  databaseReference = mockDatabaseRef;

  expect(() => getMasterIdentifiers(), throwsException);
});

test('Validate master tag after list update', () async {
  masterCardIdentifiers = []; // Clear existing identifiers
  await getMasterIdentifiers(); // Load new identifiers
  expect(isTagMaster('master123'), isTrue); // Check if 'master123' is now recognized as master
});

test('Updating master identifier list reflects changes correctly', () async {
  final mockDatabaseRef = MockDatabaseReference();
  when(mockDatabaseRef.once()).thenAnswer((_) async => DatabaseEvent(
      DatabaseEventType.value, DatabaseDataSnapshot({'identifiers': ['master123']})));
  databaseReference = mockDatabaseRef;

  await getMasterIdentifiers();
  expect(masterCardIdentifiers.contains('master123'), isTrue);
});

test('NFC tag identifier extraction for iOS', () {
  Platform.isIOS = true; // Set the platform to iOS for this test
  var tag = NfcTag(data: {'mifare': {'identifier': [1, 2, 3]}});
  
  var identifier = getTagIdentifier(tag);
  expect(identifier, equals('1,2,3'));
});
