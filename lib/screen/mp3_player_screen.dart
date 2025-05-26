import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_play_mp3/controller/player_controller.dart';
import 'dart:math' as math;

class Mp3PlayerScreen extends StatelessWidget {
  final PlayerController controller = Get.put(PlayerController());

  Mp3PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor:
            controller.isDarkMode.value ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('MP3 Player'.tr,
              style: TextStyle(
                  color: controller.isDarkMode.value
                      ? Colors.white
                      : Colors.black)),
          actions: [
            DropdownButton<Locale>(
              value: controller.currentLocale.value,
              dropdownColor:
                  controller.isDarkMode.value ? Colors.grey[900] : Colors.white,
              underline: SizedBox(),
              iconEnabledColor:
                  controller.isDarkMode.value ? Colors.white : Colors.black,
              items: [
                DropdownMenuItem(
                    value: Locale('en', 'US'),
                    child: Text('English',
                        style: TextStyle(
                            color: controller.isDarkMode.value
                                ? Colors.white
                                : Colors.black))),
                DropdownMenuItem(
                    value: Locale('km', 'KH'),
                    child: Text('ភាសាខ្មែរ',
                        style: TextStyle(
                            color: controller.isDarkMode.value
                                ? Colors.white
                                : Colors.black))),
              ],
              onChanged: (locale) {
                if (locale != null) controller.changeLanguage(locale);
              },
            ),

            // Dark mode toggle button
            IconButton(
              icon: Icon(
                  controller.isDarkMode.value
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: controller.isDarkMode.value
                      ? Colors.white
                      : Colors.black),
              onPressed: controller.toggleDarkMode,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Pick audio file button
              ElevatedButton.icon(
                onPressed: controller.pickMultipleAudioFiles,
                icon: Icon(Icons.folder_open,
                    color: controller.isDarkMode.value
                        ? Colors.white
                        : Colors.black),
                label: Text('Pick Audio File'.tr,
                    style: TextStyle(
                        color: controller.isDarkMode.value
                            ? Colors.white
                            : Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isDarkMode.value
                      ? Colors.grey[800]
                      : Colors.grey[300],
                ),
              ),

              SizedBox(height: 20),

              // Waveform placeholder
              SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.blue[900]!,
                              Colors.blue[300]!,
                            ],
                          ),
                        ),
                        child: CustomPaint(
                          painter: EqualizerPainter(),
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Song info with reactive title and artist
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Text(controller.songTitle.value,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: controller.isDarkMode.value
                                    ? Colors.white
                                    : Colors.black))),
                        Obx(() => Text(
                            controller.artist.value.isEmpty
                                ? ''
                                : controller.artist.value,
                            style: TextStyle(
                                color: controller.isDarkMode.value
                                    ? Colors.white70
                                    : Colors.black54))),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        controller.isFavorite.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red),
                    onPressed: controller.toggleFavorite,
                  ),
                ],
              ),

              // Slider & Duration
              Obx(() {
                return Slider(
                  activeColor: Colors.red,
                  inactiveColor: Colors.grey,
                  value: controller.currentPosition.value.inSeconds
                      .toDouble()
                      .clamp(0,
                          controller.totalDuration.value.inSeconds.toDouble()),
                  max: controller.totalDuration.value.inSeconds.toDouble(),
                  onChanged: (value) {
                    controller.seekTo(Duration(seconds: value.toInt()));
                  },
                );
              }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(controller.currentPosition.value),
                      style: TextStyle(
                          color: controller.isDarkMode.value
                              ? Colors.white70
                              : Colors.black54)),
                  Text(formatDuration(controller.totalDuration.value),
                      style: TextStyle(
                          color: controller.isDarkMode.value
                              ? Colors.white70
                              : Colors.black54)),
                ],
              ),

              Spacer(),

              // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Implement shuffle if you want
                    },
                    icon: Icon(Icons.shuffle,
                        color: controller.isDarkMode.value
                            ? Colors.white
                            : Colors.black),
                  ),
                  IconButton(
                    onPressed: controller.playPreviousSong,
                    icon: Icon(Icons.skip_previous,
                        color: controller.isDarkMode.value
                            ? Colors.white
                            : Colors.black),
                  ),
                  IconButton(
                    onPressed: controller.togglePlayPause,
                    icon: Icon(
                        controller.isPlaying.value
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 60,
                        color: controller.isDarkMode.value
                            ? Colors.white
                            : Colors.black),
                  ),
                  IconButton(
                    onPressed: controller.playNextSong,
                    icon: Icon(Icons.skip_next,
                        color: controller.isDarkMode.value
                            ? Colors.white
                            : Colors.black),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement share if you want
                    },
                    icon: Icon(Icons.share,
                        color: controller.isDarkMode.value
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class EqualizerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.cyanAccent;
    final barWidth = 4.0;
    final spacing = 2.0;
    final barCount = (size.width / (barWidth + spacing)).floor();

    for (int i = 0; i < barCount; i++) {
      final barHeight = (size.height / 2) *
          (0.5 +
              0.5 *
                  math.sin(i + DateTime.now().millisecondsSinceEpoch * 0.002));
      final x = i * (barWidth + spacing);
      final y = size.height - barHeight;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
