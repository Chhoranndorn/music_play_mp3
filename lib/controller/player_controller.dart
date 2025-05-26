import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';

class PlayerController extends GetxController {
  final player = AudioPlayer();

  var isPlaying = false.obs;
  var currentPosition = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var isFavorite = false.obs;

  var isDarkMode = false.obs;
  var selectedCurrency = 'USD'.obs;

  var currentLocale = Locale('en', 'US').obs;

  // New reactive song info
  var songTitle = 'No song loaded'.obs;
  var artist = ''.obs;

  @override
  void onInit() {
    super.onInit();

    player.positionStream.listen((pos) {
      currentPosition.value = pos;
    });

    player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });
  }

  // Future<void> pickAudioFile() async {
  //   final result = await FilePicker.platform.pickFiles(type: FileType.audio);
  //   if (result != null && result.files.isNotEmpty) {
  //     final path = result.files.single.path;
  //     if (path != null) {
  //       await player.setFilePath(path);
  //       totalDuration.value = player.duration ?? Duration.zero;
  //       player.play();

  //       songTitle.value = result.files.single.name;
  //       artist.value = ''; // You could parse metadata here if you want
  //     }
  //   }
  // }
  Future<void> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        await player.stop(); // Stop current playback
        await player.setFilePath(path); // Load new file

        // Reset states AFTER file is fully loaded
        currentPosition.value = Duration.zero;
        totalDuration.value = player.duration ?? Duration.zero;

        await player.seek(Duration.zero); // Ensure seek to start
        await player.play(); // Start playing new audio

        songTitle.value = result.files.single.name;
        artist.value = ''; // Optional: metadata
      }
    }
  }

  void changeLanguage(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  void togglePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void seekTo(Duration position) {
    player.seek(position);
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
  }

  void changeCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
