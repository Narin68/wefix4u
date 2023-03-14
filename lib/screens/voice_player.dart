import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:lottie/lottie.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';

class VoicePlayer extends StatefulWidget {
  final Function()? onDone;
  final String? url;

  const VoicePlayer({Key? key, this.onDone, this.url}) : super(key: key);

  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer>
    with SingleTickerProviderStateMixin {
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  late AnimationController _controller;
  var _util;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _util = OCSUtil.of(context);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _controller.reset();
    _startPlayer(path: widget.url, onDone: widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _disposePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle()
        ..padding(all: 10)
        ..height(200)
        ..borderRadius(topRight: 5, topLeft: 5)
        ..background.color(Colors.white),
      child: Stack(
        children: [
          Parent(
            style: ParentStyle()..width(_util.query.width),
            child: SizedBox(
              height: 170,
              child: Lottie.asset(
                'assets/gifs/play-sound.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller.forward();
                  _controller.repeat();
                },
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Remix.close_line),
            ),
          )
        ],
      ),
    );
  }

  Future _stopPlaying() async {
    _audioPlayer.stopPlayer();
    setState(() {});
  }

  Future _startPlayer({String? path, Function? onDone}) async {
    final fileUri = path;

    if (fileUri!.isNotEmpty) {
      await _audioPlayer.startPlayer(
        fromURI: path,
        codec: Codec.aacADTS,
        whenFinished: () {
          _controller.stop();
          _stopPlaying();
          onDone!();
        },
      );
      setState(() {});
    }
  }

  Future _disposePlayer() async {
    _audioPlayer.closeAudioSession();
    _audioPlayer = FlutterSoundPlayer();
  }

  Future _initPlayer() async {
    _audioPlayer.openAudioSession();
  }
}
