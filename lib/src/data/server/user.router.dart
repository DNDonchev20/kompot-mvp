import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final DatabaseReference _database = FirebaseDatabase.instance.ref();

void signUpWithEmailAndPassword(String email, String password, String firstName, String lastName,
    String dateOfBirth, String gender) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      print('User signed up successfully with UID: ${user.uid}');
      // Now call the function to add user details to the database
      addUserDetails(email, firstName, lastName, dateOfBirth, gender);
    } else {
      print('User registration failed.');
    }
  } catch (e) {
    print('Error: $e');
  }
}

void addUserDetails(String email, String firstName, String lastName,
    String dateOfBirth, String gender) {
  try {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      DatabaseReference userRef = _database.child('users').child(userId);

      userRef.set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
      }).then((_) {
        print('User details added successfully');
      }).catchError((error) {
        print('Error: $error');
      });
    } else {
      print('User is not authenticated.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
