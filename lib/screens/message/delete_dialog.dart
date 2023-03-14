import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '/modals/message.dart';
import '/globals.dart';

class DeleteDialog extends StatefulWidget {
  final Function(bool v) onSubmit;
  final MMessageData data;

  const DeleteDialog({Key? key, required this.onSubmit, required this.data})
      : super(key: key);

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  late var _util = OCSUtil.of(context);
  bool _forAll = true;
  bool sender = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _forAll = widget.data.sender == Model.userInfo.loginName ? true : false;
    sender = widget.data.sender == Model.userInfo.loginName ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Txt(
        _util.language.key(sender ? 'delete-select-message' : 'delete-message'),
        style: TxtStyle()
          ..fontSize(14)
          ..textColor(OCSColor.text),
      ),
      contentPadding: EdgeInsets.only(left: 15, top: 5, bottom: 0, right: 10),
      content: Row(
        children: [
          if (sender) ...[
            Checkbox(
                value: _forAll,
                onChanged: (v) {
                  setState(() {
                    _forAll = v ?? false;
                  });
                }),
            Txt(
              _util.language.key('delete-for-everyone'),
              style: TxtStyle()
                ..fontSize(12)
                ..textColor(OCSColor.text.withOpacity(0.7)),
              gesture: Gestures()
                ..onTap(() {
                  setState(() {
                    _forAll = !_forAll;
                  });
                }),
            )
          ],
          if (!sender)
            Txt(
              _util.language.key('delete-select-message'),
              style: TxtStyle()
                ..fontSize(12)
                ..margin(left: 10)
                ..textColor(OCSColor.text.withOpacity(0.7)),
            )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: Txt(
            _util.language.key('cancel'),
            style: TxtStyle()..textColor(OCSColor.text.withOpacity(0.6)),
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(_forAll);
          },
          child: Txt(
            _util.language.key('delete'),
          ),
        ),
      ],
    );
  }
}
