import 'dart:convert';

import 'package:aplikasi_absensi/mahasiswa/detail_pertemuan_mahasiswa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class DetailKelasMahasiswa extends StatefulWidget {
  String idKelas, namaDosen, namaMatkulKelas, sks;
  DetailKelasMahasiswa({this.idKelas, this.namaDosen, this.namaMatkulKelas, this.sks});

  @override
  _DetailKelasMahasiswaState createState() => _DetailKelasMahasiswaState();
}

class _DetailKelasMahasiswaState extends State<DetailKelasMahasiswa> {
  List pertemuanKelas = List();
  bool isLoading = true;

  getPertemuanKelas() async {
    String url =
        "https://aplikasiabsensistmik.000webhostapp.com/mahasiswa/pertemuan.php?id_kelas=${widget.idKelas}";
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
      body: (isLoading)
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
                          title: Text(pertemuanKelas[index]['nama']),
                          subtitle: Text(
                              "Tanggal : ${pertemuanKelas[index]['tanggal']}\nRuang : ${pertemuanKelas[index]['ruangan']}\nPukul : ${pertemuanKelas[index]['jam']} | Status : ${pertemuanKelas[index]['status']}"),
                          enabled: true,
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DetailPertemuanMahasiswa(
                                        idKelas: widget.idKelas,
                                        namaKelas: widget.namaMatkulKelas,
                                        namaDosen: widget.namaDosen,
                                        idPertemuan: pertemuanKelas[index]
                                            ['id'],
                                        namaPertemuan: pertemuanKelas[index]
                                            ['nama'],
                                        tanggal: pertemuanKelas[index]
                                            ['tanggal'],
                                        ruang: pertemuanKelas[index]['ruangan'],
                                        pukul: pertemuanKelas[index]['jam'],
                                        status: pertemuanKelas[index]['status'],
                                        sks: widget.sks)));
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
