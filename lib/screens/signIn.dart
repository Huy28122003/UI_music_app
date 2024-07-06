import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music/models/SongManager.dart';
import 'package:music/screens/signUp.dart';
import 'package:music/services/auto_login_service.dart';
import 'package:music/services/firebase_authen_service.dart';
import 'package:music/services/receive_cloud_messaging_service.dart';
import 'package:music/services/firebase_tracker_service.dart';
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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Map<String, String>> keys = [];
  late Future<List<Map<String, String>>> infor;

  Future<List<Map<String, String>>> get() async {
    final SharedPreferences prefs = await _prefs;
    Set<String> keys = prefs.getKeys();
    List<Map<String, String>> keyList = [];
    for (String key in keys) {
      var value = prefs.get(key);
      if (value is String) {
        Map<String, String> keyValue = {key: value};
        keyList.add(keyValue);
      }
    }
    return keyList;
  }

  void set(String key, String pass) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(key, pass);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fromFuture();
    infor = getInforByEmail("");
  }

  void fromFuture() async {
    keys = await get();
    for (var i in keys) {
      print(i.keys);
    }
  }

  Future<List<Map<String, String>>> getInforByEmail(String value) async {
    List<Map<String, String>> results = [];
    keys.forEach((element) {
      if (element.keys
          .toString()
          .toLowerCase()
          .contains(value.toString().toLowerCase())) {
        results.add(element);
      }
    });
    return results;
  }

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
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  FutureBuilder(
                      future: infor,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final data = snapshot.data!;
                          return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0; i < data.length; i++)
                                    TextButton(
                                        onPressed: () {
                                          _emailController.text = data[i]
                                              .keys
                                              .toString()
                                              .substring(
                                                  1,
                                                  data[i]
                                                          .keys
                                                          .toString()
                                                          .length -
                                                      1);
                                          _passwordController.text = data[i]
                                              .values
                                              .toString()
                                              .substring(
                                                  1,
                                                  data[i]
                                                          .values
                                                          .toString()
                                                          .length -
                                                      1);
                                        },
                                        child: Text(data[i].keys.toString()))
                                ],
                              ));
                        } else if (snapshot.hasError) {
                          return Text('$snapshot.error');
                        } else {
                          return const CircularProgressIndicator();
                        }
                      }),
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
                      onChanged: (value) {
                        setState(() {
                          infor = getInforByEmail(value);
                        });
                      },
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
            )));
  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _authenService.signInWithEmailAndPassword(
        context, email, password);
    if (user != null) {
      manager.setDataSource("favorite");
      manager.loadData("favorite");
      bool isSave = false;
      for (var i in keys) {
        if (i.keys.toString() == "(${_emailController.text.toString()})") {
          isSave = true;
          break;
        }
      }
      if (!isSave) {
        _showConfirmationDialog();
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/library',
          (Route<dynamic> route) => false,
        );
      }
    } else {
      print("Sign in is fail");
    }
  }

  void _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lưu thông tin đăng nhập"),
          content: const Text("Thông tin sẽ được lưu vào thiết bị!"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/library',
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                set(_emailController.text.toString(),
                    _passwordController.text.toString());
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/library',
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }
}
