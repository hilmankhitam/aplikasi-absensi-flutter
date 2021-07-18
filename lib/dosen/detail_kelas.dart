import 'dart:convert';

import 'package:aplikasi_absensi/dosen/detail_pertemuan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class DetailKelas extends StatefulWidget {
  String idKelas,
      namaDosen,
      namaMatkulKelas,
      sks,
      loginSebagai,
      idMahasiswa,
      username,
      qrCode,
      fotoProfil;
  DetailKelas(
      {this.idKelas,
      this.namaMatkulKelas,
      this.sks,
      this.loginSebagai,
      this.idMahasiswa,
      this.username,
      this.qrCode,
      this.fotoProfil});

  @override
  _DetailKelasState createState() => _DetailKelasState();
}

class _DetailKelasState extends State<DetailKelas> {
  List pertemuanKelas = List();
  bool isLoading = true;
  final GlobalKey<RefreshIndicatorState> refresh =
      GlobalKey<RefreshIndicatorState>();

  Future<void> getPertemuanKelas() async {
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/dosen/pertemuan.php?id_kelas=${widget.idKelas}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setStateIfMounted(() {
        pertemuanKelas = jsonDecode(response.body);
        isLoading = false;
      });
      //print(pertemuanKelas);
      return pertemuanKelas;
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    getPertemuanKelas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.namaMatkulKelas),
        actions: [
          (widget.loginSebagai == "dosen")
              ? Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: InkWell(
                    onTap: () async {
                      final status = await Permission.storage.request();
                      String url =
                          "https://aplikasiabsensistmik.000webhostapp.com/dosen/laporan.php?id_kelas=${widget.idKelas}";
                      if (status.isGranted) {
                        final externalDir = await getExternalStorageDirectory();
                        final id = await FlutterDownloader.enqueue(
                            url: url,
                            savedDir: externalDir.path,
                            showNotification: true,
                            openFileFromNotification: true);
                      } else {
                        print("Permission Denied");
                      }
                    },
                    child: Icon(Icons.save),
                  ))
              : SizedBox(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: getPertemuanKelas,
        key: refresh,
        child: (isLoading)
            ? Center(
                child: SpinKitFadingCircle(
                color: Color(0xFF333366),
              ))
            : pertemuanKelas.isEmpty
                ? Center(child: Text("Belum ada Pertemuan"))
                : ListView.builder(
                    itemCount:
                        pertemuanKelas == null ? 0 : pertemuanKelas.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Container(
                          decoration: BoxDecoration(
                              color: (pertemuanKelas[index]['status'] ==
                                      "Belum Aktif")
                                  ? Colors.grey
                                  : (pertemuanKelas[index]['status'] == "Aktif")
                                      ? Colors.green
                                      : Colors.red),
                          height: 100,
                          child: ListTile(
                            leading: Text("${index + 1}"),
                            title: Text("Pertemuan ke - " +
                                pertemuanKelas[index]['nama_pertemuan']),
                            subtitle: Text(
                                "Ruang : ${pertemuanKelas[index]['ruangan']}\nPukul : ${pertemuanKelas[index]['jam']}\nStatus : ${pertemuanKelas[index]['status']}"),
                            enabled: true,
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPertemuan(
                                          idKelas: widget.idKelas,
                                          namaKelas: widget.namaMatkulKelas,
                                          namaDosen: pertemuanKelas[index]
                                              ['nama'],
                                          idPertemuan: pertemuanKelas[index]
                                              ['id'],
                                          status: pertemuanKelas[index]
                                              ['status'],
                                          sks: widget.sks,
                                          loginSebagai: widget.loginSebagai,
                                          idMahasiswa: widget.idMahasiswa,
                                          username: widget.username,
                                          tandaTangan: pertemuanKelas[index]
                                              ['tanda_tangan'],
                                          pukul: pertemuanKelas[index]['jam'],
                                          qrCode: widget.qrCode,
                                          fotoProfil: widget.fotoProfil))).then(
                                  (value) => getPertemuanKelas());
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
