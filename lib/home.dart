import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musick/player.dart';
import 'package:musick/player_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DeviceModel? deviceModel; // Nullable olarak tanımladık

  @override
  void initState() {
    super.initState();
    getDevice(); // Cihaz bilgilerini almak için çağrıldı
  }

  getDevice() async => deviceModel = await OnAudioQuery().queryDeviceInfo();

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
                color: Colors.blue,
              ))
        ],
        leading: Icon(
          Icons.short_text_rounded,
          color: Colors.blue,
          size: 40,
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Text(
          "Şarkılar",
          style: TextStyle(
              fontSize: 26, color: const Color.fromARGB(255, 221, 38, 38)),
        ),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: controller.audioquery.querySongs(
          SongSortType.DEFAULT,
          OrderType.ASC_OR_SMALLER,
          UriType.EXTERNAL,
          false,
        ),
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return CircularProgressIndicator();
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text("No songs"));
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  String songTitle = snapshot.data![index].displayNameWOExt;
                  // İlk 30 karakteri al
                  String shortenedTitle = songTitle.length > 30
                      ? songTitle.substring(0,
                              songTitle.length > 30 ? 30 : songTitle.length) +
                          '...'
                      : songTitle;

                  return Container(
                    child: Obx(
                      () => ListTile(
                        title: Text(
                          shortenedTitle,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          snapshot.data![index].artist,
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: QueryArtworkWidget(
                            id: snapshot.data![index].id,
                            type: ArtworkType.AUDIO,
                            artwork: snapshot.data![index].artwork ?? null,
                            deviceSDK: deviceModel!.sdk),
                        trailing: controller.playindex.value == index &&
                                controller.isplaying.value
                            ? Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              )
                            : null,
                        onTap: () {
                          Get.to(
                              () => Player(
                                    data: snapshot.data!,
                                  ),
                              transition: Transition.downToUp);

                          controller.playSong(snapshot.data![index].uri, index);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
