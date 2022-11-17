import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_sa/customMap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:explore_sa/MyColors.dart';

import 'customSettings.dart';


class LoginScreen extends StatelessWidget {
  late UserCredential userCredential;
  late User user;
  Duration get loginTime => Duration(milliseconds: 2250);

  //user recovery
  Future<String> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) {
      // if (!user.containsKey(name)) {
      //   return 'User does not exists';
      // }
      return "null";
    });
  }

  @override
  Widget build(BuildContext context) {
    //user interface
    return FlutterLogin(
      theme: LoginTheme(
          cardTheme: CardTheme(
              color: MyColors.xLightTeal
          )
      ),
      onLogin: _loginUser,
      onSignup: _registerUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CustomSettings(),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }


  Future<String> _loginUser(LoginData data) async {
    late String status;
    print('Login =======================> Name: ${data.name}, Password: ${data.password}');
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: data.name,
          password: data.password
      );
      status = "User found!";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
    user = FirebaseAuth.instance.currentUser!;
    return status;
  }

  Future<String> _registerUser(LoginData data) async {
    late String status;
    CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
    print('Registration =======================> Name: ${data.name}, Password: ${data.password}');
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: data.name,
          password: data.password
      ).then((value) {
        usersRef.doc(value.user?.uid).set(
            {
              'displayName': "Name",
              'uid': value.user?.uid,
              'locationPref': 'food',
              'measureSystem': 'Kilometers',
              'favLocations': ''
            }
        ).catchError((onError) =>
            print(onError));
      });
      status = "User registered!";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    user = FirebaseAuth.instance.currentUser!;
    return status;
  }

  User getCurrentUser() {
    return user;
  }
}