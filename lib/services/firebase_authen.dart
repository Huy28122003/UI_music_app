
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class FirebaseAuthenService {
  final FirebaseAuth _authenService = FirebaseAuth.instance;
  Future<User?> signUpWithEmailAndPassword(BuildContext context,String email, String password) async{
    try{
      UserCredential userCredential = await _authenService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    }on FirebaseAuthException catch(e){
      if(e.code =="email-already-in-use"){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The email address is already in use'),
          ),
        );
      }
      else{
        print("Error $e");
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(BuildContext context,String email, String password) async{
    try{
      UserCredential userCredential = await _authenService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch(e){
      print(e.code);
      print(e.code);
      if(e.code == "invalid-credential"){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
          ),
        );
      }
      else{
        print("Error $e");
      }
    }
    return null;
  }
}