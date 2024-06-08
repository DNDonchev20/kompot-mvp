import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> postDataToDatabase({
  String? logoImageUrl,
  String? stampImageUrl,
  String? text,
  String? titleInfo,
  String? addressInfo,
  String? descriptionInfo,
  List<String>? identifier,
  int? cooldown,
  String? backgroundColor,
  String? textColor,
  String? instagramTextInfo,
  String? phoneTextInfo,
  String? websiteTextInfo,
  String? circleNumber,
  String? textReward,
}) async {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  final Map<String, dynamic> postData = {
    'logo': logoImageUrl,
    'stamp': stampImageUrl,
    'text': text,
    'titleInfo': titleInfo,
    'addressInfo': addressInfo,
    'descriptionInfo': descriptionInfo,
    'identifier': identifier,
    'cooldown': cooldown,
    'backgroundColor': backgroundColor,
    'textColor': textColor,
    'circleNumber': circleNumber,
    'textReward': textReward,
  };

  if (instagramTextInfo != null) {
    postData['instagramTextInfo'] = instagramTextInfo;
  }
  if (phoneTextInfo != null) {
    postData['phoneTextInfo'] = phoneTextInfo;
  }
  if (websiteTextInfo != null) {
    postData['websiteTextInfo'] = websiteTextInfo;
  }

  databaseRef.child('cards').push().set(postData).then((value) {
    print('Post data saved successfully.');
  }).catchError((error) {
    print('Failed to save post data: $error');
  });
}

void seedDatabase() async {
  await postDataToDatabase(
    logoImageUrl:
        'https://firebasestorage.googleapis.com/v0/b/kompot-13c90.appspot.com/o/images%2Faristo.jpg?alt=media&token=97e1b914-f5cd-467a-a326-2d2ef8280597',
    stampImageUrl:
        'https://firebasestorage.googleapis.com/v0/b/kompot-13c90.appspot.com/o/images%2Faristo_stamp.png?alt=media&token=8efe8566-0bf5-44bd-b07a-12d593661576',
    text: 'Поръчай 9 кафета, вземи 10-то безплатно',
    titleInfo: 'Aristo',
    addressInfo: 'https://goo.gl/maps/tt6v6ENvCB8co3bH9',
    descriptionInfo:
        'Aristo е комбинация от уютна атмосфера и изкушаващо вкусна храна.',
    identifier: [""],
    cooldown: 8,
    backgroundColor: '#FFFFFF',
    textColor: '#000000',
    instagramTextInfo: 'https://www.instagram.com/aristo_burgas',
    phoneTextInfo: "0889029270",
    websiteTextInfo: 'https://www.facebook.com/profile.php?id=100084804235335',
    circleNumber: '9',
    textReward: 'Безплатно кафе',
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
