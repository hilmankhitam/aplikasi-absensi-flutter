import 'dart:convert';

import 'package:aplikasi_absensi/tanda_tangan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:qrscan/qrscan.dart' as scanner;

// ignore: must_be_immutable
class DetailPertemuan extends StatefulWidget {
  String idKelas,
      namaKelas,
      namaDosen,
      idPertemuan,
      status,
      sks,
      loginSebagai,
      idMahasiswa,
      namaMahasiswa,
      tandaTangan,
      pukul,
      qrCode;
  DetailPertemuan(
      {this.idKelas,
      this.namaKelas,
      this.namaDosen,
      this.idPertemuan,
      this.status,
      this.sks,
      this.loginSebagai,
      this.idMahasiswa,
      this.namaMahasiswa,
      this.tandaTangan,
      this.pukul,
      this.qrCode});

  @override
  _DetailPertemuanState createState() => _DetailPertemuanState();
}

class _DetailPertemuanState extends State<DetailPertemuan> {
  final GlobalKey<RefreshIndicatorState> refreshAbsensiKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> refreshMhsTerdaftarKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> refreshAllKey =
      GlobalKey<RefreshIndicatorState>();
  List mhsTerdaftar = List();
  List absensi = List();
  List infoPertemu;

  bool loadingMhsTerdaftar = true;
  bool loadingAbsen = true;
  bool loadingInfoPertemuan = true;

