import 'dart:convert';

import 'package:aplikasi_absensi/mahasiswa/detail_kelas_mahasiswa.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeMahasiswa extends StatefulWidget {
  final VoidCallback signOut;
  HomeMahasiswa(this.signOut);
  @override
  _HomeMahasiswaState createState() => _HomeMahasiswaState();
}

class _HomeMahasiswaState extends State<HomeMahasiswa> {
  bool isLoading = true;
  signOut() {
    setStateIfMounted(() {
      widget.signOut();
    });
  }

  String username = "", nama = "", id = "", namaMatkulKelas = "";

  void getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setStateIfMounted(() {
      username = preferences.getString("username");
      nama = preferences.getString("nama");
      id = preferences.getString("id");
    });
  }

  List kelasList = List();
  getKelas() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setStateIfMounted(() {
      id = preferences.getString("id");
    });
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/mahasiswa/kelasmahasiswa.php?id_mahasiswa=$id";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setStateIfMounted(() {
        kelasList = jsonDecode(response.body);
        isLoading = false;
      });
      print(kelasList);
      return kelasList;
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    getPref();
    getKelas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Mahasiswa"),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () {
                  signOut();
                },
                child: Icon(Icons.logout),
              ))
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 140,
                  //margin: EdgeInsets.only(left: 46),
                  decoration: BoxDecoration(
                      color: Color(0xFF333366),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0.0, 10.0)),
                      ]),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 20, 30, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("NRP      : " + username,
                          style:
                              TextStyle(color: Colors.white, fontSize: 16)),
                      Text("Nama  : " + nama,
                          style:
                              TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: <Widget>[
              (isLoading)
                  ? Center(child: CircularProgressIndicator())
                  : kelasList.isEmpty
                      ? Center(child: Text("Tidak ada Kelas"))
                      : ListView.builder(
                          itemCount: kelasList == null ? 0 : kelasList.length,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  namaMatkulKelas =
                                      "${kelasList[index]['nama_matkul']} Kelas ${kelasList[index]['kelas_abjad']}";
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailKelasMahasiswa(
                                              idKelas: kelasList[index]
                                                  ['id_kelas'],
                                              namaDosen: nama,
                                              namaMatkulKelas:
                                                  namaMatkulKelas,
                                              sks: kelasList[index]['sks'])));
                                },
                                child: Container(
                                  height: 80,
                                  child: ListTile(
                                    title:
                                        Text(kelasList[index]['nama_matkul']),
                                    subtitle: Text("Kelas " +
                                        kelasList[index]['kelas_abjad']),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ],
      ),
    );
  }
}