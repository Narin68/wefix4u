import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import '/screens/partner_service_request/select_time_heading.dart';
import '/screens/partner_service_request/widget.dart';
import '../create_quot/create_quot.dart';
import '../message/message_function.dart';
import '../message/message_widget.dart' as message;
import '/blocs/wallet/wallet_cubit.dart';
import '../create_wallet.dart';
import '/screens/function_temp.dart';
import '/blocs/request_service_detail/request_service_detail_bloc.dart';
import '/screens/widget.dart';
import '../payment_screen/partner_close_service.dart';
import '../service_request_widget.dart';
import '/blocs/service_request/service_request_bloc.dart';
import '/globals.dart';
import '/modals/customer_request_service.dart';
import '/repositories/customer_request_service.dart';
import 'view_quotation_detail.dart';

class PartnerServiceRequestDetail extends StatefulWidget {
  final MRequestService? data;
  final bool? notNotif;
  final int? id;

  const PartnerServiceRequestDetail(
      {Key? key, this.data, this.notNotif, this.id})
      : super(key: key);

  @override
  State<PartnerServiceRequestDetail> createState() =>
      _PartnerServiceRequestDetailState();
}

class _PartnerServiceRequestDetailState
    extends State<PartnerServiceRequestDetail> {
  late final _util = OCSUtil.of(context);
  var txtTitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(OCSColor.text.withOpacity(0.8))
    ..width(80)
    ..textColor(OCSColor.text);
  var subtitleStyle = TxtStyle()
    ..fontSize(Style.subTitleSize)
    ..textColor(OCSColor.text.withOpacity(0.8));
  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(11.561902228675693, 104.87935669720174),
    zoom: 18,
  );
  List<Uint8> thumbnail = [];
  ServiceRequestRepo _repo = ServiceRequestRepo();
  bool _loading = false;
  bool _actionLoading = false;
  MServiceRequestDetail _requestDetail = MServiceRequestDetail();
  Color _color = Colors.orange;
  bool _failed = false;
  MRequestService _header = MRequestService();
  String _btnName = '';
  String _status = '';
  bool _initLoading = false;
  String _timeSelect = '';
  String _lateReason = '';
  List<AudioPlayer> _audioPlayers = [];
  List<PlayerState> _playerStates = [];
  List<int> _timeProgress = [];
  List<int> _audioDuration = [];
  double _value = 0;

  @override
  void initState() {
    super.initState();
    if (widget.notNotif ?? true) _header = widget.data!;
    _init();
    // print(_header.status);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_actionLoading) {
          _util.navigator.pop();
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: NavigatorBackButton(loading: _actionLoading),
          backgroundColor: OCSColor.primary,
          title: Txt(
            "${_util.language.key('service-request')}",
            style: TxtStyle()
              ..fontSize(Style.titleSize)
              ..textColor(Colors.white),
          ),
          actions: [
            if (!_failed && !_loading && !_actionLoading && !_initLoading)
              if (_header.status?.toUpperCase() == RequestStatus.pending) ...[
                modalAskGiveUp(context, onSubmit: _onGiveUp)
              ],
            if (!_failed &&
                !_loading &&
                !_initLoading &&
                _header.status?.toUpperCase() != RequestStatus.pending &&
                _header.status?.toUpperCase() != RequestStatus.accepted &&
                _header.status?.toUpperCase() != RequestStatus.giveUp) ...[
              IconButton(
                tooltip: _util.language.key('quotation'),
                onPressed: () {
                  // todo:Change next time
                  _util.navigator.to(
                    ViewQuotationDetail(
                      data: _header,
                      detail: _requestDetail,
                    ),
                    transition: OCSTransitions.LEFT,
                  );
                },
                icon: Icon(
                  Icons.assignment,
                  size: 25,
                ),
              ),
            ],
            if (_status != "enquiring" &&
                !_failed &&
                !_loading &&
                !_initLoading)
              message.MessageIcon(
                receiverImage: _header.customerImage,
                receiverName: _util.language.by(
                  km: _header.customerName,
                  en: _header.customerNameEnglish,
                  autoFill: true,
                ),
                receiverId: _header.customerId,
                requestId: _header.id,
                requestStatus: _header.status?.toLowerCase(),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        body: _initLoading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : _header.id == null
                ? Center(
                    child: BuildNoDataScreen(
                        title:
                            _util.language.key('request-may-reject-or-cancel'),
                        assets: "assets/images/service.png"),
                  )
                : SafeArea(
                    bottom: false,
                    child: Parent(
                      style: ParentStyle()..height(_util.query.height),
                      child: BlocConsumer<RequestServiceDetailBloc,
                          RequestServiceDetailState>(
                        listener: (context, state) {
                          if (state is RequestDetailSuccess) {
                            _failed = false;
                            _requestDetail =
                                state.detail ?? MServiceRequestDetail();
                            _header = state.header ?? MRequestService();
                            _requestDetail.acceptedPartners?.removeWhere(
                                (e) => e.partnerId != Model.partner.id);

                            _loading = false;
                            _checkStatus(state.header!);

                            if (state.detail?.attachment?.audioPathList
                                    ?.isNotEmpty ??
                                false)
                              _initAudio(
                                  state.detail?.attachment?.audioPathList);

                            setState(() {});
                          }
                          if (state is RequestDetailLoading) {
                            _loading = true;
                            setState(() {});
                          }
                          if (state is RequestDetailFailure) {
                            _failed = true;
                            _loading = false;
                            setState(() {});
                          }
                        },
                        builder: (context, state) {
                          if (state is RequestDetailFailure) {
                            return BuildErrorBloc(
                              message: state.message,
                              onRetry: _getDetail,
                            );
                          }
                          if (state is RequestDetailLoading) {
                            return Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }
                          if (state is RequestDetailSuccess) {
                            return Stack(
                              children: [
                                CustomScrollView(
                                  shrinkWrap: true,
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Parent(
                                        style: ParentStyle()
                                          ..padding(all: 16)
                                          ..minHeight(_util.query.height),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildServiceRequestInfo(
                                              context,
                                              header: state.header ??
                                                  MRequestService(),
                                              detail: state.detail ??
                                                  MServiceRequestDetail(),
                                              status: _status,
                                              statusColor: _color,
                                            ),
                                            if (_status.toUpperCase() ==
                                                RequestStatus.done)
                                              ratingSection(
                                                  context, state.header!),
                                            BuildServiceSection(
                                              list:
                                                  state.detail?.services ?? [],
                                            ),
                                            if (state
                                                    .detail
                                                    ?.attachment
                                                    ?.imagePathList
                                                    ?.isNotEmpty ??
                                                false)
                                              buildImageSection(
                                                context: context,
                                                pathList: state
                                                        .detail
                                                        ?.attachment
                                                        ?.imagePathList ??
                                                    [],
                                              ),
                                            if (state
                                                    .detail
                                                    ?.attachment
                                                    ?.videoPathList
                                                    ?.isNotEmpty ??
                                                false)
                                              buildVideoSection(
                                                context: context,
                                                pathList: state
                                                        .detail
                                                        ?.attachment
                                                        ?.videoPathList ??
                                                    [],
                                              ),
                                            if (state
                                                    .detail
                                                    ?.attachment
                                                    ?.audioPathList
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
                                            SizedBox(height: 70),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                _buildBtn(
                                  header: state.header,
                                  detail: state.detail,
                                ),
                                if (_actionLoading)
                                  Positioned(
                                    child: Container(
                                      color: Colors.black.withOpacity(.3),
                                      child: const Center(
                                        child:
                                            CircularProgressIndicator.adaptive(
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ),
                  ),
      ),
    );
  }

  void _init() async {
    if (widget.notNotif != null && widget.notNotif == false) {
      setState(() {
        _initLoading = true;
      });
      var _res = await _repo.list(
          MServiceRequestFilter(id: widget.id, partnerId: Model.partner.id));
      if (!_res.error) {
        if (_res.data.isNotEmpty) _header = _res.data[0];
      }

      setState(() {
        _initLoading = false;
      });
    }
    if (_header.id != null) _getDetail();
  }

  Widget _buildBtn({MRequestService? header, MServiceRequestDetail? detail}) {
    return buildBtn(
      context,
      onClick: _onClickBtn,
      header: header,
      detail: detail,
      status: _status,
      title: _btnName,
    );
  }

  Future _onClickBtn() async {
    if (_loading) return;
    if (_header.status?.toUpperCase() == RequestStatus.pending) {
      _onPendingStatus();
    } else if (_header.status?.toUpperCase() == RequestStatus.accepted) {
      //  && _header.quot?.quotStatus?.toLowerCase() == "pending"
      _issuingStatus();
    } else if (_header.status?.toUpperCase() == RequestStatus.heading) {
      await _onFixingService();
    } else if (_header.status?.toUpperCase() == RequestStatus.approved) {
      await _onHeadingService();
    } else if (_header.status?.toUpperCase() == RequestStatus.fixing) {
      _fixingStatus();
    } else if (_header.quot?.quotStatus == null) {
      _onPendingStatus();
    }
  }

  void _onPendingStatus() {
    Model.userWallet == null
        ? showDialog(
            context: context,
            builder: (_) => VerifyBankAccount(onSuccess: (v) {
              context.read<WalletCubit>().updateWallet(v);
              setState(() {});
            }),
            barrierDismissible: false,
          )
        : showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                confirmAccept(context, onSubmit: _onAcceptRequest),
          );
  }

  void _issuingStatus() {
    _util.navigator.to(
      CreateQuotation(
        quot: Model.quotationDetail,
        detail: _requestDetail,
        data: _header,
      ),
      transition: OCSTransitions.LEFT,
    );
  }

  void _fixingStatus() {
    _util.navigator.to(
      PartnerCloseService(
        data: _header,
        detail: _requestDetail,
      ),
      transition: OCSTransitions.LEFT,
    );
  }

  void _checkStatus(MRequestService header) {
    checkRequestStatus(
        header: header,
        func: (status, color, btnName) {
          _btnName = btnName;
          _status = status;
          _color = color;
        });
    setState(() {});
  }

  Future onSuccess(String status, String data) async {
    var json = jsonDecode(data);
    MRequestService header = MRequestService.fromJson(json[0]);
    header = header.copyWith(customerId: _header.customerId);
    MServiceRequestDetail detail = MServiceRequestDetail.fromJson(json[0]);

    if (status.toLowerCase() == "giveup") {
      /// When give up success
      context.read<ServiceRequestBloc>()
        ..add(UpdateServiceRequest(
            data: header.copyWith(status: RequestStatus.giveUp)));
      _util.navigator.pop();
    } else {
      /// When partner accepted service
      if (status.toUpperCase() == RequestStatus.accepted) {
        header = header.copyWith(
            status: RequestStatus.accepted,
            quot: header.quot?.copyWith(
              quotStatus: RequestStatus.accepted,
            ));
      }

      if (status.toUpperCase() == RequestStatus.fixing ||
          status.toUpperCase() == RequestStatus.heading ||
          status.toUpperCase() == RequestStatus.approved) {
        /// Success fixing and heading
        detail = detail.copyWith(
          acceptedPartners: _requestDetail.acceptedPartners,
          approvedPartner: _requestDetail.approvedPartner,
        );
        header = header.copyWith(
          partnerId: Model.partner.id,
          partnerName: detail.approvedPartner?.partnerName,
          partnerNameEnglish: detail.approvedPartner?.partnerNameEnglish,
        );
      }
      context.read<ServiceRequestBloc>()
        ..add(UpdateServiceRequest(data: header));
      context.read<RequestServiceDetailBloc>()
        ..add(UpdateRequestDetail(header: header, detail: detail));
    }
  }

  Future _onGiveUp() async {
    _util.navigator.pop();
    _processApi("giveUp");
  }

  Future _getDetail() async {
    context
        .read<RequestServiceDetailBloc>()
        .add(FetchRequestDetail(id: _header.id ?? 0, header: _header));
  }

  Future _onAcceptRequest() async {
    _util.navigator.pop();
    _processApi("ACCEPTED");
  }

  Future _onHeadingService() async {
    _headingTimeDialog();
  }

  Future _onFixingService() async {
    _processApi("FIXING");
  }

  void _processApi(String action) async {
    setState(() {
      _actionLoading = true;
    });
    var res = MResponse();
    switch (action.toLowerCase()) {
      case "heading":
        res = await _repo.heading(
          _header.id ?? 0,
          _timeSelect,
          lateReason: _lateReason,
        );
        break;
      case "fixing":
        res = await _repo.fixing(_header.id ?? 0);

        break;
      case "accepted":
        res = await _repo.partnerAccept(_header.id ?? 0);
        break;
      case "giveup":
        res = await _repo.giveUp(_header.id ?? 0);
        break;
    }

    if (res.error) {
      _util.snackBar(message: res.message, status: SnackBarStatus.danger);
    } else {
      await onSuccess(action, res.data);
      _util.toast(_util.language.key('success'));
    }
    setState(() {
      _actionLoading = false;
    });
  }

  Widget _mapSection(MRequestService data) {
    var lat = data.lat;
    var long = data.lng;
    if (lat == null || long == null) return SizedBox();
    return BuildGoogleMapView(lat: double.parse(lat), long: double.parse(long));
  }

  void _headingTimeDialog() {
    bool _isExpire = false;
    String message = '';
    DateTime? date;

    String fixingDate = _header.fixingDate ?? '';

    if (_header.fixingDate?.isNotEmpty ?? false) {
      date = DateTime.parse(fixingDate);
      _isExpire = date.isBefore(DateTime.now());
    }

    if (_isExpire) {
      message = _util.language.by(
          en: 'It will be late, please tell late reason.',
          km: 'ការចុះទៅជួសជុលរបស់អ្នកយឹតកាលកំណត់សូមជួយផ្តល់មូលហេតុ');
    } else if ((_header.fixingDate?.isNotEmpty ?? false)) {
      if (!_isExpire) {
        message = _util.language.by(
          en: 'You are heading so early',
          km: 'អ្នកនឹងទៅជួលជុលមុនកាលកំណត់របស់អថិជន',
        );
      }
    }

    showDialog(
        context: context,
        builder: (_) {
          return SelectTime(
            isExpire: _isExpire,
            message: message,
            fixingDate: _header.fixingDate,
            onSubmit: (String time, DateTime date, String lateReason) {
              _timeSelect = time;
              _lateReason = lateReason;
              _processApi('heading');
              setState(() {});
            },
          );
        });
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
