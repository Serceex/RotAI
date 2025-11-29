import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        final firebaseService = FirebaseService();
        _currentUser = await firebaseService.getUser(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String? displayName) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.signUpWithEmailAndPassword(
        email,
        password,
        displayName,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(AppUser user) async {
    await _authService.updateUserProfile(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileAndPassword(AppUser user, String? newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.updateUserProfile(user);
      if (newPassword != null && newPassword.isNotEmpty) {
        await _authService.updatePassword(newPassword);
      }
      _currentUser = user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

