import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ocs_util/ocs_util.dart';
import '/globals.dart';

class SelectTime extends StatefulWidget {
  final Function(String time, DateTime dateTime, String lateReason)? onSubmit;
  final bool isExpire;
  final String? fixingDate;
  final String? message;

  const SelectTime({
    Key? key,
    this.onSubmit,
    this.isExpire = false,
    this.fixingDate,
    this.message,
  }) : super(key: key);

  @override
  State<SelectTime> createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  String _timeError = '';
  String _timeSelect = '';
  DateTime _currDate = DateTime.now();
  late var _util = OCSUtil.of(context);
  TextEditingController _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _util.language.key('heading-request'),
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 5),
              if ((widget.fixingDate?.isNotEmpty ?? false) &&
                  (widget.message?.isNotEmpty ?? false))
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Parent(
                      style: ParentStyle()
                        ..background.color(Colors.orange)
                        ..width(8)
                        ..height(8)
                        ..margin(right: 10, top: 7)
                        ..borderRadius(all: 10),
                    ),
                    Expanded(
                      child: Txt(
                        widget.message ?? "",
                        style: TxtStyle()..fontSize(12),
                      ),
                    )
                  ],
                ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    _util.language.key('arrival-time'),
                    style: TextStyle(
                      fontSize: 12,
                      color: OCSColor.text.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "*",
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              Parent(
                gesture: Gestures()
                  ..onTap(() {
                    DatePicker.showTimePicker(
                      context,
                      showTitleActions: true,
                      onChanged: (date) {},
                      onConfirm: (date) {
                        String time = OCSUtil.dateFormat(date,
                            format: "hh:mm a", langCode: "en");
                        _timeSelect = time;
                        _currDate = date;
                        _timeError = '';

                        setState(() {});
                      },
                      currentTime: _currDate,
                      locale: Globals.langCode == "km"
                          ? LocaleType.kh
                          : LocaleType.en,
                    );
                  }),
                child: Txt(
                  "${_timeSelect.isEmpty ? _util.language.key('select') : _timeSelect}",
                  style: TxtStyle()
                    ..fontSize(14)
                    ..textColor(OCSColor.text),
                ),
                style: ParentStyle()
                  ..width(_util.query.width)
                  ..borderRadius(all: 5)
                  ..background.color(Colors.white)
                  ..padding(all: 10, horizontal: 15)
                  ..height(50)
                  ..alignmentContent.centerLeft()
                  ..border(
                    all: 1,
                    color: _timeError.isNotEmpty ? Colors.red : OCSColor.border,
                  )
                  ..ripple(true),
              ),
              SizedBox(height: 10),
              if ((widget.fixingDate?.isNotEmpty ?? false) &&
                  widget.isExpire) ...[
                Row(
                  children: [
                    Text(
                      _util.language.key('late-reason'),
                      style: TextStyle(
                          fontSize: 12, color: OCSColor.text.withOpacity(0.7)),
                    ),
                    Text(
                      "*",
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),
                TextFormField(
                  controller: _descController,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  autofocus: false,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: Style.subTitleSize,
                    color: OCSColor.text,
                  ),
                  cursorColor: OCSColor.primary,
                  cursorWidth: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "",
                    errorStyle: TextStyle(
                      fontSize: Style.subTextSize - 1,
                      fontFamily: 'kmFont',
                      fontWeight: FontWeight.w100,
                      color: Colors.red,
                    ),
                    hintStyle: TextStyle(
                      fontSize: Style.subTitleSize,
                      fontFamily: 'kmFont',
                      fontWeight: FontWeight.w100,
                      color: OCSColor.text.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.only(
                        left: 15.0, top: 10, bottom: 10, right: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: OCSColor.primary),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: OCSColor.border),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v!.isEmpty)
                      return _util.language.key('this-field-is-required');

                    return null;
                  },
                ),
                SizedBox(height: 10),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _util.navigator.pop(),
                    child: Text(
                      _util.language.key('cancel'),
                      style: TextStyle(color: OCSColor.text.withOpacity(0.7)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      bool valid = true;

                      if (_timeSelect.isEmpty) {
                        valid = false;
                        setState(() {
                          _timeError =
                              _util.language.key('this-field-is-required');
                        });
                      }
                      if (!_formKey.currentState!.validate() || !valid) return;

                      if (widget.onSubmit != null)
                        widget.onSubmit!(
                            OCSUtil.dateFormat(_currDate,
                                format: Format.time24),
                            _currDate,
                            _descController.text.trim());
                      _util.pop();
                    },
                    child: Text(
                      _util.language.key('ok'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
