import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:telegram_clone_mobile/locator.dart';
import 'package:telegram_clone_mobile/models/user_details.dart';
import 'package:telegram_clone_mobile/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _numbers = '1234567890';
  final Random _random = Random();

  User? get currentUser => _auth.currentUser;

  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  void signInWithPhoneNumber(
    String phoneNumber, {
    required void Function(PhoneAuthCredential) verificationCompleted,
    void Function(FirebaseAuthException)? verificationFailed,
    required void Function(String, int?) codeSent,
    void Function(String)? codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    int? forceResendingToken,
  }) {
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed ?? (error) {},
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout ?? (verificationId) {},
      autoRetrievedSmsCodeForTesting: autoRetrievedSmsCodeForTesting,
      timeout: Duration(seconds: 30),
      forceResendingToken: forceResendingToken,
    );
  }

  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    final userCredentials = await _auth.signInWithCredential(credential);

    // TODO: Change to Cloud Function
    if (userCredentials.additionalUserInfo!.isNewUser) {
      final username = _generateUsername();

      await locator<UserService>().addUser(
        id: userCredentials.user!.uid,
        details: UserDetails(
            username: username,
            firstName: username,
            lastName: '',
            phoneNumber: _auth.currentUser!.phoneNumber!,
            online: true,
            chats: []),
      );
    }
  }

  String _generateUsername() {
    return 'User${String.fromCharCodes(Iterable.generate(8, (_) => _numbers.codeUnitAt(_random.nextInt(_numbers.length))))}';
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
