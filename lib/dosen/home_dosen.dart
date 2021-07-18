import 'dart:convert';

import 'package:aplikasi_absensi/dosen/detail_kelas.dart';
import 'package:aplikasi_absensi/selfie_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeDosen extends StatefulWidget {
  final VoidCallback signOut;
  HomeDosen(this.signOut);
  @override
  _HomeDosenState createState() => _HomeDosenState();
}

class _HomeDosenState extends State<HomeDosen> {
  final GlobalKey<RefreshIndicatorState> refresh =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = true;
  bool isLoadingUser = true;
  bool ulang = true;
  signOut() {
    setStateIfMounted(() {
      widget.signOut();
    });
  }

  String username = "",
      nama = "",
      id = "",
      loginSebagai = "",
      namaMatkulKelas = "",
      jurusan = "",
      niknip = "";

  Future<void> getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setStateIfMounted(() {
      username = preferences.getString("username");
      nama = preferences.getString("nama");
      id = preferences.getString("id");
      loginSebagai = preferences.getString("loginSebagai");
      jurusan = preferences.getString("jurusan");
      niknip = preferences.getString("niknip");
    });
  }

  List getInfo = List();
  Future<void> getInfoUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setStateIfMounted(() {
      id = preferences.getString("id");
    });
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/mahasiswa/getinfo.php?id=$id";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setStateIfMounted(() {
        getInfo = jsonDecode(response.body);
        isLoadingUser = false;
      });
      print(getInfo);
      return getInfo;
    }
  }

  List kelasList = List();
  getKelas() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setStateIfMounted(() {
      id = preferences.getString("id");
    });
    String url;
    while (ulang) {
      if (loginSebagai == 'dosen') {
        url =
            "https://aplikasiabsensistmik.000webhostapp.com/dosen/kelasdosen.php?id_dosen=$id";
      } else if (loginSebagai == 'mahasiswa') {
        url =
            "https://aplikasiabsensistmik.000webhostapp.com/mahasiswa/kelasmahasiswa.php?id_mahasiswa=$id";
      }
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setStateIfMounted(() {
          kelasList = jsonDecode(response.body);
          isLoading = false;
        });
        return kelasList;
      }
      setState(() {
        ulang = false;
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    getPref();
    getInfoUser();
    getKelas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (loginSebagai == 'dosen')
            ? Text("Dashboard Dosen")
            : Text("Dashboard Mahasiswa"),
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
      body: RefreshIndicator(
        onRefresh: getInfoUser,
        key: refresh,
        child: ListView(children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
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
                    isLoadingUser
                        ? SpinKitCircle(
                            color: Colors.white,
                          )
                        : Container(
                            margin: EdgeInsets.fromLTRB(10, 20, 30, 20),
                            child: Row(
                              children: <Widget>[
                                Stack(
                                  children: [
                                    loginSebagai == 'mahasiswa'
                                        ? Container(
                                            margin: EdgeInsets.only(left: 24),
                                            height: 110,
                                            width: 55,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: getInfo[0]
                                                              ['fotoprofil'] !=
                                                          ""
                                                      ? NetworkImage(
                                                          'https://aplikasiabsensistmik.000webhostapp.com/image/' +
                                                              getInfo[0][
                                                                  'fotoprofil'])
                                                      : AssetImage(
                                                          "LOGOSTMIKINDONESIABANJARMASIN.png"),
                                                  fit: BoxFit.contain),
                                            ),
                                          )
                                        : Container(
                                            height: 75,
                                            width: 75,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      "LOGOSTMIKINDONESIABANJARMASIN.png"),
                                                  fit: BoxFit.contain),
                                            ),
                                          ),
                                    loginSebagai == 'mahasiswa'
                                        ? Positioned(
                                            bottom: 1,
                                            left: 40,
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (getInfo[0]['fotoprofil'] ==
                                                    "") {
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SelfiePage(
                                                                idMahasiswa: id,
                                                                fotoProfil:
                                                                    getInfo[0][
                                                                        'fotoprofil'],
                                                                username:
                                                                    username,
                                                              ))).then(
                                                      (value) => getInfoUser());
                                                  setState(() {});
                                                }
                                              },
                                              child: Container(
                                                height: 28,
                                                width: 28,
                                                child: getInfo[0]
                                                            ['fotoprofil'] ==
                                                        ""
                                                    ? Icon(
                                                        Icons.add_a_photo,
                                                        color: Colors.white,
                                                      )
                                                    : SizedBox(),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    (loginSebagai == 'dosen')
                                        ? Text("NIP/NIK : " + niknip,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16))
                                        : Text("NRP        : " + username,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                              2 +
                                          10,
                                      child: Text("Nama     : " + nama,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ),
                                    (loginSebagai == "mahasiswa")
                                        ? Text("Jurusan : " + jurusan,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16))
                                        : SizedBox(),
                                    // Text("Foto Profil  : " +getInfo[0]['fotoprofil'],
                                    //     style: TextStyle(color: Colors.white, fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  (isLoading)
                      ? Center(
                          child: SpinKitFadingCircle(
                          color: Color(0xFF333366),
                        ))
                      : kelasList.isEmpty
                          ? Center(child: Text("Tidak ada Kelas"))
                          : ListView.builder(
                              itemCount:
                                  kelasList == null ? 0 : kelasList.length,
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: InkWell(
                                    onTap: () async {
                                      namaMatkulKelas =
                                          "${kelasList[index]['nama_matkul']} Kelas ${kelasList[index]['kelas_abjad']}";
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => DetailKelas(
                                                    idKelas: kelasList[index]
                                                        ['id_kelas'],
                                                    namaMatkulKelas:
                                                        namaMatkulKelas,
                                                    sks: kelasList[index]
                                                        ['sks'],
                                                    loginSebagai: loginSebagai,
                                                    idMahasiswa: id,
                                                    username: username,
                                                    qrCode: kelasList[index]
                                                        ['qr_code'],
                                                    fotoProfil: getInfo[0]['fotoprofil'],
                                                  )));
                                    },
                                    child: Container(
                                      height: 80,
                                      child: ListTile(
                                        title: Text(
                                            kelasList[index]['nama_matkul']),
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
        ]),
      ),
    );
  }
}
