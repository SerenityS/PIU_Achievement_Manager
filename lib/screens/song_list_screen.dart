import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({Key? key}) : super(key: key);

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final _pref = GetStorage();
  var gradeData = {};

  late var difData;
  late var fullSongData;

  final List difColor = [
    Colors.red,
    Colors.amber,
    Colors.yellow,
    Colors.green,
    Colors.lightBlue,
    Colors.indigo,
    Colors.purple,
    Colors.grey
  ];

  final List difName = ['최상', '상', '중상', '중', '중하', '하', '최하', '종특'];

  @override
  void initState() {
    loadGradeData();
    loadFullSongData();
    super.initState();
  }

  void showGradeModal(context, songNum) {
    var gradeList = ['SSS', 'SS', 'S', 'A', 'B', 'C', 'D', 'F'];

    String songName = '';
    for (var song in fullSongData['songs']) {
      if (song['songNo'].toString() == songNum) {
        songName = song['songTitle_ko'];
        break;
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
          child: Wrap(
            children: [
              ListTile(
                title: Text(
                  songName,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemCount: gradeList.length,
                itemBuilder: (BuildContext ctx, idx) {
                  return GridTile(
                    child: InkWell(
                      onTap: () async {
                        gradeData['$songNum'] = gradeList[idx];
                        setState(() {});
                        Get.back();
                        await _pref.write('S21', gradeData);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        child: Image.asset(
                            'assets/grade/grade${gradeList[idx]}.png'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future loadGradeData() async {
    try {
      gradeData = await _pref.read('S21');
    } catch (e) {
      gradeData = {};
    }
  }

  Future loadDifficultyData() async {
    var jsonText = await rootBundle.loadString('assets/json/S21.json');
    difData = json.decode(jsonText);
    return true;
  }

  Future loadFullSongData() async {
    var jsonText = await rootBundle.loadString('assets/json/songList.json');
    fullSongData = json.decode(jsonText);
    return true;
  }

  Widget songJacketImage(dif, idx) {
    var songData = difData[difName[dif]][idx];
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.asset('assets/songJacket/${songData['songNum']}.png'),
        ),
        Row(
          children: [
            if (songData['skill'].contains('D'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            if (songData['skill'].contains('G'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            if (songData['skill'].contains('T'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            if (songData['skill'].contains('B'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            if (songData['skill'].contains('S'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        if (gradeData['${songData['songNum']}'] != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 27.5,
              child: Image.asset(
                  'assets/grade/grade${gradeData['${songData['songNum']}']}.png'),
            ),
          ),
      ],
    );
  }

  Widget songListView(dif, color) {
    return Flexible(
      child: Card(
        color: color,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            difName[dif],
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          children: [
            Container(
              color: Colors.white.withOpacity(0.3),
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                primary: false,
                shrinkWrap: true,
                itemCount: difData[difName[dif]].length,
                itemBuilder: (BuildContext context, int idx) {
                  return InkWell(
                    onTap: () async {
                      showGradeModal(
                          context, '${difData[difName[dif]][idx]['songNum']}');
                    },
                    child: songJacketImage(dif, idx),
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pump It Up 서열표'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: loadDifficultyData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData == false) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 8; i++)
                    if (difData[difName[i]].length != 0)
                      songListView(i, difColor[i])
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
