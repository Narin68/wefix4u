import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:record/record.dart';

class AudioRecorder extends StatefulWidget {
  final void Function(AudioResult?) onDone;

  const AudioRecorder({required this.onDone});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  Uint8List? bytes;
  File? file;
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final _audioRecorder = Record();
  double value = 0;
  String path = '';
  late var _util = OCSUtil.of(context);

  @override
  void initState() {
    _isRecording = true;
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRecordStopControl(),
        const SizedBox(height: 10),
        Txt(
          "${_recordDuration >= 60 ? "1 : 00" : "0 : ${_recordDuration < 10 ? "0${_recordDuration}" : _recordDuration}"}",
          style: TxtStyle()
            ..fontSize(12)
            ..textColor(OCSColor.text.withOpacity(0.5)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Parent(
              gesture: Gestures()
                ..onTap(() {
                  _util.navigator.pop();
                }),
              style: ParentStyle()
                ..width(80)
                ..height(35)
                ..background.color(Colors.grey.withOpacity(.3))
                ..borderRadius(all: 5)
                ..alignmentContent.center()
                ..ripple(true),
              child: Txt(
                "${_util.language.key("cancel")}",
                style: TxtStyle()
                  ..textColor(OCSColor.text)
                  ..textAlign.center()
                  ..fontSize(13)
                  ..width(100),
              ),
            ),
            SizedBox(width: 10),
            Parent(
              gesture: Gestures()
                ..onTap(() async {
                  if (_recordDuration < 1) {
                    return;
                  } else {
                    if (bytes == null) await _stop();
                    widget.onDone(
                      AudioResult(
                        inSeconds: _recordDuration,
                        bytes: bytes!,
                        file: file!,
                        path: path,
                      ),
                    );
                    Navigator.pop(context);
                  }
                }),
              style: ParentStyle()
                ..width(80)
                ..height(35)
                ..ripple(true)
                ..background.color(Colors.blue.withOpacity(0.9))
                ..borderRadius(all: 5)
                ..alignmentContent.center(),
              child: Txt(
                "${_util.language.key("done")}",
                style: TxtStyle()
                  ..textColor(Colors.white)
                  ..fontSize(13),
              ),
            ),
          ],
        ),
        SizedBox(height: _util.query.bottom),
      ],
    );
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_isRecording && !_isPaused) {
      icon = const Icon(Icons.mic, color: Colors.red, size: 40);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 40);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: CircularProgressIndicator(value: value),
        ),
        ClipOval(
          child: Material(
            color: color,
            child: InkWell(
              child: SizedBox(width: 100, height: 100, child: icon),
              onTap: () async {
                if (!_isRecording) {
                  await _start();
                } else if (_recordDuration < 60 && !_isPaused) {
                  await _pause();
                } else if (_isPaused) {
                  await _resume();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
          _recordDuration = 0;
          value = 0;
        });

        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    file = null;
    bytes = null;
    setState(() {});

    final audioPath = await _audioRecorder.stop();

    if (audioPath != null) {
      path = audioPath.replaceAll('file://', '');
      file = await _localFile(audioPath);
      bytes = await file?.readAsBytes();
      setState(() => _isRecording = false);
    }
  }

  Future<File> _localFile(String path) async {
    return File('${path.replaceAll('file://', '')}').create();
  }

  Future<void> _pause() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();
    file = null;
    bytes = null;

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _recordDuration++;
      value = _recordDuration / 60;
      setState(() {});
      if (_recordDuration > 59) {
        _stop();
      }
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      setState(() {});
    });
  }
}

class AudioResult {
  int inSeconds;
  File file;
  Uint8List bytes;
  String path;

  AudioResult(
      {required this.inSeconds,
      required this.bytes,
      required this.file,
      required this.path});
}
