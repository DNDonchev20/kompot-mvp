test('Database initialization uses correct parameters', () {
  final firebaseOptions = Firebase.initializeApp().options;
  expect(firebaseOptions.apiKey, equals(apiKey));
  expect(firebaseOptions.appId, equals(appId));
});

test('Fetching data handles errors gracefully', () async {
  final mockDatabaseRef = MockDatabaseReference();
  when(mockDatabaseRef.once()).thenThrow(Exception('Failed to fetch data'));
  databaseReference = mockDatabaseRef;

  expect(() => fetchCard('Nonexistent Card'), throwsException);
});
