import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import '/screens/widget.dart';

class AccessDenied extends StatefulWidget {
  const AccessDenied({Key? key}) : super(key: key);

  @override
  State<AccessDenied> createState() => _AccessDeniedState();
}

class _AccessDeniedState extends State<AccessDenied> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Parent(
        style: ParentStyle()..height(MediaQuery.of(context).size.height),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/access-denied.png',
                height: 250,
              ),
            ),
            SizedBox(height: 15),
            Txt(
              "Access denied",
              style: TxtStyle()..fontSize(16),
            ),
            SizedBox(height: 15),
            BuildButton(
                fontSize: 14,
                height: 45,
                width: 180,
                title: OCSUtil.of(context).language.key('back'),
                onPress: () {
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    );
  }
}
