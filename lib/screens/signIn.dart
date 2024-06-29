import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music/screens/signUp.dart';
import 'package:music/services/firebase_authen_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignUpState();
}

class _SignUpState extends State<SignIn> {
  final FirebaseAuthenService _authenService = FirebaseAuthenService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Sign in"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue)),
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue)),
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                _signIn();
              },
              child: const Text("Login")),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUp()));
                  },
                  child: const Text("Sign up"))
            ],
          )
        ],
      ),
    ));
  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _authenService.signInWithEmailAndPassword(
        context, email, password);
    if (user != null) {
      _showConfirmationDialog();
    } else {
      print("Sign in is fail");
    }
  }

  void _showConfirmationDialog() async{
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lưu thông tin đăng nhập"),
          content: const Text("Thông tin sẽ được lưu vào thiết bị!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {

                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/library',
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                // prefs.setString(_emailController.toString(), _passwordController.toString());
                Navigator.of(context).pop(); // Đóng hộp thoại
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/library',
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }
}
