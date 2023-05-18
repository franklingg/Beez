// ignore_for_file: constant_identifier_names

import 'package:beez/models/user_model.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';

enum SignInMethod {
  EMAIL,
  FACEBOOK,
  GOOGLE,
  TWITTER;
}

class AuthService {
  static Future<UserModel> performLogin(
      {required BuildContext context,
      required SignInMethod method,
      String? email,
      String? password}) async {
    try {
      assert(method == SignInMethod.EMAIL
          ? email != null && password != null
          : true);
      final auth = FirebaseAuth.instance;
      late UserCredential credential;
      late UserModel? userData;
      switch (method) {
        case SignInMethod.EMAIL:
          credential = await auth.signInWithEmailAndPassword(
              email: email!, password: password!);
          break;
        case SignInMethod.FACEBOOK:
          final loginResult = await FacebookAuth.instance.login();
          credential = await auth.signInWithCredential(
              FacebookAuthProvider.credential(loginResult.accessToken!.token));
          break;
        case SignInMethod.GOOGLE:
          credential = await auth.signInWithProvider(GoogleAuthProvider());
          break;
        case SignInMethod.TWITTER:
          final twitterLogin = TwitterLogin(
              apiKey: dotenv.env['TWITTER_API_KEY']!,
              apiSecretKey: dotenv.env['TWITTER_API_SECRET']!,
              redirectURI: dotenv.env['TWITTER_CALLBACK_URL']!);
          final authResult = await twitterLogin.login();
          credential =
              await auth.signInWithCredential(TwitterAuthProvider.credential(
            accessToken: authResult.authToken!,
            secret: authResult.authTokenSecret!,
          ));
          break;
      }
      if (credential.additionalUserInfo!.isNewUser) {
        userData =
            await registerNewUser(method: method, credential: credential);
        await auth.signInWithCredential(credential.credential!);
      } else {
        // ignore: use_build_context_synchronously
        userData = Provider.of<UserProvider>(context, listen: false)
            .findUser(credential.user!.email!);
      }
      if (userData == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('@beez/userId', userData.id);
      return userData;
    } on AssertionError catch (_) {
      return Future.error("É necessário informar e-mail e senha.");
    } on FirebaseAuthException catch (error) {
      String message = "";
      switch (error.code) {
        case 'invalid-email':
          message = "O e-mail inserido é inválido.";
          break;
        case 'user-not-found':
          message = "Este usuário não existe.";
          break;
        case 'wrong-password':
          message = "A senha inserida é inválida.";
          break;
        default:
          message = "Não foi possível fazer login dessa forma.";
      }
      return Future.error(message);
    } catch (_) {
      return Future.error("Não foi possível fazer login dessa forma.");
    }
  }

  static Future<void> performLogout() {
    return FirebaseAuth.instance.signOut();
  }

  static Future<UserModel> registerNewUser(
      {required SignInMethod method,
      UserModel? newUserData,
      String? password,
      UserCredential? credential}) async {
    try {
      assert(method == SignInMethod.EMAIL
          ? newUserData != null && password != null
          : credential != null);
      final auth = FirebaseAuth.instance;
      late UserModel newUser;
      if (method == SignInMethod.EMAIL) {
        await auth.createUserWithEmailAndPassword(
            email: newUserData!.email, password: password!);
        newUser = newUserData;
      } else {
        newUser = UserModel.initialize(
                credential!.user!.displayName ?? "Sem Nome",
                credential.user!.email!,
                '',
                DateTime.now())
            .copyWith(verifiedPhone: true);
      }

      final usersCollection = FirebaseFirestore.instance.collection('users');
      final newUserRef = await usersCollection.add(newUser.toMap());
      return newUser.copyWith(id: newUserRef.id);
    } on FirebaseAuthException catch (error) {
      String message = "";
      switch (error.code) {
        case 'invalid-email':
          message = "O e-mail inserido é inválido.";
          break;
        case 'email-already-in-use':
          message = "O email inserido já está em uso.";
          break;
        case 'weak-password':
          message = "A senha inserida é fraca demais.";
          break;
        default:
          message = "Erro de Autenticação.";
      }
      return Future.error(message);
    }
  }

  static Future sendPasswordRecovery(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      String message = "Login Falhou.";
      switch (error.code) {
        case 'invalid-email':
        case 'user-not-found':
          message = "Este usuário não existe.";
          break;
        default:
          message = "Erro de Autenticação.";
      }
      return Future.error(message);
    }
  }

  static Future<void> sendPhoneVerification(
      {required String phoneNumber,
      required Function(FirebaseAuthException) onError,
      required Function(String, int?) onSent,
      required Function(String) onTimeout,
      required int? resendToken}) async {
    final auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (_) {},
        timeout: const Duration(minutes: 2),
        forceResendingToken: resendToken,
        verificationFailed: onError,
        codeSent: onSent,
        codeAutoRetrievalTimeout: onTimeout);
  }

  static Future<UserModel> verifyOtpCode(
      String verificationId, String otpCode, UserModel userData) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(
          PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: otpCode));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('@beez/userId', userData.id);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userData.id)
          .update({'verifiedPhone': true});
      return userData;
    } on FirebaseAuthException catch (error) {
      String message = "";
      switch (error.code) {
        case 'invalid-verification-code':
          message = "O código inserido está incorreto.";
          break;
        default:
          message = "Erro de Autenticação.";
      }
      return Future.error(message);
    }
  }
}
