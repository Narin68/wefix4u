import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:remixicon/remixicon.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../message/message_function.dart';
import '../service_request_widget.dart';
import '/functions.dart';
import '../function_temp.dart';
import '/screens/more/request_partner/widget.dart';
import '/screens/widget.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/globals.dart';
import '/modals/customer_request_service.dart';
import '/repositories/file_repo.dart';
import '/blocs/service/service_bloc.dart';
import '/modals/file.dart';
import '/repositories/request_service_repo.dart';
import 'view_image.dart';
import './sound.dart';

class StepTwoServiceForm extends StatefulWidget {
  const StepTwoServiceForm({Key? key}) : super(key: key);

  @override
  State<StepTwoServiceForm> createState() => _StepTwoServiceFormState();
}

class _StepTwoServiceFormState extends State<StepTwoServiceForm> {
  late final _util = OCSUtil.of(context);
  double audioCount = 1;
  double _labelSize = Style.subTextSize;
  List<XFile> _videos = [];
  final _audioRecorder = Record();

  List<XFile> _images = [];

  List<Uint8List> thumbnail = [];

  var dateNow = new DateTime.now();
  String urlRecordPath = '';
  List<Map> _audios = [];
  Timer? _timerDown;

  int second = 0;
  int progress = 0;
  var _descTxt = TextEditingController();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  ServiceBloc _serviceBloc = ServiceBloc();

