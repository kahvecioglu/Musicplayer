import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musick/player_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatefulWidget {
  final List<SongModel> data;
  const Player({super.key, required this.data});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  DeviceModel? deviceModel; // Nullable olarak tanımladık

  @override
  void initState() {
    super.initState();
    getDevice(); // Cihaz bilgilerini almak için çağrıldı
  }

  getDevice() async {
    deviceModel = await OnAudioQuery().queryDeviceInfo();
    setState(
        () {}); // deviceModel geldikten sonra UI'ı güncellemek için setState kullanıyoruz
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Obx(
              () {
                // Şarkı değiştiğinde resmi almak için burayı güncelliyoruz
                String? resim = widget.data[controller.playindex.value].artwork;

                return QueryArtworkWidget(
                  id: widget.data[controller.playindex.value].id,
                  type: ArtworkType.AUDIO,
                  artwork: resim,
                  deviceSDK: deviceModel?.sdk ?? 30, // 30 varsayılan değer

                  artworkHeight: 300,
                  artworkWidth: 300,
                  nullArtworkWidget: Icon(
                    Icons.music_note,
                    size: 50,
                    color: Colors.white,
                  ),
                );
              },
            ),
            SizedBox(
              height: 12,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 228, 221, 221),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Obx(
                  () => Column(
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.data[controller.playindex.value]
                              .displayNameWOExt,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        widget.data[controller.playindex.value].artist,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Obx(
                        () => Row(
                          children: [
                            Text(controller.position
                                .value), // .value koymamızın sebebi , Getx kullanmamız ve her zaman canlı olarak dinlenmesi bu değerlerin
                            Expanded(
                              child: Slider(
                                  inactiveColor: Colors.blue,
                                  activeColor: Colors.blue,
                                  thumbColor: Colors.blue,
                                  min:
                                      Duration(seconds: 0).inSeconds.toDouble(),
                                  max: controller.max.value,
                                  value: controller.value.value,
                                  onChanged: (newvalue) {
                                    controller.changeDurationToSecons(
                                        newvalue.toInt());
                                  }),
                            ),
                            Text(controller.duration.value),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (controller.playindex.value > 0) {
                                controller.playSong(
                                  widget
                                      .data[controller.playindex.value - 1].uri,
                                  controller.playindex.value - 1,
                                );
                              }
                            },
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              size: 40,
                            ),
                          ),
                          Obx(
                            () => Container(
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: () {
                                  if (controller.isplaying == true) {
                                    controller.audioplayer.pause();
                                    controller.isplaying(false);
                                  } else {
                                    controller.audioplayer.play();
                                    controller.isplaying(true);
                                  }
                                },
                                icon: controller.isplaying == true
                                    ? Icon(
                                        Icons.pause,
                                        color: Colors.blue,
                                        size: 54,
                                      )
                                    : Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 54,
                                      ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (controller.playindex.value !=
                                  widget.data.length - 1) {
                                controller.playSong(
                                    widget.data[controller.playindex.value + 1]
                                        .uri,
                                    controller.playindex.value + 1);
                              } else {}
                            },
                            icon: Icon(
                              Icons.skip_next_rounded,
                              size: 40,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
