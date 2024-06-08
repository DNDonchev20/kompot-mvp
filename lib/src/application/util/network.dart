import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Network {
  final String url;

  Network(this.url);

  // celiq kod sum go kradnal
  // https://stackoverflow.com/questions/57977167/device-country-in-flutter

  Future<String> apiRequest(Map jsonMap) async {
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }

  Future<String> sendData(Map data) async {
    http.Response response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return (response.body);
    } else {
      return 'No Data';
    }
  }

  Future<String> getData() async {
    http.Response response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'});
    if (response.statusCode == 200) {
      return (response.body);
    } else {
      return 'No Data';
    }
  }
}
