import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  User? get user => _auth.currentUser;
  bool get isSignedIn => user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      String name,
      String email,
      String password,
      ) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}