import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

// ignore: must_be_immutable
class DetailPertemuanMahasiswa extends StatefulWidget {
  String idKelas,
      namaKelas,
      namaDosen,
      idPertemuan,
      namaPertemuan,
      tanggal,
      ruang,
      pukul,
      status,
      sks;
  DetailPertemuanMahasiswa(
      {this.idKelas,
      this.namaKelas,
      this.namaDosen,
      this.idPertemuan,
      this.namaPertemuan,
      this.tanggal,
      this.ruang,
      this.pukul,
      this.status,
      this.sks});

  @override
  _DetailPertemuanMahasiswaState createState() => _DetailPertemuanMahasiswaState();
}

class _DetailPertemuanMahasiswaState extends State<DetailPertemuanMahasiswa> {
  List mhsTerdaftar = List();
  bool isLoading = true;

  getMhsTerdaftar() async {
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/dosen/mhsterdaftar.php?id_kelas=${widget.idKelas}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setStateIfMounted(() {
        mhsTerdaftar = jsonDecode(response.body);
        isLoading = false;
      });
      print(mhsTerdaftar);
      return mhsTerdaftar;
    }
  }

  pilihAksi(String pilih) {
    if (pilih == GantiStatus.aktif) {
      print(GantiStatus.aktif);
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
    } else {
      print(GantiStatus.tutup);
      http.post(
          "https://aplikasiabsensistmik.000webhostapp.com/dosen/gantistatus.php",
          body: {
            "status": GantiStatus.tutup,
            "id_pertemuan": widget.idPertemuan
          });
      Fluttertoast.showToast(
          msg: "Status Pertemuan Berubha menjadi Tutup",
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

  @override
  void initState() {
    super.initState();
    getMhsTerdaftar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Detail Kelas"),
      // ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  title: Text("Detail Pertemuan"),
                  actions: <Widget>[
                    PopupMenuButton<String>(
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
                          margin: EdgeInsets.fromLTRB(35, 85, 30, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${widget.namaPertemuan}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              Text("${widget.namaKelas}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              Text("SKS : ${widget.sks} SKS",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              Text("Dosen Pengampu : ${widget.namaDosen}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              Text("Tanggal  : ${widget.tanggal}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              Text("Pukul  : ${widget.pukul}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              Text("Ruangan  : ${widget.ruang}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              Text("Status Pertemuan  : ${widget.status}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              SizedBox(
                                height: 10,
                              ),
                              Column(
                                children: <Widget>[
                                  RaisedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            height: 350,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: QrImage(
                                                    data: widget.idPertemuan,
                                                    version: QrVersions.auto,
                                                    size: 240,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    RaisedButton(
                                                      color: Color(0xFF333366),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        "Tutup",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text("Tampil QR Code"),
                                  ),
                                  SizedBox(height: 10),
                                  RaisedButton(
                                    onPressed: () {},
                                    child: Text("Tambah Tanda Tangan"),
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
              Center(
                  child: Text(
                      "ID Pertemuan : ${widget.idPertemuan} Belum Ada Mahasiswa Yang Absen")),
              (isLoading)
                  ? Center(child: CircularProgressIndicator())
                  : mhsTerdaftar.isEmpty
                      ? Center(
                          child: Text("Tidak Ada Mahasiswa Terdaftar"),
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    margin: EdgeInsets.only(top: 10, left: 10),
                                    child: Text(
                                        "Jumlah Mahasiswa (${mhsTerdaftar.length})")),
                              ],
                            ),
                            ListView.builder(
                              itemCount: mhsTerdaftar == null
                                  ? 0
                                  : mhsTerdaftar.length,
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: Container(
                                    height: 80,
                                    child: ListTile(
                                      leading: Text("${index + 1}"),
                                      title:
                                          Text(mhsTerdaftar[index]['username']),
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
      ),
    );
  }
}

class GantiStatus {
  static const String aktif = 'Aktif';
  static const String tutup = 'Tutup';

  static const List<String> pilih = <String>[aktif, tutup];
}
