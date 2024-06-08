test('Initial setup for developer accounts sets default values', () async {
  final mockDatabaseRef = MockDatabaseReference();
  when(mockDatabaseRef.once()).thenAnswer((_) async => DatabaseEvent(
      DatabaseEventType.value, DatabaseDataSnapshot(null)));
  when(mockDatabaseRef.set(any)).thenAnswer((_) async => {});
  databaseReference = mockDatabaseRef;

  await getDeveloperAccounts();
  verify(mockDatabaseRef.set({'accounts': ['']})).called(1);
});

test('Handles errors during developer accounts retrieval', () async {
  final mockDatabaseRef = MockDatabaseReference();
  when(mockDatabaseRef.once()).thenThrow(Exception('Failed to fetch developer accounts'));
  databaseReference = mockDatabaseRef;

  expect(() => getDeveloperAccounts(), throwsException);
});
