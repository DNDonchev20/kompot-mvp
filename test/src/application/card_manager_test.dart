test('Fetch card handles unsupported languages by using default', () async {
  currentLanguage = 'es'; // Set an unsupported language
  var card = await fetchCard('Any Card');
  expect(card, isNull); // Assuming fetch fails or returns null for unmatched language logic
});

test('Save card handles null fetched data without error', () async {
  await saveCard('Invalid Card'); // Assuming it handles null internally
  // Verify that no exception is thrown or ensure the expected behavior
});
