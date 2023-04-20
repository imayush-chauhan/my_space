import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {

  final _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle(BuildContext context) async {
    signInFunc() async {
      if (kIsWeb) {
        // Once signed in, return the UserCredential
        return await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      }

      await signOutWithGoogle().catchError((_) => null);
      final auth = await (await _googleSignIn.signIn())?.authentication;
      if (auth == null) {
        return null;
      }
      final credential = GoogleAuthProvider.credential(
          idToken: auth.idToken, accessToken: auth.accessToken);
      return FirebaseAuth.instance.signInWithCredential(credential);
    }
    return signInOrCreateAccount(context, signInFunc, 'GOOGLE');
  }

  Future signOutWithGoogle() => _googleSignIn.signOut();



  Future<User?> signInOrCreateAccount(
      BuildContext context,
      Future<UserCredential?> Function() signInFunc,
      String authProvider,
      ) async {
    try {
      final userCredential = await signInFunc();
      if (userCredential?.user != null) {

        // add data

      }
      return userCredential?.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message!}')),
      );
      return null;
    }
  }



}