  String tandaTangan;
  infoPertemuan() async {
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/dosen/informasipertemuan.php?id_pertemuan=${widget.idPertemuan}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setStateIfMounted(() {
        infoPertemu = jsonDecode(response.body);
        loadingInfoPertemuan = false;
      });
      print(infoPertemu);
      return infoPertemu;
    }
  }

  getMhsTerdaftar() async {
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/dosen/mhsterdaftar.php?id_kelas=${widget.idKelas}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setStateIfMounted(() {
        mhsTerdaftar = jsonDecode(response.body);
        loadingMhsTerdaftar = false;
      });
      //print(mhsTerdaftar);
      return mhsTerdaftar;
    }
  }

  getAbsensi() async {
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/dosen/getabsensi.php?id_pertemuan=${widget.idPertemuan}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setStateIfMounted(() {
        absensi = jsonDecode(response.body);
        loadingAbsen = false;
      });
      print(absensi);
      return absensi;
    }
  }

  Future scan() async {
    print(widget.qrCode);
    String qrcode = await scanner.scan();
    if (qrcode == widget.qrCode) {
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TandaTangan(
                      namaMahasiswa: widget.namaMahasiswa,
                      idPertemuan: widget.idPertemuan,
                      idMahasiswa: widget.idMahasiswa,
                      loginSebagai: widget.loginSebagai)))
          .then((value) => _refresh());
    } else if (qrcode == null) {
    } else {
      Fluttertoast.showToast(
          msg: "QR Code Tidak Sama",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  checkAbsen() async {
    final response = await http.post(
        "https://aplikasiabsensistmik.000webhostapp.com/mahasiswa/checkabsensi.php",
        body: {
          "id_pertemuan": widget.idPertemuan,
          "id_mahasiswa": widget.idMahasiswa,
        });
    final data = jsonDecode(response.body);
    int value = data['value'];

    if (widget.status != 'Tutup' && widget.status != 'Belum Aktif') {
      if (value == 1) {
        //print(data);
        Fluttertoast.showToast(
            msg: "Anda sudah Absen",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        scan();
      }
    } else {
      Fluttertoast.showToast(
          msg: "Status Pertemuan Belum Aktif / Tutup",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  pilihAksi(String pilih) {
    if (pilih == GantiStatus.aktif) {
      print(GantiStatus.aktif);
      setState(() {
        widget.status = GantiStatus.aktif;
      });
      http.post(
          "https://aplikasiabsensistmik.000webhostapp.com/dosen/gantistatus.php",
          body: {
            "status": GantiStatus.aktif,
            "id_pertemuan": widget.idPertemuan
          });
      Fluttertoast.showToast(
          msg: "Status Pertemuan Berubah menjadi Aktif",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (pilih == GantiStatus.tutup) {
      print(GantiStatus.tutup);
      setState(() {
        widget.status = GantiStatus.tutup;
      });
      http.post(
          "https://aplikasiabsensistmik.000webhostapp.com/dosen/gantistatus.php",
          body: {
            "status": GantiStatus.tutup,
            "id_pertemuan": widget.idPertemuan
          });
      Fluttertoast.showToast(
          msg: "Status Pertemuan Berubah menjadi Tutup",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      print(GantiStatus.belumAktif);
      setState(() {
        widget.status = GantiStatus.belumAktif;
      });
      http.post(
          "https://aplikasiabsensistmik.000webhostapp.com/dosen/gantistatus.php",
          body: {
            "status": GantiStatus.belumAktif,
            "id_pertemuan": widget.idPertemuan
          });
      Fluttertoast.showToast(
          msg: "Status Pertemuan Berubah menjadi Belum Aktif",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  goToTandaTangan() async {
    if (widget.status == 'Aktif') {
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TandaTangan(
                      idPertemuan: widget.idPertemuan,
                      namaDosen: widget.namaDosen,
                      loginSebagai: widget.loginSebagai)))
          .then((value) => _refresh());
    } else {
      Fluttertoast.showToast(
          msg: "Status Pertemuan Belum Aktif / Tutup",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> _refresh() async {
    getMhsTerdaftar();
    getAbsensi();
    infoPertemuan();
  }

  @override
  void initState() {
    super.initState();
    getMhsTerdaftar();
    getAbsensi();
    infoPertemuan();
  }

  @override
  Widget build(BuildContext context) {
    String pukulAwal = widget.pukul.substring(0, 5).replaceAll(":", "");
    int angkaPukulAwal = int.parse(pukulAwal);
    String pukulAkhir = widget.pukul.substring(8, 13).replaceAll(":", "");
    int angkaPukulAkhir = int.parse(pukulAkhir);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        key: refreshAllKey,
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    title: Text("Detail Pertemuan"),
                    actions: <Widget>[
                      
                      (widget.loginSebagai == 'dosen')
                          ? PopupMenuButton<String>(
                              onSelected: pilihAksi,
                              itemBuilder: (context) {
                                return GantiStatus.pilih.map((String pil) {
                                  return PopupMenuItem<String>(
                                    value: pil,
                                    child: Text(pil),
                                  );
                                }).toList();
                              },
                            )
                          : SizedBox(
                              width: 10,
                            )
                    ],
                    //pinned: true,
                    expandedHeight: 350,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: <Widget>[
                          Container(
                            height: 260,
                            margin: EdgeInsets.fromLTRB(20, 75, 20, 0),
                            decoration: BoxDecoration(
                                color: Color(0xFF2D2D6C),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 7,
                                      spreadRadius: 5,
                                      offset: Offset(0.0, 5.0)),
                                ]),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(35, 85, 30, 0),
                            child: loadingInfoPertemuan
                                ? Center(
                                    child: SpinKitFadingCircle(
                                    color: Colors.white,
                                  ))
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(infoPertemu[0]['nama_pertemuan'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      Text("${widget.namaKelas}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      Text("SKS : ${widget.sks} SKS",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      Text(
                                          "Dosen Pengampu : ${widget.namaDosen}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      Text("Pukul  : ${infoPertemu[0]['jam']}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      Text(
                                          "Ruangan  : ${infoPertemu[0]['ruangan']}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      Text(
                                          "Status Pertemuan  : ${infoPertemu[0]['status']}",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children: <Widget>[
                                          SizedBox(height: 10),
                                          (infoPertemu[0]['tanda_tangan']
                                                  .isEmpty)
                                              ? (widget.loginSebagai == 'dosen')
                                                  ? RaisedButton(
                                                      onPressed: () {
                                                        goToTandaTangan();
                                                      },
                                                      child: Text(
                                                          "Tambah Tanda Tangan"),
                                                    )
                                                  : SizedBox()
                                              : Container(
                                                  height: 80,
                                                  width: 120,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.white),
                                                  child: Container(
                                                    height: 80,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                "https://aplikasiabsensistmik.000webhostapp.com/image/" +
                                                                    infoPertemu[
                                                                            0][
                                                                        'tanda_tangan']),
                                                            fit: BoxFit
                                                                .contain)),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    floating: false,
                    snap: false,
                    forceElevated: innerBoxIsScrolled,
                    bottom: TabBar(
                      tabs: [
                        Tab(
                          text: "Abesensi",
                        ),
                        Tab(
                          text: "Mahasiswa Terdaftar",
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                // Mahasiswa yang absen
                RefreshIndicator(
                  onRefresh: _refresh,
                  key: refreshAbsensiKey,
                  child: ListView(
                    children: [
                      (loadingAbsen)
                          ? Center(
                              child: SpinKitFadingCircle(
                              color: Color(0xFF333366),
                            ))
                          : absensi.isEmpty
                              ? Center(
                                  child: Text("Belum Ada Mahasiswa yang Absen"),
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 10, left: 10),
                                            child: Text(
                                                "Jumlah yang sudah absen (${absensi.length})")),
                                      ],
                                    ),
                                    ListView.builder(
                                      itemCount: absensi.length,
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: Container(
                                            height: 75,
                                            child: ListTile(
                                              leading: Text("${index + 1}"),
                                              title: Text(
                                                  absensi[index]['username']),
                                              subtitle: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Nama : " +
                                                        absensi[index]['nama'],
                                                    style:
                                                        TextStyle(fontSize: 13),
                                                  ),
                                                  Container(
                                                    height: 40,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.white),
                                                    child: Container(
                                                      height: 40,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  "https://aplikasiabsensistmik.000webhostapp.com/image/" +
                                                                      absensi[index]
                                                                          [
                                                                          'tanda_tangan']),
                                                              fit: BoxFit
                                                                  .contain)),
                                                    ),
                                                  ),
                                                  (widget.loginSebagai ==
                                                          'dosen')
                                                      ? Container(
                                                          height: 40,
                                                          width: 60,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              image: DecorationImage(
                                                                  image: NetworkImage(
                                                                      "https://aplikasiabsensistmik.000webhostapp.com/image/" +
                                                                          absensi[index]
                                                                              [
                                                                              'selfie']),
                                                                  fit: BoxFit
                                                                      .contain)),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                              onTap: () async {
                                                if (widget.loginSebagai ==
                                                    'dosen') {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        SelfieDialog(
                                                            nama: absensi[index]
                                                                ['nama'],
                                                            nrp: absensi[index]
                                                                ['username'],
                                                            selfie:
                                                                absensi[index]
                                                                    ['selfie']),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                    ],
                  ),
                ),
                // Mahasiswa yang terdaftar
                RefreshIndicator(
                  onRefresh: _refresh,
                  key: refreshMhsTerdaftarKey,
                  child: ListView(
                    children: [
                      (loadingMhsTerdaftar)
                          ? Center(
                              child: SpinKitFadingCircle(
                              color: Color(0xFF333366),
                            ))
                          : mhsTerdaftar.isEmpty
                              ? Center(
                                  child: Text("Tidak Ada Mahasiswa Terdaftar"),
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 10, left: 10),
                                            child: Text(
                                                "Jumlah Mahasiswa (${mhsTerdaftar.length})")),
                                      ],
                                    ),
                                    ListView.builder(
                                      itemCount: mhsTerdaftar.length,
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: Container(
                                            height: 80,
                                            child: ListTile(
                                              leading: Text("${index + 1}"),
                                              title: Text(mhsTerdaftar[index]
                                                  ['username']),
                                              subtitle: Text("Nama : " +
                                                  mhsTerdaftar[index]['nama']),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: (widget.loginSebagai == 'mahasiswa')
          ? FloatingActionButton(
              elevation: 0,
              child: Icon(Icons.qr_code_scanner),
              backgroundColor: Color(0xFF333366),
              onPressed: () async {
                DateTime dateTime = DateTime.now();
                String pukulSekarang =
                    dateTime.hour.toString() + dateTime.second.toString();
                int angkaPukulSekarang = int.parse(pukulSekarang);
                if ((angkaPukulSekarang >= angkaPukulAwal) &&
                    (angkaPukulSekarang <= angkaPukulAkhir)) {
                  checkAbsen();
                } else {
                  Fluttertoast.showToast(
                      msg: "Belum Jam Pertemuan",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            )
          : SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class GantiStatus {
  static const String belumAktif = 'Belum Aktif';
  static const String aktif = 'Aktif';
  static const String tutup = 'Tutup';

  static const List<String> pilih = <String>[belumAktif, aktif, tutup];
}

class SelfieDialog extends StatelessWidget {
  String selfie, nrp, nama;
  SelfieDialog({this.selfie, this.nrp, this.nama});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          width: 300,
          height: 470,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      "https://aplikasiabsensistmik.000webhostapp.com/image/" +
                          selfie),
                  fit: BoxFit.contain)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(nrp),
              SizedBox(
                height: 5,
              ),
              Text(nama),
            ],
          )),
    );
  }
}
