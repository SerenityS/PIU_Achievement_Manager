import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({Key? key}) : super(key: key);

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final _pref = GetStorage();

  ScreenshotController screenshotController = ScreenshotController();

  var gradeData = {};

  int clearedCount = 0;

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
                        countCleared();
                        setState(() {});
                        Get.back();
                        await _pref.write('S21', gradeData);
                      },
                      onLongPress: () async {
                        gradeData['$songNum'] = '${gradeList[idx]}_O';
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

  Future countCleared() async {
    var gradeList = ['SSS', 'SS', 'S', 'A', 'B', 'C', 'D', 'F'];

    clearedCount = 0;

    for (var grade in gradeData.values) {
      if (gradeList.contains(grade)) clearedCount++;
    }
  }

  Future loadGradeData() async {
    try {
      gradeData = await _pref.read('S21');
    } catch (e) {
      gradeData = {};
    }
    await countCleared();
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

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();

    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'PIU_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name:name);

    return result['filePath'];
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

  Widget roadToTitle() {
    return Card(
      color: Colors.redAccent,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Road to ',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Image.asset('assets/title/33.png'),
                Text(
                  ' ($clearedCount/30)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget songListView(dif) {
    return Flexible(
      child: Card(
        color: difColor[dif],
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
                    onLongPress: () async {
                      gradeData
                          .remove('${difData[difName[dif]][idx]['songNum']}');
                      countCleared();
                      setState(() {});
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
        actions: [
          IconButton(
            onPressed: () async {
              final image = await screenshotController.capture();

              if (image != null) {
                await saveImage(image);
              } else {
                return;
              }
              Get.snackbar('Pump It Up', '캡쳐가 완료되었습니다.');
            },
            icon: Icon(Icons.photo_camera_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.white,
            child: FutureBuilder(
              future: loadDifficultyData(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      roadToTitle(),
                      for (var i = 0; i < 8; i++)
                        if (difData[difName[i]].length != 0) songListView(i)
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
