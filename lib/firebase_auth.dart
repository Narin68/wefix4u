import 'package:firebase_auth/firebase_auth.dart';

class MyFirebaseAuth {
  static final _auth = FirebaseAuth.instance;

  static Future sendSms(
    String phone, {
    Function(FirebaseAuthException)? onError,
    Function(String)? onSuccess,
    Function(User?)? onCompleted,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (onCompleted != null) {
          await confirmSms(credential: credential, onSuccess: onCompleted);
        }
      },
      verificationFailed: (FirebaseAuthException e) async {
        if (onError != null) onError(e);
      },
      codeSent: (String verificationId, int? resendToken) async {
        if (onSuccess != null) onSuccess(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) async {},
    );
  }

  static Future confirmSms({
    String? token,
    String? code,
    PhoneAuthCredential? credential,
    Function(User?)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      credential ??= PhoneAuthProvider.credential(
          verificationId: token ?? '', smsCode: code ?? '');

      var userCredential = await _auth.signInWithCredential(credential);
      var user = userCredential.user;

      if (user != null) {
        if (onSuccess != null) onSuccess(user);
      } else {
        if (onError != null) onError('no-user-firebase-found');
      }
    } catch (e) {
      if (onError != null) onError(e.toString());
    }
  }
}
