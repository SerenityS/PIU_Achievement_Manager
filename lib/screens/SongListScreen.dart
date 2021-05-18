import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
  final List difNameEn = ['SHD', 'HD', 'HN', 'NM', 'EN', 'EZ', 'SE', 'SP'];
  final List difNameKo = ['최상', '상', '중상', '중', '중하', '하', '최하', '종특'];

  @override
  void initState() {
    loadGradeData();
    super.initState();
  }

  void selectGradeDialog(context, songNum) {
    var grade1 = ['SSS', 'S', 'B', 'D'];
    var grade2 = ['SS', 'A', 'C', 'F'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('랭크를 선택해주세요'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var grade in grade1)
                    InkWell(
                      onTap: () {
                        gradeData['$songNum'] = grade;
                        setState(() {});
                        Get.back();
                      },
                      child: Container(
                        width: 100,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/grade/grade$grade.png'),
                      ),
                    ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var grade in grade2)
                    InkWell(
                      onTap: () {
                        gradeData['$songNum'] = grade;
                        setState(() {});
                        Get.back();
                      },
                      child: Container(
                        width: 100,
                        height: 50,
                        margin: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/grade/grade$grade.png'),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                gradeData.remove('$songNum');
                setState(() {});
                Get.back();
              },
              child: Text('삭제'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('취소'),
            ),
          ],
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

  Widget songJacketImage(dif, idx) {
    var songData = difData[difNameEn[dif]][idx];
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
            difNameKo[dif],
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
                itemCount: difData[difNameEn[dif]].length,
                itemBuilder: (BuildContext context, int idx) {
                  return InkWell(
                    onTap: () async {
                      selectGradeDialog(context,
                          '${difData[difNameEn[dif]][idx]['songNum']}');
                      await _pref.write('S21', gradeData);
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
                    if (difData[difNameEn[i]].length != 0)
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
