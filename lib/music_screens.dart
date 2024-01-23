import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:our_music/channel_model.dart';
import 'package:our_music/home_pro.dart';
import 'package:our_music/music_model.dart';
import 'package:youtube_downloader/youtube_downloader.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen>
    with WidgetsBindingObserver {
  FilePickerResult? result;
  String vvv = '';
  final TextEditingController _song = TextEditingController();
  final TextEditingController _desp = TextEditingController();
  final TextEditingController _channel = TextEditingController();
  String a = '';
  final AudioPlayer _audioPlayer = AudioPlayer();
  List prevss = [];
  MusicModel? musicModel;
  Duration _sondDuration = Duration();
  bool isMusicPlaying = false;
  playSong(String uri, {bool? a}) async {
    try {
      if (uri != vvv) {
        vvv = uri;
        print("init");

        await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri)),
            preload: true);
        prevss.remove(uri);
      }
      _audioPlayer.durationStream.listen((event) {
        _sondDuration = event!;
      });
      if (a != null) {
        if (a) {
          if (!_audioPlayer.playing) {
            print("play");
            ref.read(homeRef).configPlaying(a);
            _audioPlayer.play();
          }
        } else {
          print("pause");
          ref.read(homeRef).configPlaying(a);
          _audioPlayer.pause();
        }
      }

      // _audioPlayer.play();
    } catch (e) {
      print("&&&&&&&&&&&&&&&&&&&&&&&&&&&");
      print(e);
    }
  }

  String prev = "";

  String channel = 'some';

  final BoxController boxController = BoxController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: SlidingBox(
        controller: boxController,
        backdrop: Backdrop(
            moving: false,
            fading: true,
            body: Consumer(
              builder: (context, ref, child) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("channels")
                      .doc(channel)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.exists) {
                        ChannelModel channelModel =
                            ChannelModel.fromMap(snapshot.data!.data()!);
                        // playSong(channelModel.music, a: channelModel.play);

                        // if (prevss.contains(channelModel.music)) {

                        // } else {
                        //   prevss.add(channelModel.music);
                        //   playSong(channelModel.music,a: channelModel.play);
                        // }
                        playSong(channelModel.music, a: channelModel.play);
                        // if (_audioPlayer.position.inSeconds !=
                        //     channelModel.min) {
                        //   _audioPlayer
                        //       .seek(Duration(seconds: channelModel.min));
                        // }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 24,
                            ),
                            Text(
                              "Connected to $channel",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(360),
                                child: Image.network(
                                    "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D"),
                              ),
                            ),
                            SizedBox(
                              height: 24,
                            ),
                            musicModel != null
                                ? Column(
                                    children: [
                                      Text(musicModel!.songname),
                                      Text(musicModel!.songdescription)
                                    ],
                                  )
                                : SizedBox(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: StreamBuilder(
                                stream: _audioPlayer.positionStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    ref.read(homeRef).updateMin(
                                        channel, snapshot.data!.inSeconds);
                                    return Row(
                                      children: [
                                        Text(snapshot.data!.inSeconds
                                            .toString()
                                            .split(".")[0]),
                                        Expanded(
                                            child: Slider(
                                          value: snapshot.data!.inSeconds
                                              .toDouble(),
                                          min: 0,
                                          max: _sondDuration.inSeconds
                                              .toDouble(),
                                          onChanged: (value) {
                                            var a = Duration(
                                                seconds: value.toInt());
                                            ref.read(homeRef).updateMin(
                                                channel, value.toInt());
                                            _audioPlayer.seek(a);
                                          },
                                        )),
                                        Text(_sondDuration
                                            .toString()
                                            .split(".")[0])
                                      ],
                                    );
                                  } else {
                                    return Expanded(
                                        child: Slider(
                                      value: 0,
                                      onChanged: (value) {},
                                    ));
                                  }
                                },
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final play = ref.watch(homeRef).isPlaying;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      play
                                          ? IconButton(
                                              onPressed: () async {
                                                _audioPlayer.pause();
                                                await ref
                                                    .read(homeRef)
                                                    .pauseAndPlay(
                                                        channel, !play);
                                                ref
                                                    .read(homeRef)
                                                    .configPlaying(!play);
                                              },
                                              icon: Icon(
                                                Icons.pause,
                                                size: 60,
                                              ))
                                          : IconButton(
                                              onPressed: () async {
                                                // _audioPlayer.play();
                                                await ref
                                                    .read(homeRef)
                                                    .pauseAndPlay(
                                                        channel, !play);
                                                ref
                                                    .read(homeRef)
                                                    .configPlaying(!play);
                                              },
                                              icon: Icon(
                                                Icons.play_arrow,
                                                size: 60,
                                              ),
                                            ),
                                    ],
                                  ),
                                );
                              },
                            )
                            //Text(channelModel.)
                          ],
                        );
                      } else {
                        return Center(child: Text("No Channel on this id"));
                      }
                    } else {
                      return Text("No Channel on this id");
                    }
                  },
                );
              },
            )),

        //implement room setting here
        collapsedBody: Column(
          children: [
            SizedBox(
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _channel,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Create Or Connect Channel",
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TextButton(
                //     onPressed: () {
                //       ChannelModel channelModel = ChannelModel(
                //           uid: _channel.text, music: a, play: false, min: 0);
                //       ref.read(homeRef).createMusicChannel(channelModel);
                //     },
                //     child: Text("Create")),
                TextButton(
                    onPressed: () {
                      channel = _channel.text;
                      setState(() {});
                    },
                    child: Text("Connect")),
              ],
            )
          ],
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance.collection("music").get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    a = snapshot.data!.docs[index].data()['downloadUrl'];
                    MusicModel model =
                        MusicModel.fromMap(snapshot.data!.docs[index].data());

                    return ListTile(
                      onTap: () async {
                        if (channel.isNotEmpty) {
                          print("########################################");
                          print(index);
                          musicModel = model;
                          await ref
                              .read(homeRef)
                              .updateSong(channel, model.downloadUrl);
                          boxController.closeBox();
                        }
                      },
                      trailing: Icon(Icons.play_arrow),
                      horizontalTitleGap: 0,
                      leading: Text(index.toString() + " )"),
                      title: Text(model.songname),
                      subtitle: Text(model.songdescription),
                    );
                  },
                ),
              );
            } else {
              return Text("No Data");
            }
          },
        ),
      ),
      // bottomSheet: Row(
      //   children: [
      //     Text("data"),
      //   ],
      // ),
      appBar: AppBar(
        title: Text("Music"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            isScrollControlled: true,
            showDragHandle: true,
            context: context,
            builder: (context) {
              return Consumer(
                builder: (context, ref, child) {
                  bool isUpload = ref.watch(homeRef).isUpload;
                  return isUpload
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SpinKitWaveSpinner(
                                color: Colors.black,
                                size: MediaQuery.of(context).size.height / 8,
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Text("Uploading")
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: StatefulBuilder(builder: (context, setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 24,
                                ),
                                InkWell(
                                  onTap: () async {
                                    result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['mp3'],
                                    );
                                    setState(
                                      () {},
                                    );
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      result != null
                                          ? result!.files.first.name.toString()
                                          : " Click to Upload th song",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: TextField(
                                    controller: _song,
                                    decoration: InputDecoration(
                                      hintText: "Song name",
                                    ),
                                  ),
                                ),
                                TextField(
                                  controller: _desp,
                                  decoration: InputDecoration(
                                    hintText: "Song description",
                                  ),
                                ),
                                SizedBox(
                                  height: 24,
                                ),
                                TextButton(
                                    onPressed: () {
                                      MusicModel model = MusicModel(
                                          songname: _song.text,
                                          songdescription: _desp.text,
                                          downloadUrl: "");
                                      if (result != null) {
                                        File audi = File(result!.paths[0]!);
                                        ref
                                            .read(homeRef)
                                            .uploadSongtoStorage(audi, model)
                                            .whenComplete(() {
                                          result = null;
                                          _song.clear();
                                          _desp.clear();
                                        });
                                      } else {
                                        print("@@@@@@@@@@");
                                      }
                                    },
                                    child: Text("Upload"))
                              ],
                            );
                          }),
                        );
                },
              );
            },
          );
        },
        child: Icon(Icons.music_note),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (AppLifecycleState.resumed == state) {
    //   FirebaseFirestore.instance
    //       .collection("channels")
    //       .doc(channel)
    //       .snapshots()
    //       .listen((event) {
    //     ChannelModel ch = ChannelModel.fromMap(event.data()!);
    //     playSong(ch.music, a: ch.play);
    //     if (_audioPlayer.position.inSeconds != ch.min) {
    //       _audioPlayer.seek(Duration(seconds: ch.min));
    //     }
    //   });
    // }
    super.didChangeAppLifecycleState(state);
  }
}
