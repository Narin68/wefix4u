import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ocs_auth/models/response.dart';
import 'package:intl/intl.dart';
import '../request_service/sound.dart';
import 'package:path/path.dart' as Path;

Future<MResponse> sendVoiceFirebase(AudioResult? file) async {
  final fullName =
      "message/audio/MA${DateFormat("ddMMyyyy").format(DateTime.now())}${DateTime.now().millisecond}.m4a";

  final storageRef = FirebaseStorage.instance.ref();
  final mountainsRef = storageRef.child("$fullName");
  try {
    await mountainsRef.putFile(file!.file);
    final url = await mountainsRef.getDownloadURL();
    String after = url.split("googleapis.com").last;
    return MResponse(error: false, data: after);
  } catch (e) {
    return MResponse(error: true);
  }
}

Future<MResponse> sendImageFirebase(XFile images) async {
  var ex = images.path.split(".").last;
  final fullName =
      "message/image/MI${DateFormat("ddMMyyyy").format(DateTime.now())}${DateTime.now().millisecond}.${ex}";
  File file = File(images.path);
  final storageRef = FirebaseStorage.instance.ref();
  final mountainsRef = storageRef.child("$fullName");
  try {
    await mountainsRef.putFile(file);
    final url = await mountainsRef.getDownloadURL();
    String after = url.split("googleapis.com").last;
    return MResponse(error: false, data: after);
  } catch (e) {
    print("Error send image firebase => ${e}");
    return MResponse(error: true);
  }
}

Future deleteFirebaseImage(String url) async {
  try {
    var fileUrl = Uri.decodeFull(Path.basename(url))
        .replaceAll(new RegExp(r'(\?alt).*'), '');
    print("Image url $fileUrl");

    final firebaseStorageRef = FirebaseStorage.instance.ref().child(fileUrl);
    await firebaseStorageRef.delete();
    print("Success delete image");
  } catch (e) {
    print("Delete Image => ${e}");
  }
}

playAudio(AudioPlayer player) async {
  await player.play(player.source!);
}

/// Compulsory
pauseAudio(AudioPlayer player) async {
  await player.pause();
}

stopAudio(AudioPlayer player) async {
  await player.stop();
}

/// Optional
void seekToSec(int sec, AudioPlayer player) {
  Duration newPos = Duration(seconds: sec);
  player.seek(newPos); // Jumps to the given position within the audio file
}

/// Optional
String getTimeString(int seconds) {
  String minuteString =
      '${(seconds / 60).floor() < 10 ? 0 : ''}${(seconds / 60).floor()}';
  String secondString = '${seconds % 60 < 10 ? 0 : ''}${seconds % 60}';
  return '$minuteString:$secondString';
}
