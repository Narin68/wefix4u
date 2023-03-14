import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/modals/customer_request_service.dart';
import '/screens/widget.dart';
import '/blocs/chat_request/chat_request_bloc.dart';
import '/repositories/customer_request_service.dart';
import '/globals.dart';
import 'chat_request_detail.dart';
import 'message_detail.dart';

class ChatRequest extends StatefulWidget {
  const ChatRequest({Key? key}) : super(key: key);

  @override
  State<ChatRequest> createState() => _MessageRequestState();
}

class _MessageRequestState extends State<ChatRequest> {
  late var _util = OCSUtil.of(context);
  ScrollController _scroll = ScrollController();
  bool _loading = false;
  MServiceRequestDetail _requestDetail = MServiceRequestDetail();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _initRequest();
  }

  @override
  void dispose() {
    super.dispose();
    _scroll.removeListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Txt(
          _util.language.key('chat'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Parent(
                gesture: Gestures()
                  ..onTap(() {
                    _util.navigator.to(
                      MessageDetail(requestId: 0, receiverName: "wefix4u"),
                      transition: OCSTransitions.LEFT,
                    );
                  }),
                style: ParentStyle()
                  ..background.color(Colors.white)
                  ..width(_util.query.width)
                  ..padding(all: 10, horizontal: 15)
                  ..margin(bottom: 10)
                  ..margin(top: 15, horizontal: 15)
                  ..borderRadius(all: 5)
                  ..ripple(true),
                child: Parent(
                  style: ParentStyle(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 5),
                      Txt(
                        _util.language.key('message-to-company'),
                        style: TxtStyle()
                          ..fontSize(Style.subTitleSize)
                          ..textColor(OCSColor.text)
                          ..fontWeight(FontWeight.bold)
                          ..textAlign.right(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: BlocBuilder<ChatRequestBloc, ChatRequestState>(
                builder: (context, s) {
                  if (s is ChatRequestInitial || s is ChatRequestLoading) {
                    return Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (s is ChatRequestFailure) {
                    return Center(
                        child: BuildErrorBloc(
                      message: s.message,
                      onRetry: _initRequest,
                    ));
                  }

                  if (s is ChatRequestSuccess) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _reloadRequest();
                      },
                      child: Parent(
                        style: ParentStyle()..height(_util.query.height),
                        child: ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            controller: _scroll,
                            itemCount: (s.hasReach ?? false)
                                ? (s.data?.length ?? 0)
                                : (s.data?.length ?? 0) + 1,
                            padding: EdgeInsets.all(15),
                            shrinkWrap: true,
                            itemBuilder: (_, i) {
                              return i >= (s.data?.length ?? 0)
                                  ? Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    )
                                  : Parent(
                                      gesture: Gestures()
                                        ..onTap(() async {
                                          if (Globals.userType ==
                                              UserType.customer)
                                            _util.navigator.to(
                                                ChatRequestDetail(
                                                    header: s.data![i]),
                                                transition:
                                                    OCSTransitions.LEFT);
                                          else {
                                            _util.to(
                                                MessageDetail(
                                                  receiverImage:
                                                      s.data![i].customerImage,
                                                  receiverName:
                                                      _util.language.by(
                                                    km: s.data![i].customerName,
                                                    en: s.data![i]
                                                        .customerNameEnglish,
                                                    autoFill: true,
                                                  ),
                                                  receiverId:
                                                      s.data![i].customerId,
                                                  requestId: s.data![i].id,
                                                ),
                                                transition:
                                                    OCSTransitions.LEFT);
                                          }
                                        }),
                                      style: ParentStyle()
                                        ..background.color(Colors.white)
                                        ..width(_util.query.width)
                                        ..padding(all: 10, horizontal: 15)
                                        ..margin(bottom: 10)
                                        ..borderRadius(all: 5)
                                        ..ripple(true),
                                      child: Stack(
                                        children: [
                                          Parent(
                                            style: ParentStyle(),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Txt(
                                                  s.data?[i].code ?? "",
                                                  style: TxtStyle()
                                                    ..fontSize(
                                                        Style.subTitleSize)
                                                    ..textColor(OCSColor.text)
                                                    ..fontWeight(
                                                        FontWeight.bold)
                                                    ..textAlign.right(),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Remix.calendar_2_line,
                                                      size: 14,
                                                      color: OCSColor.text
                                                          .withOpacity(1),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Txt(
                                                        OCSUtil.dateFormat(
                                                            s.data?[i]
                                                                    .createdDate ??
                                                                "",
                                                            format: Format
                                                                .dateTime),
                                                        style: TxtStyle()
                                                          ..fontSize(
                                                              Style.subTextSize)
                                                          ..maxLines(1)
                                                          ..textOverflow(
                                                              TextOverflow
                                                                  .ellipsis)
                                                          ..textColor(OCSColor
                                                              .text
                                                              .withOpacity(.7)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                            }),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ))
            ],
          ),
          if (_loading)
            Container(
              width: _util.query.width,
              height: _util.query.height,
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              color: Colors.black12,
            )
        ],
      ),
    );
  }

  void _initRequest() {
    context.read<ChatRequestBloc>()
      ..add(
        FetchedChatRequest(
          filter: MServiceRequestFilter(
            refId: Globals.userType == "customer" ? Model.customer.id : 0,
            partnerId: Globals.userType == "customer" ? 0 : Model.partner.id,
          ),
          isInit: true,
        ),
      );
  }

  void _getRequest() {
    context.read<ChatRequestBloc>()
      ..add(
        FetchedChatRequest(
          filter: MServiceRequestFilter(
            refId: Globals.userType == "customer" ? Model.customer.id : 0,
            partnerId: Globals.userType == "customer" ? 0 : Model.partner.id,
          ),
        ),
      );
  }

  void _reloadRequest() {
    context.read<ChatRequestBloc>()
      ..add(ReloadChatRequest())
      ..add(
        FetchedChatRequest(
          filter: MServiceRequestFilter(
            refId: Globals.userType == "customer" ? Model.customer.id : 0,
            partnerId: Globals.userType == "customer" ? 0 : Model.partner.id,
          ),
        ),
      );
  }

  Future _onScroll() async {
    var _curr = _scroll.position.pixels;
    var _max = _scroll.position.maxScrollExtent;
    if (_curr >= _max - 50) {
      _getRequest();
    }
  }
}
