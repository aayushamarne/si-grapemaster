import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static AuthService? _instance;
  // Lazily create the singleton to avoid accessing FirebaseAuth before
  // Firebase.initializeApp(...) is called (prevents web configuration errors).
  static AuthService get instance => _instance ??= AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp({required String email, required String password, required String name}) async {
    try {
      print('🔵 Starting sign up for: $email');
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print('✅ User created in Firebase Auth: ${cred.user?.uid}');
      
      final uid = cred.user!.uid;
      // Update the user's display name
      await cred.user!.updateDisplayName(name);
      await cred.user!.reload();
      print('✅ Display name updated to: $name');
      
      // Store user info in Firestore
      await _fs.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': 'farmer',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ User document created in Firestore');
      return cred;
    } catch (e) {
      print('❌ Sign up error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signIn({required String email, required String password}) async {
    try {
      print('🔵 Starting sign in for: $email');
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('✅ Signed in successfully: ${cred.user?.uid}');
      return cred;
    } catch (e) {
      print('❌ Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
