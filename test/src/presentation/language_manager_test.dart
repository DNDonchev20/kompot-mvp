test('getCountry fetches correct country code', () async {
  Network mockNetwork = MockNetwork();
  when(mockNetwork.getData()).thenReturn(Future.value('{"country":"Bulgaria"}'));
  var country = await getCountry();
  expect(country, 'Bulgaria');
});

test('getCodeForCountryName defaults to English for unsupported country', () {
  var code = getCodeForCountryName('Mars');
  expect(code, 'en');
});
