import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static bool get isAuthenticated => _auth.currentUser != null;

  static Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
    String? photoUrl,
  }) async {
    try {
      print('=== FIREBASE AUTH DEBUG ===');
      print('Creating user with email: $email');
      print('Password length: ${password.length}');

      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      print('User created successfully: ${userCredential.user?.uid}');

      // Update user display name
      await userCredential.user?.updateDisplayName(fullName);
      print('Display name updated: $fullName');

      // Save additional user data to Firestore
      print('Saving user data to Firestore...');
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'uid': userCredential.user?.uid,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User data saved to Firestore successfully');

      return userCredential;
    } catch (e) {
      print('=== FIREBASE ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('=====================');
      rethrow;
    }
  }

  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  static Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  static Future<DocumentSnapshot?> getUserData() async {
    if (currentUser == null) return null;

    try {
      return await _firestore.collection('users').doc(currentUser!.uid).get();
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUser == null) return;

    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(currentUser!.uid).update(data);

      // Also update Firebase Auth display name if fullName is being updated
      if (data.containsKey('fullName')) {
        await currentUser!.updateDisplayName(data['fullName']);
      }
    } catch (e) {
      print('Update user data error: $e');
      rethrow;
    }
  }
}
