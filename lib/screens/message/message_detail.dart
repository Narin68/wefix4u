import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ocs_auth/models/response.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remixicon/remixicon.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import '/blocs/count_message/count_message_cubit.dart';
import '../request_service/view_image.dart';
import '/screens/message/delete_dialog.dart';
import '/screens/widget.dart';
import '/blocs/message/message_bloc.dart';
import '/modals/message.dart';
import '/repositories/message_repo.dart';
import '../function_temp.dart';
import '../request_service/sound.dart';
import '/globals.dart';
import 'package:intl/intl.dart' as intl;
import 'message_function.dart';
import 'message_widget.dart';

class MessageDetail extends StatefulWidget {
  final int? receiverId;
  final String? receiverImage;
  final String? receiverName;
  final int? requestId;
  final String? requestStatus;

  const MessageDetail({
    Key? key,
    this.receiverId,
    this.receiverImage,
    this.receiverName,
    this.requestId,
    this.requestStatus = '',
  }) : super(key: key);

  @override
  State<MessageDetail> createState() => _MessageDetailState();
}

class _MessageDetailState extends State<MessageDetail>
    with SingleTickerProviderStateMixin {
  ScrollController _scrCtrl = ScrollController();
  late var _util = OCSUtil.of(context);
  MessageRepo _messageRepo = MessageRepo();
  int _receiverId = 0;
  TextEditingController _textController = TextEditingController();
  List<MMessageData> _messageData = [];
  List<MMessageData> _messageAudios = [];
  List<XFile> _images = [];
  XFile? _image;
  AudioPlayer audioPlayer = AudioPlayer();
  List<AudioPlayer> _audioPlayers = [];
  List<PlayerState> _playerStates = [];
  List<int> _timeProgress = [];
  List<int> _audioDuration = [];
  PlayerState playerState = PlayerState.paused;
  AudioResult? _voiceData;
  MMessageData? _updateMessageData;
  List<MMessageData> _messageImg = [];
  double _value = 0;
  String _firebaseServer = Globals.firebaseServer;

  @override
  void initState() {
    super.initState();
    Globals.inMessagePage = true;
    Globals.requestId = widget.requestId ?? 0;
    _receiverId = widget.receiverId ?? -1;
    _initBloc();
    _scrCtrl.addListener(onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _scrCtrl.removeListener(onScroll);
    for (var i = 0; i < _audioPlayers.length; i++) {
      _audioPlayers[i].stop();
      _audioPlayers[i].dispose();
      _audioPlayers[i].release();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Globals.inMessagePage = false;
        Globals.requestId = 0;
        context.read<MessageBloc>().add(ReloadMessage());
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: buildTopTitle(widget.receiverName, widget.receiverImage),
        ),
        body: Parent(
          style: ParentStyle()..height(_util.query.height),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildList(),
              if (widget.requestStatus?.toUpperCase() !=
                      RequestStatus.rejected &&
                  widget.requestStatus?.toUpperCase() !=
                      RequestStatus.canceled &&
                  widget.requestStatus?.toUpperCase() != RequestStatus.done &&
                  widget.requestStatus?.toUpperCase() != RequestStatus.giveUp)
                _buildBottom(),
            ],
          ),
        ),
      ),
    );
  }

  void _initBloc() async {
    context.read<MessageBloc>()
      ..add(ReloadMessage())
      ..add(FetchMessage(
          receiverId: _receiverId, requestId: widget.requestId, isInit: true));

    context.read<CountMessageCubit>().setCountMessage(0);
  }

  Future onScroll() async {
    var max = _scrCtrl.position.maxScrollExtent;
    var _curr = _scrCtrl.position.pixels;

    if (_curr >= max - 50) {
      context.read<MessageBloc>().add(
          FetchMessage(receiverId: _receiverId, requestId: widget.requestId));
      if (mounted) setState(() {});
    }
  }

  Future _sendMessage() async {
    if (_receiverId == 0) return;

    MMessageData data = MMessageData(
      contentMsg: _voiceData != null ? "" : _textController.text,
      receivers: [_receiverId.toString()],
      status: "U",
      sender: Model.userInfo.loginName,
      contentType: _images.isNotEmpty
          ? "I"
          : _voiceData != null
              ? "A"
              : "T",
      direction:
          Globals.userType.toLowerCase() == UserType.customer ? "C2P" : "P2C",
      deleteStatus: null,
      requestId: widget.requestId ?? 0,
      completed: false,
      createdDate: DateTime.now().add(Duration(minutes: 2)).toString(),
      createdBy: Model.userInfo.loginName,
      id: 0,
    );

    context.read<MessageBloc>().add(AddMessage(data: data));
    String contentUrl = '';

    if (_images.isNotEmpty) {
      _image = _images[0];
      _images = [];
      var res = await sendImageFirebase(_image!);
      if (!res.error) {
        contentUrl = res.data;
      } else {
        return;
      }
    }

    if (_voiceData != null) {
      var res = await sendVoiceFirebase(_voiceData);
      if (!res.error) {
        contentUrl = res.data;
      } else {
        return;
      }
    }

    MSendMessage model = MSendMessage(
      contentMsg: _voiceData != null ? "" : _textController.text,
      receivers: [_receiverId == -1 ? 0 : _receiverId],
      status: "U",
      sender: Model.userInfo.loginName,
      contentType: _image != null
          ? "I"
          : _voiceData != null
              ? "A"
              : "T",
      direction: _receiverId == -1
          ? "C2S"
          : Globals.userType.toLowerCase() == UserType.customer
              ? "C2P"
              : "P2C",
      deleteStatus: "U",
      requestId: widget.requestId ?? 0,
      contentUrl: contentUrl,
      id: 0,
    );
    _textController.clear();
    _voiceData = null;
    _images = [];
    _image = null;
    MResponse _res = await _messageRepo.sendMessage(model);
    if (!_res.error) {
      MMessageData responseData = _res.data;
      context
          .read<MessageBloc>()
          .add(UpdateLastMessage(data: responseData.copyWith(completed: true)));
    } else {
      if (model.contentType == "I")
        await deleteFirebaseImage("${_firebaseServer}${contentUrl}");
      context.read<MessageBloc>().add(DeleteMessage(id: 0));
      _util.snackBar(status: SnackBarStatus.danger, message: _res.message);
    }
  }

  Future _updateMessage() async {
    if (_receiverId == 0) return;

    MMessageData? data = _updateMessageData?.copyWith(
      updatedBy: Model.userInfo.loginName,
      updatedDate: DateTime.now().toString(),
      contentType: _textController.text,
      receivers: [_receiverId.toString()],
    );
    _updateData(data);

    MSendMessage model = MSendMessage(
      contentMsg: _textController.text,
      receivers: [_receiverId == -1 ? 0 : _receiverId],
      status: _updateMessageData?.status,
      sender: _updateMessageData?.sender,
      contentType: _updateMessageData?.contentType,
      direction:
          Globals.userType.toLowerCase() == UserType.customer ? "C2P" : "P2C",
      deleteStatus: "U",
      requestId: widget.requestId ?? 0,
      contentUrl: _updateMessageData?.contentUrl ?? "",
      id: _updateMessageData?.id,
    );

    _textController.clear();
    _updateMessageData = null;
    MResponse _res = await _messageRepo.updateMessage(model);
    if (!_res.error) {
      MMessageData responseData = _res.data;
      responseData = responseData.copyWith(completed: true);
      _updateData(responseData);
    } else {
      _updateData(data);
      _util.snackBar(status: SnackBarStatus.danger, message: _res.message);
    }
  }

  void _updateData(MMessageData? data) {
    context
        .read<MessageBloc>()
        .add(UpdateMessage(data: data ?? MMessageData()));

    setState(() {});
  }

  Future _deleteMessage(MMessageData? data, bool forAll) async {
    _util.pop();
    String deleteStatus = forAll
        ? "A"
        : data?.sender == Model.userInfo.loginName
            ? "SI"
            : "RI";
    MResponse _res =
        await _messageRepo.deleteMessage(data?.id ?? 0, deleteStatus);
    _updateData(data?.copyWith(deleteStatus: deleteStatus));
    if (!_res.error) {
      MMessageData responseData = _res.data;
      if (responseData.deleteStatus == "A" && responseData.contentType == "I") {
        await deleteFirebaseImage(
          "${_firebaseServer}${data?.contentUrl}",
        );
      }
      _updateData(_res.data);
    } else {
      _updateData(data);
      _util.snackBar(status: SnackBarStatus.danger, message: _res.message);
    }
  }

  Future _addVoice() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      var statuses = await Permission.microphone.request();
      if (statuses.isGranted) _shoModalRecord();
    }
    if (await Permission.speech.isPermanentlyDenied) {
      openAppSettings();
    }
    if (status.isGranted && !status.isDenied) {
      _shoModalRecord();
    }
  }

  void _shoModalRecord() {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            AudioRecorder(onDone: (
              file,
            ) async {
              if (file != null) {
                _voiceData = file;
                await _sendMessage();
                setState(() {});
              }
            }),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Future _getImage() async {
    var _res = await getImageByGallery();
    if (_res != null) {
      _images = [];
      _images.add(_res);
      _util.navigator.pop();
    }
    setState(() {});
  }

  Future _getImageByTakeCamera() async {
    final XFile? image = await getImageByTakeCamera();
    if (image != null) {
      _images.add(image);
      _util.navigator.pop();
    }
    setState(() {});
  }

  void showMessageAction(MMessageData? data) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return buildMessageAction(_util, data: data, onTabDelete: () {
          _onTabDelete(data);
        }, onTapUpdateMessage: () {
          _onTapUpdateMessage(data);
        });
      },
    );
  }

  void _onTapUpdateMessage(MMessageData? data) {
    _util.pop();
    _updateMessageData = data;
    _textController.text = data?.contentMsg ?? "";
    setState(() {});
  }

  void _onTabDelete(MMessageData? data) {
    _util.pop();
    showDialog(
      context: context,
      builder: (_) {
        return DeleteDialog(
            onSubmit: (v) async {
              await _deleteMessage(data, v);
            },
            data: data!);
      },
    );
  }

  void _onClearUpdateMessage() {
    _updateMessageData = null;
    _textController.clear();
    setState(() {});
  }

  Future _initAudio(List<MMessageData> list) async {
    List<MMessageData> data = [];
    data = list.where((e) => e.contentType == "A").toList();
    if (data.isEmpty) return;

    for (var i = 0; i < data.length; i++) {
      _audioPlayers.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      _playerStates.add(PlayerState.paused);
      _audioDuration.add(0);
      _timeProgress.add(0);
      _audioPlayers[i].onPlayerStateChanged.listen((PlayerState state) {
        if (_playerStates[i] != PlayerState.paused)
          _audioPlayers[i].setSourceUrl(
            _firebaseServer + "${data[i].contentUrl}",
          );
        if (mounted)
          setState(() {
            _playerStates[i] = state;
          });
      });

      /// Optional
      _audioPlayers[i].setSourceUrl(
        _firebaseServer + "${data[i].contentUrl}",
      );
      _audioPlayers[i].onDurationChanged.listen((Duration duration) {
        if (mounted)
          setState(() {
            _audioDuration[i] = duration.inSeconds;
          });
      });
      _audioPlayers[i].onPositionChanged.listen((Duration position) async {
        if (_audioDuration[i] == position.inSeconds) {
          _value = position.inSeconds / _audioDuration[i];
          if (mounted) setState(() {});
          await Future.delayed(Duration(seconds: 1));
          stopAudio(_audioPlayers[i]);
          _value = 0;
          return;
        }
        if (mounted)
          setState(() {
            _timeProgress[i] = position.inSeconds;
            _value = position.inSeconds / _audioDuration[i];
          });
      });
    }
    setState(() {});
  }

  Widget _buildList() {
    return Expanded(
      child: BlocConsumer<MessageBloc, MessageState>(
        listener: (context, s) {
          if (s is MessageSuccess) {
            _messageData = s.data ?? [];
            _messageAudios =
                _messageData.where((e) => e.contentType == "A").toList();
            _messageImg =
                _messageData.where((e) => e.contentType == "I").toList();

            _messageAudios.removeWhere((e) =>
                (e.deleteStatus == "A") ||
                (e.deleteStatus == "RI" &&
                    e.sender != Model.userInfo.loginName) ||
                (e.sender == Model.userInfo.loginName &&
                    e.deleteStatus == "SI"));
            _initAudio(_messageAudios);
            setState(() {});
          }
        },
        builder: (context, s) {
          if (s is MessageLoading)
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );

          if (s is MessageFailure)
            return Center(
              child: BuildErrorBloc(
                message: "error",
                onRetry: _initBloc,
              ),
            );

          if (s is MessageSuccess) {
            if (s.data?.isEmpty ?? true)
              return buildNoData(_util.language.key('no-message'));
            var list = s.data
                ?.map((d) => intl.DateFormat("yyyyMMdd")
                    .format(DateTime.parse(d.createdDate ?? "")))
                .toSet()
                .toList();
            list?.sort();
            var res = list
                ?.map((c) => s.data!
                    .where((d) => (c ==
                        intl.DateFormat("yyyyMMdd")
                            .format(DateTime.parse(d.createdDate ?? ""))))
                    .toList())
                .toList();
            List<String> _dateList = [];

            res?.forEach((e) {
              e.removeWhere((el) =>
                  (el.contentType == "T" && el.contentMsg == "") ||
                  (el.deleteStatus == "A") ||
                  (el.deleteStatus == "RI" &&
                      el.sender != Model.userInfo.loginName) ||
                  (el.sender == Model.userInfo.loginName &&
                      el.deleteStatus == "SI"));
            });

            res?.removeWhere((e) => e.isEmpty);

            res?.forEach((e) {
              _dateList.add(e[0].createdDate ?? "");
            });

            _dateList = _dateList.reversed.toList();
            res = res?.reversed.toSet().toList();

            if (_dateList.isEmpty)
              return buildNoData(_util.language.key('no-message'));

            return ListView.builder(
              shrinkWrap: true,
              reverse: true,
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrCtrl,
              padding: EdgeInsets.all(15),
              itemCount: _dateList.isEmpty
                  ? 0
                  : s.hasMax!
                      ? _dateList.toSet().length
                      : (_dateList.toSet().length) + 1,
              itemBuilder: (_, i) {
                return i >= (_dateList.length)
                    ? Parent(
                        style: ParentStyle()
                          ..width(_util.query.width)
                          ..padding(vertical: 15),
                        child: Center(
                          child: SizedBox(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                            height: 25,
                            width: 25,
                          ),
                        ),
                      )
                    : StickyHeader(
                        header: Parent(
                          style: ParentStyle()..background.color(Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 10),
                              Txt(
                                OCSUtil.dateFormat(
                                  DateTime.parse(_dateList[i]),
                                  format: Format.date,
                                  langCode: Globals.langCode,
                                ),
                                style: TxtStyle()
                                  ..bold()
                                  ..fontSize(Style.subTextSize)
                                  ..textColor(OCSColor.text.withOpacity(0.7)),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                        overlapHeaders: true,
                        content: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(top: 25, bottom: 5),
                          primary: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: res?[i].length ?? 0,
                          itemBuilder: (_, j) {
                            res?[i].sort((a, b) =>
                                DateTime.parse(a.createdDate ?? "").compareTo(
                                    DateTime.parse(b.createdDate ?? "")));
                            MMessageData? data = res?[i][j];
                            return _buildChatMessage(data);
                          },
                        ),
                      );
              },
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget _buildChatMessage(MMessageData? data) {
    return data?.sender == Model.userInfo.loginName
        ? _buildSender(data)
        : _buildReceiver(data);
  }

  Widget _buildSender(MMessageData? data) {
    return data?.contentType == "I"
        ? buildImageSection(_util,
            data: data,
            type: "sender",
            onLongPress: () {
              showMessageAction(data);
            },
            image: _image,
            onPress: () {
              int index = _messageImg.indexWhere((e) => e.id == data?.id);

              if (index >= 0)
                _util.to(ViewMultiImage(
                  paths: _messageImg
                      .map((e) => "${_firebaseServer + (e.contentUrl ?? "")}")
                      .toList(),
                  index: index,
                  path: _firebaseServer + (data?.contentUrl ?? ""),
                  isXFile: false,
                  showNum: false,
                ));
            })
        : data?.contentType == "A"
            ? _buildVoice(data, type: "sender")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Parent(
                    gesture: Gestures()
                      ..onLongPress(() {
                        showMessageAction(data);
                      }),
                    style: ParentStyle()
                      ..padding(horizontal: 5, top: 5, bottom: 0),
                    child: Txt(
                      data?.contentMsg ?? "",
                      style: TxtStyle()
                        ..padding(all: 10)
                        ..textAlign.right()
                        ..background.color(OCSColor.blue.withOpacity(0.1))
                        ..borderRadius(
                            topRight: 10, bottomLeft: 10, topLeft: 10)
                        ..fontSize(Style.subTextSize)
                        ..textColor(OCSColor.text.withOpacity(0.7)),
                    ),
                  ),
                  buildTimeRight(_util, data: data),
                ],
              );
  }

  Widget _buildVoice(MMessageData? data, {String? type}) {
    int index = _messageAudios.indexWhere((v) => v.id == data?.id);
    if (index < 0) return SizedBox();
    return Parent(
      style: ParentStyle(),
      gesture: Gestures(),
      child: Column(
        crossAxisAlignment: type == "sender"
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Parent(
            style: ParentStyle()
              ..width(_util.query.width / 2)
              ..margin(top: 10)
              ..borderRadius(all: 20)
              ..overflow.hidden()
              ..background.color(Colors.blue),
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value:
                      _playerStates[index] == PlayerState.playing ? _value : 0,
                  backgroundColor: Colors.transparent,
                  color: Colors.black12,
                  minHeight: 30,
                ),
                Parent(
                  gesture: Gestures()
                    ..onTap(() {
                      if (data?.completed == false ||
                          _audioDuration[index] <= 0) return;
                      if (_playerStates[index] != PlayerState.playing) {
                        for (var i = 0; i < _playerStates.length; i++) {
                          if (_playerStates[i] == PlayerState.playing) {
                            stopAudio(_audioPlayers[i]);
                          }
                        }
                        playAudio(_audioPlayers[index]);

                        return;
                      }

                      if (_playerStates[index] == PlayerState.playing) {
                        pauseAudio(_audioPlayers[index]);
                      } else {
                        playAudio(_audioPlayers[index]);
                      }
                    })
                    ..onLongPress(() {
                      showMessageAction(data);
                    }),
                  style: ParentStyle()
                    ..width(_util.query.width / 2)
                    ..height(30)
                    // ..margin(top: 10)
                    ..borderRadius(all: 20)
                    ..background.color(Colors.transparent),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 5),
                      Icon(
                        _playerStates[index] == PlayerState.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white,
                          height: 2,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      ((data?.completed ?? false) && _audioDuration[index] > 0)
                          ? Txt(
                              getTimeString(_audioDuration[index]),
                              style: TxtStyle()
                                ..fontSize(11)
                                ..textColor(Colors.white),
                            )
                          : Parent(
                              style: ParentStyle()..margin(left: 5),
                              child: SizedBox(
                                child: CircularProgressIndicator(
                                    strokeWidth: 1, color: Colors.white),
                                width: 17,
                                height: 17,
                              ),
                            ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          type == "sender"
              ? buildTimeRight(_util, data: data)
              : buildTimeLeft(_util, data: data),
        ],
      ),
    );
  }

  Widget _buildReceiver(MMessageData? data) {
    return data?.contentType == "I"
        ? buildImageSection(_util,
            data: data,
            type: "receiver",
            onLongPress: () {
              showMessageAction(data);
            },
            image: _image,
            onPress: () {
              int index = _messageImg.indexWhere((e) => e.id == data?.id);

              if (index >= 0)
                _util.to(ViewMultiImage(
                  paths: _messageImg
                      .map((e) => "${_firebaseServer + (e.contentUrl ?? "")}")
                      .toList(),
                  index: index,
                  path: _firebaseServer + (data?.contentUrl ?? ""),
                  isXFile: false,
                  showNum: false,
                ));
            })
        : data?.contentType == "A"
            ? _buildVoice(data, type: "receiver")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Parent(
                    gesture: Gestures()
                      ..onLongPress(() {
                        showMessageAction(data);
                      }),
                    style: ParentStyle()
                      ..padding(all: 10)
                      ..background.color(OCSColor.background)
                      ..borderRadius(
                        bottomRight: 10,
                        topLeft: 10,
                        topRight: 10,
                      ),
                    child: Column(
                      children: [
                        Txt(
                          data?.contentMsg ?? "",
                          style: TxtStyle()
                            ..fontSize(Style.subTextSize)
                            ..textColor(OCSColor.text.withOpacity(0.7)),
                        ),
                        // Icon(Remix.check_double_line, size: 16),
                      ],
                      // crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                  ),
                  buildTimeLeft(_util, data: data),
                ],
              );
  }

  Future _removeImage() async {
    _images.removeAt(0);
    setState(() {});
  }

  Widget _buildBottom() {
    return Parent(
      style: ParentStyle()
        ..width(MediaQuery.of(context).size.width)
        ..minHeight(40)
        ..borderRadius(all: 10)
        ..alignmentContent.center()
        ..boxShadow(color: Colors.black12, blur: 10, offset: Offset(-1, 0))
        ..background.color(OCSColor.background),
      child: Column(
        children: [
          buildImageSend(_util, images: _images, onRemove: _removeImage),
          if (_updateMessageData != null)
            Parent(
              style: ParentStyle()..padding(all: 5, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Txt(
                    "Edit message",
                    style: TxtStyle()
                      ..fontSize(12)
                      ..bold()
                      ..textColor(Colors.blue),
                  ),
                  Row(
                    children: [
                      if (_updateMessageData?.contentUrl?.isNotEmpty ?? false)
                        Parent(
                          style: ParentStyle()
                            ..borderRadius(all: 5)
                            ..overflow.hidden(),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: MyNetworkImage(
                                iconSize: 20,
                                url: _firebaseServer +
                                    (_updateMessageData?.contentUrl ?? "")),
                          ),
                        ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Txt(
                          _updateMessageData?.contentMsg ?? "",
                          style: TxtStyle()
                            ..fontSize(12)
                            ..textOverflow(TextOverflow.ellipsis)
                            ..maxLines(1)
                            ..textColor(OCSColor.text.withOpacity(0.7)),
                        ),
                      ),
                      SizedBox(width: 5),
                      InkWell(
                          onTap: _onClearUpdateMessage,
                          child: Icon(
                            Remix.close_circle_line,
                            color: Colors.black87,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: 5),
              if (_updateMessageData == null)
                Parent(
                  gesture: Gestures()
                    ..onTap(() {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (BuildContext context) {
                          return buildImageAction(_util,
                              getImage: _getImage,
                              getImageByCamera: _getImageByTakeCamera);
                        },
                      );
                    }),
                  style: ParentStyle()
                    ..padding(all: 10)
                    ..ripple(true)
                    ..margin(bottom: 5)
                    ..background.color(Colors.transparent)
                    ..borderRadius(all: 50),
                  child: Icon(
                    Icons.image,
                    size: 20,
                    color: Color(0xff34495E),
                  ),
                ),
              if (_updateMessageData == null)
                Parent(
                  gesture: Gestures()..onTap(_addVoice),
                  style: ParentStyle()
                    ..padding(all: 10)
                    ..ripple(true)
                    ..margin(right: 5, bottom: 5)
                    ..background.color(Colors.transparent)
                    ..borderRadius(all: 50),
                  child: Icon(
                    Icons.mic,
                    size: 20,
                    color: Color(0xff34495E),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.only(
                      left: 10,
                      top: 5,
                      bottom: 20,
                      right: 10,
                    ),
                    hintText: "Write a message...",
                    hintStyle: TextStyle(
                      color: OCSColor.text.withOpacity(0.6),
                    ),
                  ),
                  style: TextStyle(fontSize: 14, color: OCSColor.text),
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                ),
              ),
              Parent(
                gesture: Gestures()
                  ..onTap(_updateMessageData == null
                      ? _sendMessage
                      : _updateMessage),
                style: ParentStyle()
                  ..padding(all: 10)
                  ..ripple(true)
                  ..margin(left: 10, bottom: 5)
                  ..background.color(Colors.transparent)
                  ..borderRadius(all: 50),
                child: Icon(
                  Icons.send,
                  size: 18,
                  color: Color(0xff34495E),
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
        ],
      ),
    );
  }
}
