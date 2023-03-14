import 'package:flutter/material.dart';
import 'package:ocs_auth/models/response.dart';
import 'package:ocs_util/ocs_util.dart';
import '/globals.dart';
import '/modals/business.dart';
import '/screens/widget.dart';
import '/repositories/partner_repo.dart';

class BusinessRequestDetail extends StatefulWidget {
  final int id;
  final MBusinessRequestList? header;

  const BusinessRequestDetail({
    Key? key,
    required this.id,
    this.header,
  }) : super(key: key);

  @override
  State<BusinessRequestDetail> createState() => _BusinessRequestDetailState();
}

class _BusinessRequestDetailState extends State<BusinessRequestDetail> {
  PartnerRepo _repo = PartnerRepo();
  late var _util = OCSUtil.of(context);
  bool _loading = false;

  MBusinessRequestDetail _data = MBusinessRequestDetail();
  List<MAddedService> _addedServices = [];
  List<MAddedService> _removedServices = [];
  List<MAddedCoverage> _addedCoverages = [];
  List<MAddedCoverage> _removedCoverages = [];

  @override
  void initState() {
    super.initState();
    _getDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Txt(
          _util.language.key('business-request-detail'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
        backgroundColor: OCSColor.primary,
        leading: NavigatorBackButton(),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : Parent(
              style: ParentStyle(),
              child: SingleChildScrollView(
                child: Parent(
                  style: ParentStyle()
                    ..padding(all: 15)
                    ..minHeight(_util.query.height - _util.query.top - 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.header?.status?.toLowerCase() == "rejected" &&
                          (widget.header?.reason?.isNotEmpty ?? false)) ...[
                        Parent(
                          style: ParentStyle()
                            ..padding(all: 15)
                            ..background.color(Colors.white)
                            ..borderRadius(all: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Parent(
                                    style: ParentStyle()
                                      ..width(5)
                                      ..margin(top: 8)
                                      ..height(5)
                                      ..borderRadius(all: 50)
                                      ..background.color(Colors.red),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Txt(
                                      "${_util.language.by(km: "សំណើររបស់អ្នក", en: "Your request has ")}${_util.language.key('${widget.header?.status?.toLowerCase()}').toLowerCase()}${_util.language.by(km: "ដោយសារមូលហេតុ", en: " because")}",
                                      style: TxtStyle()
                                        ..fontSize(12)
                                        ..textColor(
                                            OCSColor.text.withOpacity(0.7)),
                                    ),
                                  ),
                                ],
                              ),
                              Txt(
                                "${widget.header?.reason?.trim()}",
                                style: TxtStyle()
                                  ..fontSize(14)
                                  ..margin(left: 15),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                      _servicesSection(_addedServices, 'added-services'),
                      _servicesSection(_removedServices, 'removed-services'),
                      _coverage(_addedCoverages, "added-coverages"),
                      _coverage(_removedCoverages, "removed-coverages"),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future _getDetail() async {
    setState(() {
      _loading = true;
    });
    MResponse _res = await _repo.updateCovAndServDetail(widget.id);
    if (!_res.error) {
      _data = _res.data;
      _removedCoverages = _data.removedCoverages ?? [];
      _addedCoverages = _data.addedCoverages ?? [];
      _removedServices = _data.removedServices ?? [];
      _addedServices = _data.addedServices ?? [];
      setState(() {});
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }
    setState(() {
      _loading = false;
    });
  }

  Widget _servicesSection(List<MAddedService>? services, String headTitle) {
    if ((services ?? []).isEmpty) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          _util.language.key("$headTitle"),
          style: TxtStyle()
            ..textColor(OCSColor.text.withOpacity(0.8))
            ..fontSize(Style.subTitleSize),
        ),
        SizedBox(height: 5),
        Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..background.color(Colors.white)
            ..borderRadius(all: 5)
            ..elevation(1, opacity: 0.2)
            ..padding(all: 10, horizontal: 10),
          child: AlignedGridView.count(
            primary: true,
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            itemCount: services?.length,
            itemBuilder: (_, i) {
              return Stack(
                children: [
                  Parent(
                    style: ParentStyle()..margin(all: 5),
                    child: Column(
                      children: [
                        Parent(
                          style: ParentStyle()
                            ..background.color(Colors.white)
                            ..elevation(1, opacity: 0.3)
                            ..borderRadius(all: 5),
                          child: services?[i].image == null
                              ? Image.asset(
                                  'assets/images/no-image.png',
                                  fit: BoxFit.cover,
                                )
                              : Parent(
                                  style: ParentStyle()
                                    ..padding(all: 10)
                                    ..height(70),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: '',
                                    image: ApisString.webServer +
                                        "/" +
                                        (services?[i].image ?? ""),
                                    placeholderErrorBuilder: (c, a, b) {
                                      return Center(
                                        child: SizedBox(
                                          width: 30,
                                          child: Image.asset(
                                            'assets/images/loading.gif',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    },
                                    imageErrorBuilder: (c, a, b) {
                                      return Image.asset(
                                        'assets/images/no-image.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                        ),
                        SizedBox(height: 5),
                        Txt(
                          _util.language.by(
                              km: services?[i].serviceName,
                              en: services?[i].serviceNameEnglish,
                              autoFill: true),
                          style: TxtStyle()
                            ..fontSize(12)
                            ..textAlign.center()
                            ..maxLines(2)
                            ..textColor(OCSColor.text.withOpacity(0.8))
                            ..textOverflow(TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _coverage(List<MAddedCoverage> coverages, String headTitle) {
    if (coverages.isEmpty) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Txt(
          _util.language.key("$headTitle"),
          style: TxtStyle()
            ..textColor(OCSColor.text.withOpacity(0.7))
            ..fontSize(14),
        ),
        SizedBox(height: 5),
        Parent(
          style: ParentStyle()
            ..width(_util.query.width)
            ..background.color(Colors.white)
            ..borderRadius(all: 5)
            ..elevation(1, opacity: 0.2)
            ..margin(bottom: 15),
          child: ListView.builder(
              itemCount: coverages.length,
              shrinkWrap: true,
              padding:
                  EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
              primary: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Txt(
                        "${_util.language.key('${coverages[i].addressType?.toLowerCase()}')} : ${_util.language.by(km: coverages[i].addressName, en: coverages[i].addressNameEnglish)}",
                        style: TxtStyle()
                          ..fontSize(15)
                          ..margin(bottom: 5)
                          ..textColor(OCSColor.text),
                      ),
                    ),
                  ],
                );
              }),
        )
      ],
    );
  }
}
