import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({Key? key}) : super(key: key);

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
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

  Future loadDifficultyData() async {
    var jsonText = await rootBundle.loadString('assets/json/S21.json');
    difData = json.decode(jsonText);
    return true;
  }

  Widget songJacketImage(dif, idx) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.asset(
              'assets/songJacket/${difData[difNameEn[dif]][idx]['songNum']}.png'),
        ),
        Row(
          children: [
            if (difData[difNameEn[dif]][idx]['skill'].contains('D'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            if (difData[difNameEn[dif]][idx]['skill'].contains('G'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            if (difData[difNameEn[dif]][idx]['skill'].contains('T'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            if (difData[difNameEn[dif]][idx]['skill'].contains('B'))
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
            if (difData[difNameEn[dif]][idx]['skill'].contains('S'))
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
                    onTap: () {
                      // TODO: Implement onTap Activity
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
        title: Text('PIU Achievement Manager'),
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
