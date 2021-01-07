import 'package:aplikasi_absensi/login_dosen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login Absensi",
      home: LoginDosenPage(),
      theme: ThemeData(
        primaryColor: Color(0xFF333366)
      ),
    );
  }
}

