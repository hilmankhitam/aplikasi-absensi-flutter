import 'dart:async';

import 'package:aplikasi_absensi/login_dosen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login Absensi",
      home: SplashScreen(),
      theme: ThemeData(
        primaryColor: Color(0xFF333366)
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), ()=> Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => LoginDosenPage())) );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF333366),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset("LOGOSTMIKINDONESIABANJARMASIN.png", height: 100,),
          SizedBox(height: 30,),
          SpinKitFadingCircle(color: Colors.white,)
        ],
      ),
    );
  }
}
