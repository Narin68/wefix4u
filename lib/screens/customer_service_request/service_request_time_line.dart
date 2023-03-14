import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:timelines/timelines.dart';
import '/globals.dart';
import '/screens/widget.dart';
import '/modals/request_log_list.dart';
import '/repositories/customer_request_service.dart';

class ServiceRequestTimeLine extends StatefulWidget {
  final String code;

  const ServiceRequestTimeLine({Key? key, required this.code})
      : super(key: key);

  @override
  State<ServiceRequestTimeLine> createState() => _ServiceRequestTimeLineState();
}

class _ServiceRequestTimeLineState extends State<ServiceRequestTimeLine> {
  late var _util = OCSUtil.of(context);
  bool _loading = false;
  bool _isFail = false;
  String _errorMessage = '';

  List<MRequestLogList> _data = [];

  Color _color = Colors.orange;
  String _headingSoon = "heading";
  String _fixing = "fix";
  String _status = '';

  @override
  void initState() {
    super.initState();
    _getTimelineData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Txt(
          _util.language.key('tracking-service'),
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..textColor(Colors.white),
        ),
        backgroundColor: OCSColor.primary,
        leading: NavigatorBackButton(loading: _loading),
      ),
      body: Parent(
        style: ParentStyle()..height(_util.query.height),
        child: _loading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : _isFail
                ? Center(
                    child: BuildErrorBloc(
                        message: _errorMessage, onRetry: _getTimelineData),
                  )
                : _data.isEmpty
                    ? BuildNoDataScreen()
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Parent(
                              style: ParentStyle()..padding(all: 15),
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _data.length,
                                  primary: true,
                                  shrinkWrap: true,
                                  itemBuilder: (_, i) {
                                    MRequestLogList data = _data[i];
                                    _checkStatus(data.status ?? "");
                                    return TimelineTile(
                                      nodeAlign: TimelineNodeAlign.start,
                                      contents: Parent(
                                        style: ParentStyle()
                                          ..margin(left: 10, bottom: 10)
                                          ..borderRadius(all: 5)
                                          ..overflow.hidden(),
                                        child: Parent(
                                          style: ParentStyle()
                                            ..elevation(1, opacity: 0.2)
                                            ..border(bottom: 1, color: _color)
                                            ..padding(
                                                all: 15, vertical: 10, top: 5)
                                            ..width(_util.query.width - 60)
                                            ..background.color(Colors.white),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Txt(
                                                "${_util.language.key(_status)}",
                                                style: TxtStyle()
                                                  ..fontSize(Style.subTitleSize)
                                                  ..margin(bottom: 5)
                                                  ..textColor(_color),
                                              ),
                                              if (data.status?.toLowerCase() ==
                                                      "approved" ||
                                                  data.status?.toLowerCase() ==
                                                      "created" ||
                                                  data.status?.toLowerCase() ==
                                                      "done" ||
                                                  data.status?.toLowerCase() ==
                                                      "canceled")
                                                _buildActionBy(
                                                  _util.language.by(
                                                    km: data.customerName,
                                                    en: data
                                                        .customerNameEnglish,
                                                    autoFill: true,
                                                  ),
                                                  data.customerActionDate !=
                                                              null ||
                                                          data.createdDate !=
                                                              null
                                                      ? "${OCSUtil.dateFormat(DateTime.parse("${data.createdDate}"), format: Format.dateTime, langCode: Globals.langCode)}"
                                                      : "",
                                                ),
                                              if (data.status?.toLowerCase() !=
                                                      "done" &&
                                                  data.partners != null)
                                                for (var j = 0;
                                                    j < data.partners!.length;
                                                    j++) ...[
                                                  _buildActionBy(
                                                    "${_util.language.by(km: data.partners![j].partnerName, en: data.partners![j].partnerNameEnglish, autoFill: true)}",
                                                    "${OCSUtil.dateFormat(DateTime.parse('${data.partners![j].actionDate}'), format: Format.dateTime, langCode: Globals.langCode)}",
                                                  ),
                                                ]
                                            ],
                                          ),
                                        ),
                                      ),
                                      node: TimelineNode(
                                        indicator:
                                            OutlinedDotIndicator(color: _color),
                                        startConnector: SolidLineConnector(
                                          color: Colors.grey,
                                          thickness: 0.7,
                                        ),
                                        endConnector: SolidLineConnector(
                                          color: Colors.grey,
                                          thickness: 0.7,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          )
                        ],
                      ),
      ),
    );
  }

  Future _getTimelineData() async {
    setState(() {
      _loading = true;
    });
    var res = await ServiceRequestRepo().log(widget.code);
    if (!res.error) {
      _data = res.data;
      _isFail = false;
      _errorMessage = "";
    } else {
      _isFail = true;
      _errorMessage = res.message;
    }
    setState(() {
      _loading = false;
    });
  }

  void _checkStatus(String status) {
    switch (status.toLowerCase()) {
      case "created":
        _color = Style.statusColors[0];
        _status = 'request-sent';
        break;
      case "approved":
        _color = Style.statusColors[4];
        _status = 'confirmed';
        break;
      case "done":
        _color = Style.statusColors[2];
        _status = 'done';
        break;
      case "heading":
        _color = Style.statusColors[7];
        _status = _headingSoon;
        break;
      case "accepted":
        _status = 'accept-partners';
        _color = Style.statusColors[3];
        break;
      case "fixing":
        _color = Style.statusColors[8];
        _status = _fixing;
        break;
      case "closed":
        _color = Style.statusColors[6];
        _status = 'closed';
        break;
      case "failed":
        _color = Style.statusColors[1];
        _status = 'failed';
        break;
      case "canceled":
        _color = Style.statusColors[5];
        _status = 'canceled';
        break;
    }
  }

  Widget _buildActionBy(String cusName, String date) {
    return Parent(
      style: ParentStyle()
        ..width(_util.query.width)
        ..padding(all: 5, left: 10, right: 10)
        ..background.color(
          _color.withOpacity(0.04),
        )
        ..margin(bottom: 5)
        ..borderRadius(all: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Txt(
            "${cusName}",
            style: TxtStyle()
              ..fontSize(Style.subTitleSize)
              ..textColor(OCSColor.text),
          ),
          Txt(
            date,
            style: TxtStyle()
              ..fontSize(Style.subTextSize)
              ..textColor(OCSColor.text.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
