import 'dart:convert';

import 'package:aplikasi_absensi/dosen/detail_pertemuan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class DetailKelas extends StatefulWidget {
  String idKelas, namaDosen, namaMatkulKelas, sks, loginSebagai, idMahasiswa, namaMahasiswa;
  DetailKelas({this.idKelas, this.namaMatkulKelas, this.sks, this.loginSebagai, this.idMahasiswa,this.namaMahasiswa});

  @override
  _DetailKelasState createState() => _DetailKelasState();
}

class _DetailKelasState extends State<DetailKelas> {
  List pertemuanKelas = List();
  bool isLoading = true;
  final GlobalKey<RefreshIndicatorState> refresh = GlobalKey<RefreshIndicatorState>();

  Future<void> getPertemuanKelas() async {
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/dosen/pertemuan.php?id_kelas=${widget.idKelas}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setStateIfMounted(() {
        pertemuanKelas = jsonDecode(response.body);
        isLoading = false;
      });
      print(pertemuanKelas);
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
      ),
      body: RefreshIndicator(
        onRefresh: getPertemuanKelas,
        key: refresh,
              child: (isLoading)
            ? Center(child: CircularProgressIndicator())
            : pertemuanKelas.isEmpty
                ? Center(child: Text("Belum ada Pertemuan"))
                : ListView.builder(
                    itemCount: pertemuanKelas == null ? 0 : pertemuanKelas.length,
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
                            title: Text(pertemuanKelas[index]['nama_pertemuan']),
                            subtitle: Text(
                                "Ruang : ${pertemuanKelas[index]['ruangan']}\nPukul : ${pertemuanKelas[index]['jam']} | Status : ${pertemuanKelas[index]['status']}"),
                            enabled: true,
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPertemuan(
                                          idKelas: widget.idKelas,
                                          namaKelas: widget.namaMatkulKelas,
                                          namaDosen: pertemuanKelas[index]['nama'],
                                          idPertemuan: pertemuanKelas[index]
                                              ['id'],
                                          status: pertemuanKelas[index]['status'],
                                          sks: widget.sks,
                                          loginSebagai: widget.loginSebagai,
                                          idMahasiswa: widget.idMahasiswa,
                                          namaMahasiswa: widget.namaMahasiswa,
                                          tandaTangan: pertemuanKelas[index]['tanda_tangan'],))).then((value) => getPertemuanKelas());
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
