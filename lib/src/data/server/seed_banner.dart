import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> postDataToDatabase({
  String? logoImageUrl,
  String? titleInfo,
  String? descriptionInfo,
  String? textColor,
  String? backgroundColor,
}) async {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  final Map<String, dynamic> postData = {
    'logo': logoImageUrl,
    'titleInfo': titleInfo,
    'descriptionInfo': descriptionInfo,
    'backgroundColor': backgroundColor,
    'textColor': textColor,
  };

  databaseRef.child('banners').push().set(postData).then((value) {
    print('Post data saved successfully.');
  }).catchError((error) {
    print('Failed to save post data: $error');
  });
}

void seedDatabase() async {
  await postDataToDatabase(
    logoImageUrl: '',
    titleInfo: 'Aristo',
    descriptionInfo: '9 кафета, 10-то безплатно',
    backgroundColor: '#FFFFFF',
    textColor: '#000000',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCzl-eRuodu7QhZCBe-DzYbShqVshWwHn0',
      appId: '1:745257287690:android:b4e48f92f72ce0eb7f1ff3',
      messagingSenderId: '745257287690',
      projectId: 'kompot-13c90',
      databaseURL:
          'https://kompot-13c90-default-rtdb.europe-west1.firebasedatabase.app/',
      storageBucket: "gs://kompot-13c90.appspot.com",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Failed to initialize Firebase: ${snapshot.error}');
          return const Center(
            child: Text('Failed to initialize Firebase'),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'My App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const MyPage(),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            seedDatabase();
          },
          child: const Text('Seed Database'),
        ),
      ),
    );
  }
}
