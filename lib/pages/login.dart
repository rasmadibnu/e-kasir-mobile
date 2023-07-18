import 'package:flutter/material.dart';

import '../api.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    _isLoading = true;
    final username = _usernameController.text;
    final password = _passwordController.text;

    final loggedIn = await Api.login(username, password);

    final validate = _formKey.currentState?.validate();
    if (validate == true) {
      if (loggedIn) {
        String token = await Api.isLoggedIn() ?? "";
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(token)));
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
        });
      }
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Theme(
          data: ThemeData(
              // inputDecorationTheme: InputDecorationTheme(
              //   enabledBorder: UnderlineInputBorder(
              //     borderSide: BorderSide(color: Colors.white),
              //   ),
              //   focusedBorder: UnderlineInputBorder(
              //     borderSide: BorderSide(color: Colors.white),
              //   ),
              //   labelStyle: TextStyle(color: Colors.white), // Ubah warna label
              //   hintStyle: TextStyle(color: Colors.white), // Ubah warna hint teks
              // ),
              ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Image.asset(
                          //   'assets/flutter_logo.png', // Path to your Flutter logo image
                          //   width: 100,
                          //   height: 100,
                          // ),
                          Text(
                            'E-Kasir',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                                labelText: 'Username',
                                icon: Icon(Icons.person)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Username tidak boleh kosong.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                icon: Icon(Icons.lock)),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Password tidak boleh kosong.';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 25.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50), // NEW
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Login',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
