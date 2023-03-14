import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '../function_temp.dart';
import '../message/message_function.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '../service_request_widget.dart';
import '../widget.dart';
import '/globals.dart';
import '/modals/customer_request_service.dart';

class CustomerServiceAllInfo extends StatefulWidget {
  final MRequestService? data;
  final MServiceRequestDetail? requestDetail;

  const CustomerServiceAllInfo({Key? key, this.data, this.requestDetail})
      : super(key: key);

  @override
  State<CustomerServiceAllInfo> createState() => _CustomerServiceAllInfoState();
}

class _CustomerServiceAllInfoState extends State<CustomerServiceAllInfo> {
  late var _util = OCSUtil.of(context);
  Color _color = Colors.orange;
  String _status = '';

  List<AudioPlayer> _audioPlayers = [];
  List<PlayerState> _playerStates = [];
  List<int> _timeProgress = [];
  List<int> _audioDuration = [];
  double _value = 0;

  @override
  void initState() {
    super.initState();
    context.read<RequestServiceDetailBloc>().add(
        UpdateRequestDetail(detail: widget.requestDetail, header: widget.data));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        title: Txt(
          "${_util.language.key('service-request-detail')}",
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      backgroundColor: Colors.white,
      body: Parent(
        style: ParentStyle()..height(_util.query.height),
        child:
            BlocConsumer<RequestServiceDetailBloc, RequestServiceDetailState>(
          listener: (_, s) {
            if (s is RequestDetailSuccess) {
              if (s.detail?.attachment?.audioPathList?.isNotEmpty ?? false)
                _initAudio(s.detail?.attachment?.audioPathList);
            }
          },
          builder: (context, state) {
            if (state is RequestDetailSuccess) {
              _checkStatus(state.header!);

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Parent(
                      style: ParentStyle()..padding(all: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildServiceRequestInfo(
                            context,
                            header: state.header!,
                            detail: state.detail!,
                            status: _status,
                            statusColor: _color,
                          ),
                          buildDescription(
                            context: context,
                            description: state.header?.desc,
                          ),
                          BuildServiceSection(
                            list: state.detail?.services ?? [],
                          ),
                          buildImageSection(
                            context: context,
                            pathList:
                                state.detail?.attachment?.imagePathList ?? [],
                          ),
                          buildVideoSection(
                            context: context,
                            pathList:
                                state.detail?.attachment?.videoPathList ?? [],
                          ),
                          if (state.detail?.attachment?.audioPathList
                                  ?.isNotEmpty ??
                              false)
                            buildVoiceList(
                              context,
                              audioDurations: _audioDuration,
                              audioPlayers: _audioPlayers,
                              playerStates: _playerStates,
                              value: _value,
                            ),
                          SizedBox(height: 15),
                          _mapSection(state.header!),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var i = 0; i < _audioPlayers.length; i++) {
      _audioPlayers[i].stop();
      _audioPlayers[i].dispose();
      _audioPlayers[i].release();
    }
  }

  Widget _mapSection(MRequestService data) {
    var lat = data.lat;
    var long = data.lng;
    if (lat == null || long == null) return SizedBox();
    return BuildGoogleMapView(lat: double.parse(lat), long: double.parse(long));
  }

  void _checkStatus(MRequestService header) {
    checkCusRequestStatus(
      header: header,
      func: (status, color, subStatus) {
        _status = status;
        _color = color;
      },
    );
  }

  Future _initAudio(List<String>? list) async {
    List<String> data = list ?? [];
    _audioPlayers = [];
    _playerStates = [];
    _timeProgress = [];
    _audioDuration = [];
    if (data.isEmpty) return;
    for (var i = 0; i < data.length; i++) {
      _audioPlayers.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
      _playerStates.add(PlayerState.paused);
      _audioDuration.add(0);
      _timeProgress.add(0);
      _audioPlayers[i].onPlayerStateChanged.listen((PlayerState state) {
        if (_playerStates[i] != PlayerState.paused)
          _audioPlayers[i].setSourceUrl(
            ApisString.webServer + "/${data[i]}",
          );
        if (mounted)
          setState(() {
            _playerStates[i] = state;
          });
      });

      /// Optional
      _audioPlayers[i].setSourceUrl(
        ApisString.webServer + "/${data[i]}",
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
}
