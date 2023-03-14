import 'package:flutter/material.dart';
import '../globals.dart';
import '/modals/quotation.dart';
import '../repositories/quotation_repo.dart';
import '/screens/service_request_widget.dart';
import 'package:ocs_util/ocs_util.dart';

class BuildQuoteTable extends StatefulWidget {
  final int quotId;
  final Widget? header;
  final Function(MQuotationData? quote)? quoteData;

  const BuildQuoteTable(
      {Key? key, required this.quotId, this.header, this.quoteData})
      : super(key: key);

  @override
  State<BuildQuoteTable> createState() => _BuildQuoteTableState();
}

class _BuildQuoteTableState extends State<BuildQuoteTable> {
  late var _util = OCSUtil.of(context);
  MQuotationData? _quotData;
  bool _initLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.quotId > 0) _getQuotationDetail();
  }

  @override
  Widget build(BuildContext context) {
    return _initLoading
        ? Parent(
            style: ParentStyle()..height(350),
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          )
        : widget.quotId > 0
            ? Column(
                children: [
                  if (widget.header != null) widget.header!,
                  buildDescription(
                    context: context,
                    description: _quotData?.description ?? "",
                  ),
                  buildQuotTable(
                    quotation: _quotData ?? MQuotationData(),
                    context: context,
                  ),
                  SizedBox(height: 70),
                ],
              )
            : SizedBox();
  }

  Future _getQuotationDetail() async {
    setState(() {
      _initLoading = true;
    });
    var _res = await QuotRepo().detail(id: widget.quotId);
    if (!_res.error) {
      _quotData = _res.data;
      if (_quotData?.status != RequestStatus.approved)
        _quotData = _quotData?.copyWith(requireDeposit: false);
      if (widget.quoteData != null) widget.quoteData!(_res.data);
    } else {
      _util.snackBar(message: _res.message, status: SnackBarStatus.danger);
    }

    setState(() {
      _initLoading = false;
    });
  }
}
