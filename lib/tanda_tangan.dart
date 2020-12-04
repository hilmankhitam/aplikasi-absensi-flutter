import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;

class TandaTangan extends StatefulWidget {
  String namaMahasiswa, idPertemuan, idMahasiswa, loginSebagai, namaDosen;
  TandaTangan(
      {this.namaMahasiswa,
      this.idPertemuan,
      this.idMahasiswa,
      this.loginSebagai,
      this.namaDosen});
  @override
  _TandaTanganState createState() => _TandaTanganState();
}

class _TandaTanganState extends State<TandaTangan> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print("Value changed"));
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tanda Tangan"),
      ),
      body: ListView(
        children: <Widget>[
          //SIGNATURE CANVAS
          Signature(
            controller: _controller,
            height: 300,
            backgroundColor: Colors.white,
          ),
          //OK AND CLEAR BUTTONS
          Container(
            decoration: const BoxDecoration(color: Colors.black),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //SHOW EXPORTED IMAGE IN NEW ROUTE
                AbsorbPointer(
                  absorbing: loading,
                                  child: IconButton(
                    icon: (loading) ? CircularProgressIndicator() : Icon(Icons.check),
                    color: Colors.blue,
                    onPressed: () async {
                      if (_controller.isNotEmpty) {
                        setState(() {
                          loading = true;
                        });
                        var data = await _controller.toPngBytes();
                        String nameFile;

                        String base64Image = base64Encode(data);
                        if (widget.loginSebagai == 'mahasiswa') {
                          nameFile =
                              '${formattedDate()}${widget.namaMahasiswa.replaceAll(" ", "_")}.png';
                          final response = await http.post(
                              "https://aplikasiabsensistmik.000webhostapp.com/image/upload.php",
                              body: {
                                "image": base64Image,
                                "name": nameFile,
                                "idPertemuan": widget.idPertemuan,
                                "idMahasiswa": widget.idMahasiswa
                              });
                          if (response.statusCode == 200) {
                            print("Berhasil terupload");
                          } else {
                            print("gagal upload");
                          }
                        } else {
                          nameFile =
                              '${formattedDate()}${widget.namaDosen.replaceAll(" ", "_")}.png';
                          final response = await http.post(
                              "https://aplikasiabsensistmik.000webhostapp.com/image/uploadTTDDosen.php",
                              body: {
                                "image": base64Image,
                                "name": nameFile,
                                "idPertemuan": widget.idPertemuan
                              });
                          if (response.statusCode == 200) {
                            print("Berhasil terupload");
                          } else {
                            print("gagal upload");
                          }
                        }
                        Navigator.of(context).pop();
                      } else {
                        Fluttertoast.showToast(
                            msg: "Tanda Tangan Tidak Boleh Kosong",
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
                //CLEAR CANVAS
                IconButton(
                  icon: const Icon(Icons.clear),
                  color: Colors.blue,
                  onPressed: () {
                    setState(() => _controller.clear());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
