import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_play_mp3/screen/mp3_player_screen.dart';
import 'package:music_play_mp3/util/translations.dart'; // <== Add this

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      translations: AppTranslations(), // <== Add this
      locale: Locale('en', 'US'), // <== Set default locale
      fallbackLocale: Locale('en', 'US'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Mp3PlayerScreen(),
    );
  }
}
