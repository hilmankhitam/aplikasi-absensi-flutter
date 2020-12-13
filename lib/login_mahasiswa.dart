import 'dart:convert';

import 'package:aplikasi_absensi/dosen/home_dosen.dart';
import 'package:aplikasi_absensi/mahasiswa/home_mahasiswa.dart';
import 'package:aplikasi_absensi/login_dosen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginMahasiswaPage extends StatefulWidget {
  @override
  _LoginMahasiswaPageState createState() => _LoginMahasiswaPageState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginMahasiswaPageState extends State<LoginMahasiswaPage> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String username, password;
  final _key = GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      loginMahasiswa();
    }
  }

  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();

  loginMahasiswa() async {
    final response = await http.post(
        "https://aplikasiabsensistmik.000webhostapp.com/mahasiswa/loginmahasiswa.php",
        body: {
          "username": username,
          "password": password,
        });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String usernameAPI = data['username'];
    String namaAPI = data['nama'];
    String id = data['id'];
    String loginSebagai = data['loginsebagai'];
    if (value == 1) {
      print(data);
      Fluttertoast.showToast(
          msg: "Login Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, usernameAPI, namaAPI, id, loginSebagai);
      });
    } else {
      print(data);
      Fluttertoast.showToast(
          msg: "Username & Password Inccorect!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  savePref(int value, String username, String nama, String id,
      String loginSebagai) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("username", username);
      preferences.setString("nama", nama);
      preferences.setString("id", id);
      preferences.setString("loginSebagai", loginSebagai);
      // ignore: deprecated_member_use
      preferences.commit();
    });
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", null);
      // ignore: deprecated_member_use
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return MaterialApp(
          theme: ThemeData(primaryColor: Color(0xFF333366)),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              title: Text("Login Mahasiswa"),
            ),
            body: Padding(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _key,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  "LOGOSTMIKINDONESIABANJARMASIN.png"),
                              fit: BoxFit.contain),
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Login Mahasiswa',
                            style: TextStyle(
                                color: Color(0xFF333366),
                                fontWeight: FontWeight.w500,
                                fontSize: 30),
                          )),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          validator: (e) {
                            if (e.isEmpty) {
                              return "Please insert username";
                            }
                          },
                          onSaved: (e) => username = e,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'User Name',
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: TextFormField(
                          obscureText: _secureText,
                          onSaved: (e) => password = e,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                  onPressed: showHide,
                                  icon: Icon(_secureText
                                      ? Icons.visibility_off
                                      : Icons.visibility))),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          height: 50,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Color(0xFF333366),
                            child: Text('Login'),
                            onPressed: () {
                              check();
                            },
                          )),
                      GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginDosenPage()),
                              (Route<dynamic> route) => false);
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 25, 10, 0),
                          child: Text("Login Dosen",
                              style: TextStyle(
                                  color: Color(0xFF333366),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        );
        break;
      case LoginStatus.signIn:
        return HomeDosen(signOut);
        break;
    }
  }
}
