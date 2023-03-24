import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:just_audio/just_audio.dart';

import './Full_Surah.dart';
import './Loading_Scenario.dart';
import './Error_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Map<String, String>> surah = [];
  var isLoading;
  bool isReady = false;
  bool isError = false;
  int isPlaying = -1;
  bool playing = false;
  final player = AudioPlayer();
  Future<bool> fetchAllData() async {
    try {
      var url = Uri.parse('http://api.alquran.cloud/v1/surah');
      var response = await http.get(url);

      final data = jsonDecode(response.body);
      (data['data'] as List<dynamic>).forEach((e) {
        surah.add({
          'number': e['number'].toString(),
          'name': e['name'].toString(),
          'engName': e['englishName'].toString(),
          'ayhs': e['numberOfAyahs'].toString(),
          'revelationType': e['revelationType'].toString()
        });
      });
    } catch (e) {
      print(e);
      setState(() {
        isError = true;
      });
    }

    setState(() {
      isReady = true;
    });
    return true;
  }

  void playAudio(int ii) async {
    if (playing) {
      print('Working on if');
      await player.pause();
      setState(() {
        // isPlaying = ii;
        playing = false;
      });
      return;
    }
    playing = true;
    String index = (ii + 1).toString();
    String i;
    if (index.length == 1) {
      i = '00$index';
    } else if (index.length == 2) {
      i = '0$index';
    } else {
      i = index;
    }
    print('Playing');

    final duration =
        await player.setUrl('https://server6.mp3quran.net/thubti/$i.mp3');
    // player.play();
    await player.play();
    setState(() {
      // isPlaying = ii;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    isLoading = fetchAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: isReady
              ? AppBar(
                  title: Text('Al-Quran'),
                )
              : null,
          body: FutureBuilder(
            future: isLoading,
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? const Loading()
                : isError
                    ? Error()
                    : ListView.builder(
                        itemCount: surah.length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            print('Working');
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => FullSurah(
                                      name: surah[index]['engName'],
                                      surahNo: surah[index]['number'],
                                    )));
                          },
                          child: Card(
                            child: ListTile(
                                leading: CircleAvatar(
                                  child:
                                      Text(surah[index]['number'].toString()),
                                ),
                                subtitle: Text(surah[index]['name'].toString()),
                                title: Text(surah[index]['engName'].toString()),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (isPlaying != index)
                                        isPlaying = index;
                                      else
                                        isPlaying = -1;
                                    });
                                    playAudio((index));
                                  },
                                  icon: isPlaying == index
                                      ? const Icon(Icons.pause)
                                      : const Icon(Icons.play_arrow),
                                )),
                          ),
                        ),
                      ),
          )),
    );
  }
}
