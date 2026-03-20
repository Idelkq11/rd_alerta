import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> registerWithEmail(String email, String password, String nombre) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('usuarios').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'nombre': nombre,
        'email': email,
        'fechaRegistro': DateTime.now().toIso8601String(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Cancelado';
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      final userDoc = await _firestore.collection('usuarios').doc(result.user!.uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('usuarios').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'nombre': result.user!.displayName ?? 'Usuario',
          'email': result.user!.email,
          'fechaRegistro': DateTime.now().toIso8601String(),
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String> getUserName() async {
    try {
      final doc = await _firestore.collection('usuarios').doc(currentUser!.uid).get();
      return doc.data()?['nombre'] ?? 'Usuario';
    } catch (e) {
      return 'Usuario';
    }
  }
}