  RequestServiceRepo _requestRepo = RequestServiceRepo();
  bool _loading = false;
  String _audioType = "Audio";
  String _videoType = "Video";
  String _imageType = "Image";
  List<MFile> _mFile = [];
  FileRepo _fileRepo = FileRepo();
  var menuStyle = ParentStyle()
    ..height(60)
    ..width(60)
    ..borderRadius(all: 100)
    ..borderRadius(all: 5)
    ..ripple(true)
    ..background.color(Colors.white)
    ..borderRadius(all: 5)
    ..boxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      offset: Offset(0, 0),
      blur: 2.0,
      spread: 1,
    )
    ..elevation(1, opacity: 0.3);

  String _dateString = '';
  DateTime? _dateTime;
  String _timeSelect = '';
  DateTime? _currDate;
  String _errorTime = '';
  List<AudioPlayer> _audioPlayers = [];
  List<PlayerState> _playerStates = [];
  List<int> _timeProgress = [];
  List<int> _audioDuration = [];
  double _value = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    for (var i = 0; i < _audioPlayers.length; i++) {
      _audioPlayers[i].stop();
      _audioPlayers[i].dispose();
      _audioPlayers[i].release();
    }
    _timerDown?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _loading ? null : _util.navigator.pop();

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: OCSColor.primary,
            title: Txt(
              _util.language.key('request-info'),
              style: TxtStyle()
                ..fontSize(16)
                ..textColor(Colors.white),
            ),
            leading: NavigatorBackButton(loading: _loading)),
        body: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              Parent(
                style: ParentStyle(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Parent(
                        style: ParentStyle()..padding(all: 16, top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15),
                            _buildDescSection(),
                            SizedBox(height: 10),
                            _buildSelectDateField(),
                            SizedBox(height: 15),
                            if (_images.isNotEmpty) ...[
                              _buildImageSection(),
                              SizedBox(height: 15),
                            ],
                            if (_videos.isNotEmpty) ...[
                              _buildVideoSection(),
                              SizedBox(height: 15),
                            ],
                            if (_audios.isNotEmpty) ...[
                              _buildVoiceList(),
                              SizedBox(height: 15),
                            ],
                            _buttonAction(),
                            SizedBox(height: 70),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              if (!_util.query.isKbPopup)
                Positioned(
                  // bottom: 0,
                  bottom: _util.query.bottom <= 0 ? 15 : 0,
                  child: Parent(
                    style: ParentStyle()
                      ..alignment.center()
                      ..padding(
                        horizontal: 16,
                      )
                      ..width(_util.query.width),
                    child: BuildButton(
                      title: _util.language.key('apply'),
                      fontSize: 16,
                      onPress: _onSubmit,
                    ),
                  ),
                ),
              if (_loading)
                Positioned(
                  child: Container(
                    color: Colors.black.withOpacity(.3),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future _onSubmit() async {
    if (_dateString.isNotEmpty && _timeSelect.isEmpty) {
      _errorTime = "error";
      setState(() {});
      return;
    }

    setState(() {
      _loading = true;
    });
    List<int> _serviceId = getServiceId();

    var location = ApplyServiceModel.address.isNotEmpty
        ? ApplyServiceModel.address + ", " + ApplyServiceModel.pinMap
        : "" + ApplyServiceModel.pinMap;
    MServiceUsage model =
        _mappingModel(servicesId: _serviceId, location: location);
    var res = await _requestRepo.requestService(model);
    if (!res.error) {
      List<MRequestService> data = res.data;
      _addRequest(data);
      _navigatorToSuccess();
      _uploadFile(data);
      if (data.isNotEmpty) {
        await _uploadVideo(data);
        await _deleteVideos();
      }
    } else {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    }

    // var result = await _requestRepo.checkAvailability(_serviceId, location);
    // if (!result.error) {
    //
    // } else {
    //   _util.snackBar(message: result.message, status: SnackBarStatus.danger);
    // }

    setState(() {
      _loading = false;
    });
  }

  List<int> getServiceId() {
    List<int> _serviceId = [];
    var state = _serviceBloc.state;
    if (state is ServiceSuccess) {
      state.selectData?.map((e) => {_serviceId.add(e.id ?? 0)}).toList();
    }
    return _serviceId;
  }

  MServiceUsage _mappingModel({String? location, servicesId}) {
    String dateFormat = ApplyServiceModel.date != null
        ? OCSUtil.dateFormat(_dateTime ?? "", format: "MM-dd-yyyy")
        : "";
    String timeFormat = ApplyServiceModel.time != null
        ? OCSUtil.dateFormat(_currDate ?? "", format: "HH:mm:ss")
        : ApplyServiceModel.date != null
            ? "07:00"
            : "";

    MServiceUsage model = MServiceUsage(
      customerCode: Model.customer.code,
      serviceIds: servicesId,
      targetLocation: location,
      lat: ApplyPartnerDataModel.lat.toString(),
      lng: ApplyPartnerDataModel.long.toString(),
      desc: ApplyServiceModel.description,
      contactPhone: ApplyServiceModel.phone,
      fixingDate: "$dateFormat $timeFormat",
      provinceId: ApplyServiceModel.provinceId,
    );

    return model;
  }

  void _addRequest(List<MRequestService> data) {
    if (Globals.tabRequestStatusIndex == 0 ||
        Globals.tabRequestStatusIndex == 1) {
      context.read<ServiceRequestBloc>().add(AddServiceRequest(data: data));
    }
  }

  Future _uploadFile(List<MRequestService> data) async {
    List<MFileUpload> files = [];
    if (_mFile.isNotEmpty) {
      data.forEach((e) async {
        for (int i = 0; i < _mFile.length; i++) {
          _mFile[i] = _mFile[i].copyWith(refId: e.id);
          var fileRes = await _fileRepo.uploadFile(_mFile[i]);
          if (!fileRes.error) {
            files.add(fileRes.data);
            if (i == _mFile.length - 1) {
              await _saveFileToDb(data, files);
              await _deleteImageAudio();
            }
          } else {
            _util.snackBar(
              message: fileRes.message,
              status: SnackBarStatus.danger,
            );
            break;
          }
        }
      });
    }
  }

  Future _uploadVideo(List<MRequestService> data) async {
    if (_videos.isEmpty) return;
    data.forEach((e) async {
      for (var i = 0; i < _videos.length; i++) {
        final fullName =
            "videos/service_request/SRQ${intl.DateFormat("ddMMyyyy").format(DateTime.now())}${DateTime.now().millisecond}.mp4";
        final name =
            "SRQ${intl.DateFormat("ddMMyyyy").format(DateTime.now())}${DateTime.now().millisecond}";

        File file = File(_videos[i].path);
        final storageRef = FirebaseStorage.instance.ref();
        final mountainsRef = storageRef.child("$fullName");
        try {
          await mountainsRef.putFile(file);
          final url = await mountainsRef.getDownloadURL();
          String after = url.split("googleapis.com").last;

          var _res = await _fileRepo.uploadVideo(
            url: after,
            refId: e.id,
            name: name,
            extension: "mp4",
          );

          if (_res.error) {
            _util.snackBar(
              message: _res.message,
              status: SnackBarStatus.danger,
            );

            continue;
          }
        } catch (e) {
          print("Error upload video => $e");
        }
      }
    });
  }

  Future _saveFileToDb(
      List<MRequestService> data, List<MFileUpload> files) async {
    if (data.length > 1) {
      for (var j = 1; j < data.length; j++) {
        var saveDbRes = await _fileRepo.saveFileToDb(MSaveFileToDb(
          files: files,
          refId: data[j].id,
          refType: "USE_SERVICE_REQ",
        ));
        if (!saveDbRes.error) {
        } else {
          _util.snackBar(
              message: saveDbRes.message, status: SnackBarStatus.danger);
        }
      }
    }
  }

  void _navigatorToSuccess() {
    _util.navigator.pop();
    _util.navigator.pop();
    _util.navigator.replace(BuildSuccessScreen(
      successTitle: _util.language.key('your-request-has-been-sent'),
    ));
  }

  Future _deleteImageAudio() async {
    _images.forEach((e) {
      deleteFile(File(e.path));
    });
  }

  Future _deleteVideos() async {
    _videos.forEach((e) {
      deleteFile(File(e.path));
    });
  }

  Future _getFileBytes(int refId) async {
    _mFile = [];
    if (_audios.isNotEmpty)
      _audios.forEach((e) async {
        await _mappingFile(path: e['Path'], ex: 'aac', refId: refId);
      });
    if (_images.isNotEmpty)
      _images.forEach((e) async {
        var ex = e.name.substring(e.name.lastIndexOf('.') + 1);
        await _mappingFile(path: e.path, ex: '$ex', refId: refId);
      });
  }

  Future _mappingFile({String? path, String? ex, int? refId}) async {
    _mFile.add(MFile(
      extension: ex,
      file: await _covertFileToBytes(path!),
      fileType: _getFileType(ex!),
      refType: 'USE_SERVICE_REQ',
      refId: refId,
    ));
  }

  String _getFileType(String ex) {
    if (ex == "m4a" || ex == "mp3" || ex == 'aac')
      return _audioType;
    else if (ex == "png" || ex == "jpeg" || ex == 'jpg')
      return _imageType;
    else if (ex == "mp4") return _videoType;
    return '';
  }

  Future<Uint8List> _covertFileToBytes(String path) async {
    var bytes = await File(path).readAsBytes();
    return bytes;
  }

  void _initData() {
    _serviceBloc = BlocProvider.of<ServiceBloc>(context);
    _descTxt.text = ApplyServiceModel.description;
    _dateTime = ApplyServiceModel.date == null
        ? DateTime.now()
        : ApplyServiceModel.date;
    _currDate = ApplyServiceModel.time == null
        ? DateTime.now()
        : ApplyServiceModel.time;
    _images = ApplyServiceModel.images;
    _videos = ApplyServiceModel.videos;
    _audios = _audios + ApplyServiceModel.audios;
    thumbnail = ApplyServiceModel.thumbnail;
    _dateString = ApplyServiceModel.date == null
        ? ''
        : OCSUtil.dateFormat(ApplyServiceModel.date ?? '',
            format: Format.date, langCode: Globals.langCode);
    _timeSelect = ApplyServiceModel.time == null
        ? ''
        : OCSUtil.dateFormat(ApplyServiceModel.time ?? '',
            format: Format.time, langCode: Globals.langCode);
    _getFileBytes(0);
    _initAudio();
  }

  void _stopAudioPlaying() {
    for (var i = 0; i < _audioPlayers.length; i++) {
      if (_playerStates[i] == PlayerState.playing) {
        _audioPlayers[i].stop();
        return;
      }
    }
  }

  Future _removeVoice(int index) async {
    _audios.removeAt(index);
    ApplyServiceModel.audios.removeAt(index);
    await _getFileBytes(0);
    setState(() {});
  }

  Future _removeImage(XFile image) async {
    _images.removeWhere((e) => e.path == image.path);
    ApplyServiceModel.images.removeWhere((e) => e.path == image.path);
    deleteFile(File(image.path));
    await _getFileBytes(0);
    setState(() {});
  }

  Future _getImageByGallery() async {
    final List<XFile>? images = await getMultiImageByGallery();
    if (images != null) {
      _images.addAll(images);
      ApplyServiceModel.images = _images;
      await _getFileBytes(0);
      _util.navigator.pop();
    }
    setState(() {});
  }

  Future _getImageByTakeCamera() async {
    final XFile? image = await getImageByTakeCamera();
    if (image != null) {
      _images.add(image);
      ApplyServiceModel.images = _images;
      await _getFileBytes(0);

      _util.navigator.pop();
    }
    setState(() {});
  }

  Future _generateThumbnail(XFile videoFile) async {
    final uint8List = await VideoThumbnail.thumbnailData(
      video: videoFile.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 1200,
      quality: 85,
    );
    thumbnail.add(uint8List!);
    ApplyServiceModel.thumbnail = thumbnail;
  }

  Future _getVideoByGallery() async {
    final XFile? video = await getVideoByGallery();
    if (video != null) {
      _videos.add(video);
      ApplyServiceModel.videos = _videos;
      await _getFileBytes(0);
      await _generateThumbnail(video);
    }
    setState(() {});
  }

  Future _getVideoByTakeCamera() async {
    final XFile? video = await getVideoByTakeCamera();
    if (video != null) {
      _util.navigator.pop();
      _videos.add(video);
      ApplyServiceModel.videos = _videos;
      await _getFileBytes(0);
      await _generateThumbnail(video);
    }
    setState(() {});
  }

  Future _removeVideo(XFile videoFile, int index) async {
    _videos.removeWhere((e) => e.path == videoFile.path);
    ApplyServiceModel.videos.removeWhere((e) => e.path == videoFile.path);
    ApplyServiceModel.thumbnail.removeAt(index);
    deleteFile(File(videoFile.path));
    await _getFileBytes(0);
    setState(() {});
  }

  Future _addVoice() async {
    var status = await Permission.microphone.status;

    if (await _audioRecorder.hasPermission()) {
      _shoModalRecord();
      return;
    }
    if (await status.isPermanentlyDenied) {
      openAppSettings();
    }
    if (status.isGranted || !status.isDenied) {
      _shoModalRecord();
    }
  }

  Widget _buildSelectDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Txt(
          _util.language.key('set-fixing-date'),
          style: TxtStyle()
            ..textColor(OCSColor.text.withOpacity(0.7))
            ..fontSize(12),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Parent(
                    gesture: Gestures()
                      ..onTap(() {
                        DatePicker.showDatePicker(
                          context,
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          onConfirm: (date) {
                            _dateString = OCSUtil.dateFormat(date,
                                format: Format.date,
                                langCode: Globals.langCode);
                            _dateTime = date;
                            ApplyServiceModel.date = date;
                            setState(() {});
                          },
                          currentTime: _dateTime,
                          locale: Globals.langCode == "en"
                              ? LocaleType.en
                              : LocaleType.kh,
                          theme: DatePickerTheme(
                            backgroundColor: Colors.white,
                            itemStyle: TextStyle(fontFamily: "kmFont"),
                          ),
                        );
                      }),
                    child: Row(
                      children: [
                        Txt(
                          "${_dateString.isEmpty ? _util.language.key('dates') : _dateString}",
                          style: TxtStyle()
                            ..fontSize(14)
                            ..textColor(_dateString.isEmpty
                                ? OCSColor.text.withOpacity(0.5)
                                : OCSColor.text),
                        ),
                        Expanded(child: SizedBox()),
                        if (_dateString.isNotEmpty)
                          Parent(
                            gesture: Gestures()
                              ..onTap(() {
                                _dateTime = null;
                                _dateString = '';
                                ApplyServiceModel.date = null;
                                ApplyServiceModel.time = null;
                                _timeSelect = '';
                                _errorTime = '';
                                setState(() {});
                              }),
                            style: ParentStyle()
                              ..width(30)
                              ..borderRadius(all: 50)
                              ..ripple(true)
                              ..height(30),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                    style: ParentStyle()
                      ..width(_util.query.width)
                      ..borderRadius(all: 5)
                      ..background.color(Colors.white)
                      ..padding(all: 10, horizontal: 15, right: 5)
                      ..height(50)
                      ..alignmentContent.centerLeft()
                      ..border(
                        all: 1,
                        color: OCSColor.border,
                      )
                      ..ripple(true),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Parent(
                style: ParentStyle(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Parent(
                      gesture: Gestures()
                        ..onTap(
                            _dateString.isEmpty ? () {} : _headingTimeDialog),
                      child: Row(
                        children: [
                          Txt(
                            "${_timeSelect.isEmpty ? _util.language.key('time') : _timeSelect}",
                            style: TxtStyle()
                              ..fontSize(14)
                              ..textColor(_timeSelect.isEmpty
                                  ? OCSColor.text.withOpacity(0.5)
                                  : OCSColor.text),
                          ),
                          Expanded(child: SizedBox()),
                          if (_timeSelect.isNotEmpty)
                            Parent(
                              gesture: Gestures()
                                ..onTap(() {
                                  _currDate = null;
                                  ApplyServiceModel.time = null;
                                  _timeSelect = '';
                                  setState(() {});
                                }),
                              style: ParentStyle()
                                ..borderRadius(all: 50)
                                ..ripple(true)
                                ..width(30)
                                ..height(30),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                      style: ParentStyle()
                        ..width(_util.query.width)
                        ..borderRadius(all: 5)
                        ..background.color(Colors.white)
                        ..padding(all: 10, horizontal: 15, right: 5)
                        ..height(50)
                        ..alignmentContent.centerLeft()
                        ..border(
                          all: 1,
                          color: _errorTime.isNotEmpty
                              ? Colors.red
                              : OCSColor.border,
                        )
                        ..ripple(_dateString.isNotEmpty),
                    ),
                    if (_errorTime.isNotEmpty)
                      Parent(
                        style: ParentStyle()
                          ..minHeight(6)
                          ..margin(top: 5)
                          ..maxHeight(10)
                          ..overflow.visible()
                          ..alignmentContent.topLeft(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Remix.information_line,
                                color: Colors.red, size: 12),
                            SizedBox(width: 2),
                            Expanded(
                                child: Txt(
                                    _util.language.key('please-select-time'),
                                    style: TxtStyle()
                                      ..textColor(Colors.red)
                                      ..fontSize(10)
                                      ..height(10)
                                      ..maxLines(1)
                                      ..textOverflow(TextOverflow.ellipsis)
                                      ..overflow.visible()
                                      ..alignmentContent.centerLeft()
                                      ..background.color(Colors.transparent)))
                          ],
                        ),
                      ),
                    // SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _headingTimeDialog() {
    DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {},
      onConfirm: (date) {
        String time =
            OCSUtil.dateFormat(date, format: "hh:mm a", langCode: "en");
        _timeSelect = time;
        _currDate = date;
        ApplyServiceModel.time = date;
        _errorTime = '';
        setState(() {});
      },
      currentTime: _currDate,
      locale: Globals.langCode == "km" ? LocaleType.kh : LocaleType.en,
    );
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
                  _audios.add({"Path": file.path, "Second": file.inSeconds});
                  ApplyServiceModel.audios
                      .add({"Path": file.path, "Second": file.inSeconds});
                  await _getFileBytes(0);
                  _initAudio();
                  setState(() {});
                }
              }),
              const SizedBox(height: 20),
            ],
          );
        });
  }

  Widget _buttonAction() {
    return Parent(
      style: ParentStyle()
        ..width(_util.query.width)
        ..borderRadius(all: 5)
        ..background.color(Colors.white)
        ..boxShadow(color: Colors.black12, offset: Offset(0, 0), blur: 2)
        ..padding(all: 15),
      child: Row(
        children: [
          if (_audios.length <= 5)
            Parent(
              gesture: Gestures()
                ..onTap(() async {
                  _stopAudioPlaying();
                  _addVoice();
                }),
              style: menuStyle,
              child: Icon(
                Remix.mic_line,
                color: Colors.teal,
              ),
            ),
          SizedBox(width: 10),
          Parent(
            gesture: Gestures()
              ..onTap(() {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (BuildContext context) {
                    return _buildImageAction();
                  },
                );
              }),
            style: menuStyle,
            child: Icon(
              Remix.camera_2_line,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 10),
          Parent(
            gesture: Gestures()
              ..onTap(() {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return _buildVideoAction();
                  },
                );
              }),
            style: menuStyle,
            child: Icon(
              Icons.video_camera_back_outlined,
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideoAction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Parent(
          style: ParentStyle()
            ..borderRadius(all: 1)
            ..width(_util.query.width)
            ..background.color(Colors.white)
            ..padding(all: 10, top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Txt(
                _util.language.key('video'),
                style: TxtStyle()
                  ..fontSize(16)
                  ..textColor(Colors.black87),
              ),
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildActionModal(
                    icon: Icons.video_camera_back_outlined,
                    onPress: () async {
                      _stopAudioPlaying();
                      await _getVideoByTakeCamera();
                    },
                    color: Colors.green,
                    title: _util.language.key('camera'),
                  ),
                  buildActionModal(
                    color: Colors.blue,
                    icon: Remix.video_line,
                    onPress: () async {
                      _stopAudioPlaying();
                      await _getVideoByGallery();
                    },
                    title: _util.language.key('gallery'),
                  ),
                ],
              ),
              SizedBox(height: _util.query.bottom + 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescSection() {
    return MyTextArea(
      labelSize: 12,
      controller: _descTxt,
      label: _util.language.key('description'),
      placeHolder: _util.language.key('enter-descriptions'),
      onChange: (v) {
        ApplyServiceModel.description = v;
        setState(() {});
      },
    );
  }

  Widget _buildImageAction() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Parent(
          style: ParentStyle()
            ..background.color(Colors.white)
            ..padding(all: 10, top: 5)
            ..borderRadius(all: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Txt(
                _util.language.key('image'),
                style: TxtStyle()
                  ..fontSize(16)
                  ..textColor(Colors.black87),
              ),
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildActionModal(
                    icon: Icons.camera_alt_outlined,
                    onPress: _getImageByTakeCamera,
                    color: Colors.green,
                    title: _util.language.key("camera"),
                  ),
                  buildActionModal(
                    icon: Remix.image_line,
                    onPress: _getImageByGallery,
                    color: Colors.blue,
                    title: _util.language.key("gallery"),
                  ),
                ],
              ),
              SizedBox(height: _util.query.bottom + 5),
            ],
          ),
        ),
      ],
    );
  }

  Future _initAudio() async {
    _audioPlayers = [];
    _playerStates = [];
    _timeProgress = [];
    _audioDuration = [];
    if (_audios.isEmpty) return;
    for (var i = 0; i < _audios.length; i++) {
      _audioPlayers.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      _playerStates.add(PlayerState.paused);
      _audioDuration.add(0);
      _timeProgress.add(0);
      _audioPlayers[i].onPlayerStateChanged.listen((PlayerState state) {
        if (_playerStates[i] != PlayerState.paused)
          _audioPlayers[i].setSourceDeviceFile(
            _audios[i]['Path'],
          );
        if (mounted)
          setState(() {
            _playerStates[i] = state;
          });
      });

      /// Optional
      _audioPlayers[i].setSourceDeviceFile(
        _audios[i]['Path'],
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

  Widget _buildVoiceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          OCSUtil.of(context).language.key('voice'),
          style: TxtStyle()
            ..fontSize(12)
            ..margin(top: 15)
            ..textColor(OCSColor.text.withOpacity(0.7)),
        ),
        Parent(
          style: ParentStyle(),
          child: ListView.builder(
            shrinkWrap: true,
            primary: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              return buildVoice(context,
                  audioPlayer: _audioPlayers[i],
                  value: _value,
                  playerState: _playerStates[i],
                  audioDuration: _audioDuration[i], onDelete: () {
                _removeVoice(i);
                deleteFile(_audios[i]['Path']);
              }, onPlay: () {
                if (_playerStates[i] != PlayerState.playing) {
                  for (var i = 0; i < _playerStates.length; i++) {
                    if (_playerStates[i] == PlayerState.playing) {
                      stopAudio(_audioPlayers[i]);
                    }
                  }
                }
              });
            },
            itemCount: _audioPlayers.length,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      children: [
        Row(
          children: [
            Txt(
              _util.language.key('video'),
              style: TxtStyle()
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..fontSize(_labelSize),
            ),
            Expanded(child: SizedBox()),
          ],
        ),
        GridView.builder(
          primary: true,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemCount: _videos.length,
          itemBuilder: (context, i) {
            return Parent(
              style: ParentStyle(),
              gesture: Gestures()
                ..onTap(() {
                  _util.navigator.to(
                    MyVideoPlayer(
                      path: _videos[i].path,
                    ),
                    transition: OCSTransitions.LEFT,
                  );
                }),
              child: Stack(
                children: [
                  Parent(
                    style: ParentStyle()
                      ..margin(all: 5)
                      ..width(150)
                      ..height(150)
                      ..borderRadius(all: 5)
                      ..overflow.hidden(),
                    child: Image.memory(
                      thumbnail[i],
                      fit: BoxFit.cover,
                      errorBuilder: (a, b, c) {
                        return Image.asset("assets/images/no-image.png");
                      },
                    ),
                  ),
                  Positioned(
                    child: Parent(
                      child: Icon(
                        Remix.play_circle_fill,
                        size: 40,
                        color: Colors.white.withOpacity(.8),
                      ),
                      style: ParentStyle()..alignmentContent.center(),
                    ),
                  ),
                  Positioned(
                    child: Parent(
                      style: ParentStyle()
                        ..padding(all: 5)
                        ..ripple(true)
                        ..borderRadius(all: 50)
                        ..background.color(Colors.white)
                        ..elevation(1, opacity: 0.5),
                      child: Icon(
                        Remix.delete_bin_line,
                        size: 18,
                        color: OCSColor.primary,
                      ),
                      gesture: Gestures()
                        ..onTap(() {
                          _removeVideo(_videos[i], i);
                        }),
                    ),
                    right: 0,
                    top: 0,
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Row(
          children: [
            Txt(
              _util.language.key('image'),
              style: TxtStyle()
                ..textColor(OCSColor.text.withOpacity(0.7))
                ..fontSize(_labelSize),
            ),
            Expanded(child: SizedBox()),
          ],
        ),
        GridView.builder(
          primary: true,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemCount: _images.length,
          itemBuilder: (context, i) {
            return Stack(
              children: [
                Parent(
                  gesture: Gestures()
                    ..onTap(() {
                      _util.navigator.to(ViewMultiImage(
                        path: _images[i].path,
                        images: _images,
                        index: i,
                      ));
                    }),
                  style: ParentStyle()
                    ..margin(all: 5)
                    ..width(300)
                    ..borderRadius(all: 5)
                    ..overflow.hidden()
                    ..background.color(Colors.white)
                    ..boxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      offset: Offset(0, 1),
                      blur: 3.0,
                      spread: 0.5,
                    ),
                  child: Image.file(
                    File(_images[i].path),
                    fit: BoxFit.cover,
                    height: 100,
                  ),
                ),
                Positioned(
                  child: Parent(
                    style: ParentStyle()
                      ..padding(all: 5)
                      ..ripple(true)
                      ..borderRadius(all: 50)
                      ..background.color(Colors.white)
                      ..elevation(1, opacity: 0.5),
                    child: Icon(
                      Remix.delete_bin_line,
                      size: 18,
                      color: OCSColor.primary,
                    ),
                    gesture: Gestures()
                      ..onTap(() {
                        _removeImage(_images[i]);
                      }),
                  ),
                  right: 0,
                  top: 0,
                )
              ],
            );
          },
        ),
      ],
    );
  }
}
