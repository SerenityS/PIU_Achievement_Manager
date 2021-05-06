import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piu_achievement_manager/screens/SongListScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.grey,
        primaryIconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/songlist',
      getPages: [GetPage(name: '/songlist', page: () => SongListScreen())],
    );
  }
}
