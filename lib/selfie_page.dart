import 'dart:convert';
import 'dart:io';

import 'package:aplikasi_absensi/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class SelfiePage extends StatefulWidget {
  String namaMahasiswa, idPertemuan, idMahasiswa, namaDosen, base64ImageTTD;
  SelfiePage(
      {this.namaMahasiswa,
      this.idPertemuan,
      this.idMahasiswa,
      this.namaDosen,
      this.base64ImageTTD});
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
        dateTime.second.toString() +
        ':' +
        dateTime.millisecond.toString() +
        ':' +
        dateTime.microsecond.toString();
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
        title: Text("Camera Test"),
      ),
      body: Center(
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
                  imageFile = await Navigator.push<File>(
                      context, MaterialPageRoute(builder: (_) => CameraPage()));
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
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
            if (imageFile != null) {
              setState(() {
                loading = true;
              });
              String base64ImageSelfie =
                  base64Encode(imageFile.readAsBytesSync());

              String nameFileTTD =
                  '${formattedDate()}${widget.namaMahasiswa.replaceAll(" ", "_")}.png';
              String nameFileSelfie =
                  '${formattedDateSelfie()}${widget.namaMahasiswa.replaceAll(" ", "_")}.jpg';
              final response = await http.post(
                  "https://aplikasiabsensistmik.000webhostapp.com/image/upload.php",
                  body: {
                    "imageTTD": widget.base64ImageTTD,
                    "namaTTD": nameFileTTD,
                    "imageSelfie": base64ImageSelfie,
                    "namaSelfie": nameFileSelfie,
                    "idPertemuan": widget.idPertemuan,
                    "idMahasiswa": widget.idMahasiswa
                  });
              if (response.statusCode == 200) {
                print("Berhasil terupload");
              } else {
                print("gagal upload");
              }

              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
