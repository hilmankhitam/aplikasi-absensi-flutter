import 'dart:convert';
import 'dart:io';

import 'package:aplikasi_absensi/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelfiePage extends StatefulWidget {
  String username,
      idPertemuan,
      idMahasiswa,
      idKelas,
      pertemuanKe,
      namaDosen,
      base64ImageTTD,
      fotoProfil;
  SelfiePage(
      {this.username,
      this.idPertemuan,
      this.idMahasiswa,
      this.namaDosen,
      this.base64ImageTTD,
      this.idKelas,
      this.pertemuanKe,
      this.fotoProfil});
  @override
  _SelfiePageState createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  File imageFile;
  bool loading = false;

  String formattedDate() {
    DateTime dateTime = DateTime.now();
    String dateTimeString = 'TandaTangan_' +
        dateTime.year.toString() +
        dateTime.month.toString() +
        dateTime.day.toString() +
        dateTime.hour.toString() +
        ':' +
        dateTime.minute.toString() +
        ':' +
        dateTime.second.toString();
    return dateTimeString;
  }

  String formattedDateSelfie() {
    DateTime dateTime = DateTime.now();
    String dateTimeString = 'Selfie_' +
        dateTime.year.toString() +
        dateTime.month.toString() +
        dateTime.day.toString() +
        dateTime.hour.toString() +
        ':' +
        dateTime.minute.toString() +
        ':' +
        dateTime.second.toString() +
        ':' +
        dateTime.millisecond.toString() +
        ':' +
        dateTime.microsecond.toString();
    return dateTimeString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Konfirmasi Foto"),
      ),
      body: ListView(children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                width: 300,
                height: 450,
                color: Colors.grey[200],
                child: (imageFile != null) ? Image.file(imageFile) : SizedBox(),
              ),
              AbsorbPointer(
                absorbing: loading,
                child: RaisedButton(
                  child: Text("Take Picture"),
                  onPressed: () async {
                    imageFile = await Navigator.push<File>(context,
                        MaterialPageRoute(builder: (_) => CameraPage()));
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: AbsorbPointer(
        absorbing: loading,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: (loading)
              ? CircularProgressIndicator(
                  backgroundColor: Colors.white,
                )
              : Icon(Icons.check),
          onPressed: () async {
            String nameFileSelfie = "";
            if (imageFile != null) {
              if (widget.fotoProfil != "") {
                setState(() {
                  loading = true;
                });
                String base64ImageSelfie =
                    base64Encode(imageFile.readAsBytesSync());

                String nameFileTTD =
                    '${formattedDate()}${widget.username.replaceAll(" ", "_")}.png';
                nameFileSelfie =
                    '${formattedDateSelfie()}${widget.username.replaceAll(" ", "_")}.jpg';
                final response = await http.post(
                    "https://aplikasiabsensistmik.000webhostapp.com/image/upload.php",
                    body: {
                      "imageTTD": widget.base64ImageTTD,
                      "namaTTD": nameFileTTD,
                      "imageSelfie": base64ImageSelfie,
                      "namaSelfie": nameFileSelfie,
                      "idPertemuan": widget.idPertemuan,
                      "idMahasiswa": widget.idMahasiswa,
                      "idKelas": widget.idKelas,
                      "pertemuanKe": widget.pertemuanKe.trim()
                    });
                if (response.statusCode == 200) {
                  print("Berhasil terupload");
                } else {
                  print("gagal upload");
                }

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                setState(() {
                  loading = true;
                });
                String base64ImageSelfie =
                    base64Encode(imageFile.readAsBytesSync());
                String nameFileSelfie =
                    '${formattedDateSelfie()}${widget.username.replaceAll(" ", "_")}.jpg';
                final response = await http.post(
                    "https://aplikasiabsensistmik.000webhostapp.com/image/uploadFotoProfil.php",
                    body: {
                      "imageSelfie": base64ImageSelfie,
                      "namaSelfie": nameFileSelfie,
                      "idMahasiswa": widget.idMahasiswa,
                    });
                if (response.statusCode == 200) {
                  print("Berhasil terupload");
                } else {
                  print("gagal upload");
                }

                Navigator.of(context).pop();
                setState(() {});
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Gambar Tidak Boleh Kosong",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
        ),
      ),
    );
  }
}
