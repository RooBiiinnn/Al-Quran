import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:http/http.dart' as http;

import './Loading_Scenario.dart';
import './Error_Screen.dart';

class FullSurah extends StatefulWidget {
  final surahNo;
  final name;
  const FullSurah({required this.surahNo, required this.name});

  @override
  State<FullSurah> createState() => _FullSurahState();
}

class _FullSurahState extends State<FullSurah> {
  List<Map<String, String>> ayah = [];
  List<Map<String, String>> ayahArabic = [];
  var isLoad;
  bool isReady = false;
  bool isError = false;

  Future<bool> getSurah() async {
    final urlEnglish = Uri.parse(
        'http://api.alquran.cloud/v1/surah/${widget.surahNo}/en.asad');
    final urlArabic =
        Uri.parse('http://api.alquran.cloud/v1/surah/${widget.surahNo}');

    try {
      var responseEnglish = await http.get(urlEnglish);
      var responseArabic = await http.get(urlArabic);
      final English = jsonDecode(responseEnglish.body);
      final Arabic = jsonDecode(responseArabic.body);

      (English['data']['ayahs'] as List<dynamic>).forEach((e) {
        ayah.add({
          e['numberInSurah'].toString(): e['text'].toString(),
          'numberInQuran': e['number'].toString(),
          'juz': e['juz'].toString(),
          'manzil': e['manzil'].toString(),
          'page': e['page'].toString(),
          'ruku': e['ruku'].toString(),
          'hizbQuarter': e['hizbQuarter'].toString(),
          'sajda': e['sajda'].toString()
        });
      });

      (Arabic['data']['ayahs'] as List<dynamic>).forEach((e) {
        ayahArabic.add({e['numberInSurah'].toString(): e['text'].toString()});
      });
    } catch (e) {
      print(e);
      isError = true;
    }
    print(ayah[2].values);

    return true;
  }

  void openDetails(BuildContext context, Map<String, String> datas) {
    print(datas);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'))
          ],
          content: Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Ayah Number in Quran: ${datas['numberInQuran']}'),
                Text('Juz: ${datas['juz']}'),
                Text('Manzil: ${datas['manzil']}'),
                Text('Page Number: ${datas['page']}'),
                Text('Ruku: ${datas['ruku']}'),
                Text('Hizb Quarter: ${datas['hizbQuarter']}'),
                Text('Sajda: ${datas['sajda']}'),
              ],
            ),
          )),
    );
  }

  @override
  void initState() {
    isLoad = getSurah();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: FutureBuilder(
          future: isLoad,
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? const Loading()
              : isError
                  ? const Error()
                  : Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: ListView.builder(
                        itemCount: ayah.length,
                        itemBuilder: (context, index) => Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListTile(
                              onTap: () {
                                var datas = {
                                  'numberInQuran':
                                      ayah[index]['numberInQuran'].toString(),
                                  'juz': ayah[index]['juz'].toString(),
                                  'manzil': ayah[index]['manzil'].toString(),
                                  'page': ayah[index]['page'].toString(),
                                  'ruku': ayah[index]['ruku'].toString(),
                                  'hizbQuarter':
                                      ayah[index]['hizbQuarter'].toString(),
                                  'sajda': ayah[index]['sajda'].toString()
                                };
                                openDetails(context, datas);
                              },
                              subtitle: Text(ayah[index][(index + 1).toString()]
                                  .toString()),
                              title: Text(ayahArabic[index]
                                      [(index + 1).toString()]
                                  .toString()),
                            ),
                            const Divider()
                          ],
                        ),
                      ),
                    )),
    );
  }
}
