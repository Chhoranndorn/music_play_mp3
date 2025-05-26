// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:file_picker/file_picker.dart';

// class PlayerController extends GetxController {
//   final player = AudioPlayer();

//   var isPlaying = false.obs;
//   var currentPosition = Duration.zero.obs;
//   var totalDuration = Duration.zero.obs;
//   var isFavorite = false.obs;

//   var isDarkMode = false.obs;
//   var selectedCurrency = 'USD'.obs;

//   var currentLocale = Locale('en', 'US').obs;

//   // New reactive song info
//   var songTitle = 'No song loaded'.obs;
//   var artist = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();

//     player.positionStream.listen((pos) {
//       currentPosition.value = pos;
//     });

//     player.playerStateStream.listen((state) {
//       isPlaying.value = state.playing;
//     });
//   }

//   // Future<void> pickAudioFile() async {
//   //   final result = await FilePicker.platform.pickFiles(type: FileType.audio);
//   //   if (result != null && result.files.isNotEmpty) {
//   //     final path = result.files.single.path;
//   //     if (path != null) {
//   //       await player.setFilePath(path);
//   //       totalDuration.value = player.duration ?? Duration.zero;
//   //       player.play();

//   //       songTitle.value = result.files.single.name;
//   //       artist.value = ''; // You could parse metadata here if you want
//   //     }
//   //   }
//   // }
//   // Future<void> pickAudioFile() async {
//   //   final result = await FilePicker.platform.pickFiles(type: FileType.audio);
//   //   if (result != null && result.files.isNotEmpty) {
//   //     final path = result.files.single.path;
//   //     if (path != null) {
//   //       await player.stop(); // Stop current playback
//   //       await player.setFilePath(path); // Load new file

//   //       // Reset states AFTER file is fully loaded
//   //       currentPosition.value = Duration.zero;
//   //       totalDuration.value = player.duration ?? Duration.zero;

//   //       await player.seek(Duration.zero); // Ensure seek to start
//   //       await player.play(); // Start playing new audio

//   //       songTitle.value = result.files.single.name;
//   //       artist.value = ''; // Optional: metadata
//   //     }
//   //   }
//   // }
//   List<String> playlist = [];
//   int currentSongIndex = 0;

//   Future<void> pickMultipleAudioFiles() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.audio,
//       allowMultiple: true,
//     );

//     if (result != null && result.files.isNotEmpty) {
//       playlist = result.files
//           .where((file) => file.path != null)
//           .map((file) => file.path!)
//           .toList();
//       currentSongIndex = 0;
//       await playSongAtIndex(currentSongIndex, result.files);
//     }
//   }

//   Future<void> playSongAtIndex(int index, List<PlatformFile> files) async {
//     if (index < 0 || index >= playlist.length) return;

//     await player.stop();
//     await player.setFilePath(playlist[index]);
//     currentPosition.value = Duration.zero;
//     totalDuration.value = player.duration ?? Duration.zero;
//     await player.seek(Duration.zero);
//     await player.play();

//     songTitle.value = files[index].name;
//     artist.value = ''; // optional metadata

//     // Listen for song completion and play next
//     player.playerStateStream.listen((state) async {
//       if (state.processingState == ProcessingState.completed) {
//         currentSongIndex++;
//         if (currentSongIndex < playlist.length) {
//           await playSongAtIndex(currentSongIndex, files);
//         } else {
//           // Playlist ended
//           currentSongIndex = 0; // or reset / stop
//         }
//       }
//     });
//   }

//   void changeLanguage(Locale locale) {
//     currentLocale.value = locale;
//     Get.updateLocale(locale);
//   }

//   void togglePlayPause() {
//     if (player.playing) {
//       player.pause();
//     } else {
//       player.play();
//     }
//   }

//   void seekTo(Duration position) {
//     player.seek(position);
//   }

//   void toggleFavorite() {
//     isFavorite.value = !isFavorite.value;
//   }

//   void toggleDarkMode() {
//     isDarkMode.value = !isDarkMode.value;
//   }

//   void changeCurrency(String currency) {
//     selectedCurrency.value = currency;
//   }

//   @override
//   void onClose() {
//     player.dispose();
//     super.onClose();
//   }
// }
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

  // Future<void> playSongAtIndex(int index, List<PlatformFile> files) async {
  //   if (index < 0 || index >= playlist.length) return;

  //   await player.stop();
  //   await player.setFilePath(playlist[index]);
  //   currentPosition.value = Duration.zero;
  //   totalDuration.value = player.duration ?? Duration.zero;
  //   await player.seek(Duration.zero);
  //   await player.play();

  //   songTitle.value = files[index].name;
  //   artist.value = ''; // optional metadata
  //   currentSongIndex = index;
  // }
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
