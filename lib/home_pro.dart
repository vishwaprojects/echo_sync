import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_music/channel_model.dart';
import 'package:our_music/music_model.dart';

final homeRef = ChangeNotifierProvider((ref) => HomePro());
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

class HomePro with ChangeNotifier {
  bool _isUploading = false;
  bool get isUpload => _isUploading;

  Future uploadSongtoStorage(File result, MusicModel model) async {
    try {
      _isUploading = true;
      notifyListeners();
      //Uint8List? fileBytes = result.files.first.bytes;
      String fileName = model.songname;
      //SettableMetadata({});
      // Upload file
      if (result != null) {
        await FirebaseStorage.instance
            .ref('musics/$fileName')
            .putFile(result, SettableMetadata(contentType: 'audio/mpeg'))
            .then((val) async {
          var a = await FirebaseStorage.instance
              .ref('musics/$fileName')
              .getDownloadURL();
          MusicModel music = MusicModel(
              songname: model.songname,
              songdescription: model.songdescription,
              downloadUrl: a);
          await FirebaseFirestore.instance
              .collection("music")
              .doc()
              .set(music.toMap());
          _isUploading = false;
          notifyListeners();
        });
      } else {
        print("***********************************");
      }
    } catch (e) {
      _isUploading = false;
      print(e);
      print("########################################");
      final SnackBar snackBar = SnackBar(content: Text("error : $e"));
      snackbarKey.currentState?.showSnackBar(snackBar);
      notifyListeners();
    }
  }

  String _connectId = 'something';
  String get connectId => _connectId;

  configConnectId(String a) {
    _connectId = a;
    notifyListeners();
  }

  createMusicChannel(ChannelModel channelModel) {
    FirebaseFirestore.instance
        .collection("channels")
        .doc(channelModel.uid)
        .set(channelModel.toMap());
  }

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  configPlaying(bool a) {
    _isPlaying = a;
    notifyListeners();
  }

  pauseAndPlay(String id, bool a) async {
    await FirebaseFirestore.instance
        .collection("channels")
        .doc(id)
        .update({"play": a});
  }

  updateMin(String id, int a) async {
    Future.delayed(Duration(seconds: 1));
    await FirebaseFirestore.instance
        .collection("channels")
        .doc(id)
        .update({"min": a});
  }

  updateSong(String id, String url) async {
    print("update");
    print(id);
    print(url);
    
    await FirebaseFirestore.instance
        .collection("channels")
        .doc(id)
        .update({"music": url});
  }
}
