import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CollectionAuth {
  static Future<bool> loginWithEmailPassword(String email, String password) async {
    final bytes = utf8.encode(password);
    final hashedPassword = sha256.convert(bytes).toString();

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
    if (!userDoc.exists) return false;
    final data = userDoc.data() as Map<String, dynamic>;
    return data['password'] == hashedPassword;
  }

  static Future<bool> userExists(String email) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
    return userDoc.exists;
  }

  static Future<void> registerUser(Map<String, dynamic> userData) async {
    await FirebaseFirestore.instance.collection('users').doc(userData['email']).set(userData);
  }
} 