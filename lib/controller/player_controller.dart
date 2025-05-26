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

  // Playlist info
  List<String> playlist = [];
  List<PlatformFile> playlistFiles = [];
  int currentSongIndex = 0;

  // Reactive song info
  var songTitle = 'No song loaded'.obs;
  var artist = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen position updates
    player.positionStream.listen((pos) {
      currentPosition.value = pos;
    });

    // Listen player state changes and auto-play next song on completion
    player.playerStateStream.listen((state) async {
      isPlaying.value = state.playing;

      if (state.processingState == ProcessingState.completed) {
        currentSongIndex++;
        if (currentSongIndex < playlist.length) {
          await playSongAtIndex(currentSongIndex, playlistFiles);
        } else {
          currentSongIndex = 0;
          // Optionally stop playback or restart playlist here
          await player.stop();
          songTitle.value = 'No song loaded';
          artist.value = '';
          currentPosition.value = Duration.zero;
          totalDuration.value = Duration.zero;
        }
      }
    });
  }

  void playNextSong() async {
    if (playlist.isEmpty) return;

    currentSongIndex++;
    if (currentSongIndex >= playlist.length) {
      currentSongIndex = 0; // Loop to start or you can stop playback instead
    }
    await playSongAtIndex(currentSongIndex, playlistFiles);
  }

  void playPreviousSong() async {
    if (playlist.isEmpty) return;

    currentSongIndex--;
    if (currentSongIndex < 0) {
      currentSongIndex = playlist.length - 1; // Loop to end
    }
    await playSongAtIndex(currentSongIndex, playlistFiles);
  }

  Future<void> pickMultipleAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      playlist = result.files
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();
      playlistFiles = result.files;
      currentSongIndex = 0;
      await playSongAtIndex(currentSongIndex, playlistFiles);
    }
  }

  Future<void> playSongAtIndex(int index, List<PlatformFile> files) async {
    if (index < 0 || index >= playlist.length) return;

    // Update title immediately
    songTitle.value = files[index].name;
    update();
    artist.value = '';

    await player.stop();
    await player.setFilePath(playlist[index]);

    // Optionally wait for duration to be set (but no delay)
    currentPosition.value = Duration.zero;
    totalDuration.value = player.duration ?? Duration.zero;
    await player.seek(Duration.zero);
    await player.play();

    currentSongIndex = index;
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

  void changeLanguage(Locale locale) {
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
