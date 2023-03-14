import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '/modals/customer_request_service.dart';
import '/repositories/customer_request_service.dart';
import '/screens/message/message_detail.dart';
import '/globals.dart';
import '/modals/partner.dart';
import '../widget.dart';

class ChatRequestDetail extends StatefulWidget {
  final MRequestService header;

  const ChatRequestDetail({Key? key, required this.header}) : super(key: key);

  @override
  State<ChatRequestDetail> createState() => _ChatRequestDetailState();
}

class _ChatRequestDetailState extends State<ChatRequestDetail> {
  late var _util = OCSUtil.of(context);
  bool _loading = false;
  int _headerId = 0;
  String _errorMessage = '';
  MServiceRequestDetail _requestDetail = MServiceRequestDetail();
  MRequestService? _header;

  @override
  void initState() {
    super.initState();
    _headerId = widget.header.id ?? 0;
    _header = widget.header;
    _getDetail();
  }

  Future _getDetail() async {
    setState(() {
      _loading = true;
    });
    var res = await ServiceRequestRepo().getDetail(_headerId);

    if (res.error) {
      _errorMessage = res.message;
    } else {
      _requestDetail = res.data;
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Txt(
          _util.language.key("partners"),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        leading: NavigatorBackButton(),
      ),
      body: Column(
        children: [
          _loading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                )
              : _errorMessage.isNotEmpty
                  ? Expanded(
                      child: Center(
                        child: BuildErrorBloc(
                          message: _errorMessage,
                        ),
                      ),
                    )
                  : (_requestDetail.acceptedPartners?.isEmpty ?? true)
                      ? Expanded(
                          child: BuildNoDataScreen(
                          title: _util.language.key('no-partner'),
                        ))
                      : Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.all(15),
                            itemCount: _requestDetail.acceptedPartners?.length,
                            itemBuilder: (_, i) {
                              return _partnerCard(
                                _requestDetail.acceptedPartners?[i],
                              );
                            },
                          ),
                        ),
        ],
      ),
    );
  }

  Widget _partnerCard(MAcceptedPartner? data) {
    return Parent(
      gesture: Gestures()
        ..onTap(() {
          _util.to(
            MessageDetail(
              receiverId: data?.partnerId,
              requestId: _headerId,
              receiverName: _util.language.by(
                km: data?.partnerName,
                en: data?.partnerNameEnglish,
                autoFill: true,
              ),
              receiverImage: (data?.image ?? ''),
              requestStatus: data?.status ?? "",
            ),
            transition: OCSTransitions.LEFT,
          );
        }),
      style: ParentStyle()
        ..overflow.hidden(true)
        ..alignmentContent.center()
        ..borderRadius(all: 5)
        ..margin(bottom: 10)
        ..padding(vertical: 5, horizontal: 5)
        ..elevation(1, opacity: 0.2)
        ..background.color(Colors.white),
      child: Column(
        children: [
          Parent(
            style: ParentStyle(),
            child: Row(
              children: [
                Parent(
                  style: ParentStyle()
                    ..borderRadius(all: 5)
                    ..overflow.hidden(true)
                    ..width(110)
                    ..overflow.hidden()
                    ..background.blur(10)
                    ..alignmentContent.center()
                    ..background.color(Colors.white)
                    ..boxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 1),
                      blur: 3.0,
                      spread: 0.5,
                    ),
                  child: MyNetworkImage(
                    url: (data?.image ?? ''),
                    height: 80,
                    width: 110,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Txt(
                        _util.language.by(
                          km: data?.partnerName,
                          en: data?.partnerNameEnglish,
                          autoFill: true,
                        ),
                        style: TxtStyle()
                          ..fontSize(Style.subTitleSize)
                          ..textColor(OCSColor.text)
                          ..textOverflow(TextOverflow.ellipsis),
                      ),
                      Txt(
                        data?.partnerPhone ?? "",
                        style: TxtStyle()
                          ..fontSize(Style.subTextSize)
                          ..textColor(OCSColor.text.withOpacity(0.7))
                          ..textOverflow(TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
