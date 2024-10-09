import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musick/main.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class PlayerController extends GetxController {
  final audioquery = OnAudioQuery();
  final audioplayer = AudioPlayer();

  var duration = ''.obs;
  var position = ''.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  var playindex = 0.obs;
  var isplaying = false.obs;

  void onInit() {
    super.onInit();
    checkPermissions();
  }

  checkPermissions() async {
    var perm = await Permission.storage.request();
    if (perm.isGranted) {
      return audioquery.querySongs();
    } else {
      checkPermissions();
    }
  }

  playSong(String? uri, index) {
    playindex.value = index;

    try {
      audioplayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
      audioplayer.play();
      isplaying(true);
      updatePosition();
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  updatePosition() {
    audioplayer.durationStream.listen((d) {
      // Duration toplam zamanı temsil eder
      duration.value = d.toString().split('.')[0];
      max.value = d!.inSeconds.toDouble();
    });

    audioplayer.positionStream.listen((p) {
      // Position anlık zamanı temsil eder
      position.value = p.toString().split('.')[0];
      value.value =
          p.inSeconds.toDouble(); // slidere iletilir . Slider bu değeri alır.
    });
  }

  changeDurationToSecons(seconds) {
    // müzik çalarken secons.cu saniyeye git demek
    var duration = Duration(seconds: seconds);
    audioplayer.seek(duration);
  }
}
