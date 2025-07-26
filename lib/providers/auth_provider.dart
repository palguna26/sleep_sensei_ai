import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  UserProfile? _profile;
  bool _loading = true;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _profile = null;
      }
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _profile = UserProfile.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      if (_user != null) {
        await _loadUserProfile(_user!.uid);
      }
      
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      notifyListeners();
      
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      
      throw Exception(message);
    } catch (e) {
      _loading = false;
      notifyListeners();
      throw Exception('Login failed: $e');
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      notifyListeners();
      
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      
      throw Exception(message);
    } catch (e) {
      _loading = false;
      notifyListeners();
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      if (_user == null) throw Exception('User not authenticated');
      
      await _firestore.collection('users').doc(_user!.uid).set(profile.toMap());
      _profile = profile;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      _profile = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Password reset failed: ${e.message}';
      }
      throw Exception(message);
    }
  }
}
