import 'package:flutter/material.dart';
import 'package:ocs_auth/ocs_auth.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '/functions.dart';
import '../widget.dart';

class NotificationScreen extends StatefulWidget {
  final Function()? onClose;
  final BuildContext? mainContext;

  const NotificationScreen({Key? key, this.mainContext, this.onClose})
      : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _scrollCtl = ScrollController();
  late final _util = OCSUtil.of(context);
  final _filter = MNotificationFilter(orderBy: 'Id', orderDir: 'DESC');

  @override
  void initState() {
    super.initState();
    context.notificationFetched(_filter, reload: true);
    _scrollCtl.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OCSColor.primary,
        leading: IconButton(
          tooltip: _util.language.key('close'),
          icon: Icon(Remix.close_line, size: 26),
          onPressed: () {
            _util.navigator.pop();
          },
        ),
        title: Txt(
          _util.language.key('notification'),
          style: TxtStyle()
            ..fontSize(16)
            ..textColor(Colors.white),
        ),
      ),
      body: NotificationListBuilder(
        listenerBuilder: (_, s) {
          if (s is NotificationSuccess) {
            context.notificationCount();
          }
        },
        successBuilder: (_, data, hasReachedMax) => RefreshIndicator(
            onRefresh: () async {
              context.notificationFetched(_filter, reload: true);
            },
            child: _buildList(data, hasReachedMax)),
        loadingBuilder: (_) => const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, i, u) {
          return BuildErrorBloc(
            onRetry: () {
              context.notificationFetched(_filter, reload: true);
            },
            message: u,
          );
        },
      ),
    );
  }

  Widget _buildList(List<MNotification> data, bool hasReachedMax) {
    if (data.isEmpty) {
      return BuildNoDataScreen();
    }

    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _scrollCtl,
      padding: const EdgeInsets.only(top: 16),
      itemCount: data.length + (hasReachedMax ? 0 : 1),
      itemBuilder: (context, i) {
        if (i >= data.length) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildCard(data[i]);
      },
    );
  }

  Widget _buildCard(MNotification data) {
    return Stack(
      children: [
        Parent(
          gesture: Gestures()
            ..onTap(() {
              if (data.referenceType?.toLowerCase() == "request" ||
                  data.referenceType?.toLowerCase() == "wallettransaction" ||
                  data.referenceType?.toLowerCase() == "request_feedback") {
                Map<String, dynamic> map = {
                  "ref_id": data.referenceId,
                  "ref_type": data.referenceType
                };
                data = data.copyWith(referenceJsonData: map);
              }
              if (data.referenceJsonData != null)
                messagingAction(context,
                    jsonData: data.referenceJsonData ?? {},
                    fromNotification: true,
                    refId: data.referenceId ?? 0);
              if (!(data.read ?? false))
                context.read<NotificationCubit>().update(data);
              setState(() {});
            })
            ..onLongPress(() async {
              await vibrate();
              _showActions(context, data);
            }),
          style: ParentStyle()
            ..background.color(Colors.white)
            ..ripple(true)
            ..padding(horizontal: 15, vertical: 10)
            ..margin(horizontal: 15, bottom: 10)
            ..borderRadius(all: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Parent(
                style: ParentStyle()
                  ..width(30)
                  ..borderRadius(all: 100)
                  ..margin(right: 10, top: 3)
                  ..alignmentContent.center(),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.black45,
                  size: 22,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((data.title?.isNotEmpty ?? false) ||
                        (data.title?.isNotEmpty ?? false))
                      Txt(
                        _util.language.by(
                          km: data.message,
                          en: data.titleEnglish,
                          autoFill: true,
                        ),
                        style: TxtStyle()
                          ..fontSize(14)
                          ..maxLines(1)
                          ..bold()
                          ..textOverflow(TextOverflow.ellipsis)
                          ..overflow.hidden()
                          ..textColor(OCSColor.text),
                      ),
                    Txt(
                      _util.language.by(
                          km: data.message,
                          en: data.messageEnglish,
                          autoFill: true),
                      style: TxtStyle()
                        ..fontSize(14)
                        ..maxLines(5)
                        ..overflow.hidden()
                        ..textColor(OCSColor.text),
                    ),
                    Txt(
                      OCSUtil.dateFormat(DateTime.parse(data.date ?? ''),
                          format: Format.dateTime),
                      style: TxtStyle()
                        ..alignmentContent.centerRight()
                        ..textColor(OCSColor.subText)
                        ..fontSize(12),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!(data.read ?? false))
          Positioned(
            left: 25,
            top: 22,
            child: Parent(
              style: ParentStyle()
                ..width(5)
                ..height(5)
                ..borderRadius(all: 100)
                ..background.color(Colors.green),
            ),
          ),
        Positioned(
          right: 15,
          child: OCSBtn(
            width: 30,
            height: 30,
            style: ParentStyle()..padding(all: 0),
            prefixIcon: Icon(Icons.more_vert, color: OCSColor.icon, size: 18),
            type: BtnType.icon,
            onPressed: () {
              _showActions(context, data);
            },
          ),
        ),
      ],
    );
  }

  void _onScroll() {
    var max = _scrollCtl.position.maxScrollExtent;
    var pos = _scrollCtl.position.pixels;

    if (pos >= max) {
      context.notificationFetched(_filter, reload: false);
    }
  }

  @override
  void dispose() {
    if (widget.onClose != null) widget.onClose!();

    _scrollCtl.dispose();

    super.dispose();
  }

  void _showActions(BuildContext context, MNotification data) {
    final _util = OCSUtil.of(context);

    _util.bottomSheet(
      children: [
        const SizedBox(width: 10),
        Txt(
            _util.translateBy(
                km: data.title, en: data.titleEnglish, autoFill: true),
            style: TxtStyle()
              ..textAlign.center()
              ..margin(horizontal: 20)
              ..fontSize(12)
              ..textColor(OCSColor.subText)),
        MyListTile(
          leading: Icon(Icons.highlight_remove_outlined, color: OCSColor.icon),
          titleStyle: TxtStyle()..bold(),
          title: _util.translateBy(
              km: 'លុបការជូនដំណឹងនេះ', en: 'Remove this notification'),
          onTap: () async {
            context.notificationRemove(data);
            bool undo = false;

            _util.pop();

            _onScroll();

            if (_scrollCtl.position.maxScrollExtent <= 200) {
              context.notificationFetched(_filter);
            }

            await _util.snackBar(
              duration: const Duration(seconds: 2),
              status: SnackBarStatus.warning,
              message: _util.translateBy(
                  km: 'ការជូនដំណឹងត្រូវបានដកចេញ។', en: 'Notification removed.'),
              primaryAction: (ctl) => Txt(_util.language.key('undo'),
                  gesture: Gestures()
                    ..onTap(() {
                      undo = true;
                      ctl.dismiss();
                    }),
                  style: TxtStyle()
                    ..margin(right: 10)
                    ..textColor(OCSColor.white)
                    ..bold()),
            );

            if (undo) {
              context.notificationUndoRemove();
              return;
            }

            final result =
                await OCSAuth.instance.notificationDelete([data.id ?? 0]);

            if (!result.error) {
              _util.toast('Success');
              debugPrint('Notification removed!');
            } else {
              context.notificationUndoRemove();
              _util.snackBar(
                  message: 'Can\'t remove notification!',
                  status: SnackBarStatus.danger);
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
