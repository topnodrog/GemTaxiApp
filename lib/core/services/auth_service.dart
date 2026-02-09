import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable User Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current User
  User? get currentUser => _auth.currentUser;

  // Phone Number Sign In (Step 1: Request Code)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (Android only usually)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Phone Number Sign In (Step 2: Verify Code)
  Future<UserCredential> signInWithOtp(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Check if user profile exists in Firestore, if not create one
  Future<void> checkOrCreateUser(User user) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    
    if (!doc.exists) {
      // New User - Default to passenger
      UserModel newUser = UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber,
        email: user.email,
        displayName: 'New User',
        role: 'passenger',
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
