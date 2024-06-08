test('Create review with invalid data handles errors', () async {
  await createReview('Unknown Title', [5.0, 5.0, 5.0]); // Assuming createReview manages handling of non-existent titles
  // Verify that an appropriate action is taken, like error logging or fallback
});

test('Update total reviews handles duplicate reviews correctly', () async {
  await createOrUpdateTotal Reviews('Popular Title', {'review': 'Excellent!'});
  await createOrUpdateTotal Reviews('Popular Title', {'review': 'Excellent!'}); // Duplicate entry test
  // Check if the review count only increments once or handles duplicates as per your app logic
});
