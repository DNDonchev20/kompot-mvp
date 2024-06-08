test('addUserData updates storage correctly', () async {
  final mockLocalStorage = MockLocalStorage();
  when(mockLocalStorage.setItem(any, any)).thenAnswer((_) async => {});
  storage = mockLocalStorage;

  addUserData('test@example.com', 'Test', 'User', 'Non-binary', '01/01/1990');
  verify(mockLocalStorage.setItem('email', 'test@example.com')).called(1);
});

test('clearCards removes all cards from storage', () async {
  final mockLocalStorage = MockLocalStorage();
  when(mockLocalStorage.deleteItem(any)).thenAnswer((_) async => {});
  storage = mockLocalStorage;

  clearCards();
  verify(mockLocalStorage.deleteItem('cards')).called(1);
});
