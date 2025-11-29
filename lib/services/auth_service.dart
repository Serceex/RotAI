import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _firebaseService.getUser(credential.user!.uid);
    } catch (e) {
      throw Exception('Giriş hatası: $e');
    }
  }

  Future<AppUser> signUpWithEmailAndPassword(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = AppUser(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );
        await _firebaseService.createUser(user);
        return user;
      }
      throw Exception('Kullanıcı oluşturulamadı');
    } catch (e) {
      throw Exception('Kayıt hatası: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUserProfile(AppUser user) async {
    await _firebaseService.updateUser(user);
    if (user.displayName != null) {
      await _auth.currentUser?.updateDisplayName(user.displayName);
    }
  }
}

