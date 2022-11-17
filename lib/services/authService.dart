
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  AuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  String getCurrentUserUID(){
    final User? user = _firebaseAuth.currentUser;
    return user!.uid;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
