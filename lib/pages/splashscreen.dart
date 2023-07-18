import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kasir_mobile/pages/home.dart';
import 'login.dart';
import 'package:kasir_mobile/api.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () async {
      String token = await Api.isLoggedIn() ?? "";
      if(token != ""){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(token)));
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()));
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logoekasir.png'),
            Text(
              'Kelompok 6',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
