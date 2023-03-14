import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lottie/lottie.dart' as lt;
import 'package:ocs_auth/builders/notification_bell.dart';
import 'package:ocs_auth/custom_context.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import '../functions.dart';
import '/globals.dart';
import 'notification/notification.dart';
import 'dart:io';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

Widget notificationBellBuilder(BuildContext context) {
  final _util = OCSUtil.of(context);

  return NotificationBellBuilder(
    builder: (count) {
      return SizedBox(
        child: Stack(
          children: [
            Center(
              child: IconButton(
                  onPressed: () {
                    _util.navigator.to(NotificationScreen(
                      onClose: () async {
                        context.notificationCount();
                      },
                    ), isFade: true, transition: OCSTransitions.UP);
                  },
                  icon: const Icon(
                    Icons.notifications,
                    size: 24,
                  )),
            ),
            if (count > 0)
              Positioned(
                  right: 6,
                  top: 6,
                  child: IgnorePointer(
                    child: Txt(
                      count > 99 ? '99+' : count.toString(),
                      style: TxtStyle()
                        ..fontSize(10)
                        ..padding(all: 2)
                        ..minWidth(23)
                        ..height(23)
                        ..textAlign.center()
                        ..fontWeight(FontWeight.w600)
                        ..textColor(Colors.white)
                        ..background.color(Colors.red)
                        ..borderRadius(all: 100)
                        ..border(all: 1, color: OCSColor.border),
                    ),
                  )),
          ],
        ),
      );
    },
  );
}

class MyNetworkImage extends StatelessWidget {
  final String url;
  final String? defaultAssetImage;
  final double? iconSize;
  final double? width;
  final double? height;

  const MyNetworkImage({
    Key? key,
    required this.url,
    this.defaultAssetImage,
    this.iconSize,
    this.width = null,
    this.height = null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInImage.assetNetwork(
      width: width,
      height: height,
      placeholder: '',
      image: url,
      fit: BoxFit.cover,
      placeholderErrorBuilder: (c, a, b) {
        return Center(
          child: SizedBox(
            width: iconSize ?? 30,
            child: Image.asset(
              'assets/images/loading.gif',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      imageErrorBuilder: (c, a, b) {
        return defaultAssetImage != null
            ? Image.asset(
                defaultAssetImage!,
                fit: BoxFit.cover,
                width: width,
                height: height,
              )
            : Image.asset(
                'assets/images/no-image.png',
                fit: BoxFit.cover,
                height: height,
                width: width,
              );
      },
    );
  }
}

class MyViewImage extends StatefulWidget {
  final String? url;

  final Uint8List? byteImage;
  final String onErrorImage;

  MyViewImage(
      {this.url,
      this.byteImage,
      this.onErrorImage = 'assets/images/no-image.png'});

  @override
  _MyViewImageState createState() => _MyViewImageState();
}

class _MyViewImageState extends State<MyViewImage> {
  late final _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          widget.byteImage != null
              ? PhotoView(
                  imageProvider: MemoryImage(widget.byteImage!),
                  errorBuilder: (_, b, c) {
                    return Center(
                        child: Image.asset(
                      "assets/images/user.png",
                      fit: BoxFit.cover,
                    ));
                  },
                )
              : PhotoView(
                  imageProvider: NetworkImage(widget.url!),
                  errorBuilder: (_, b, c) {
                    return Center(
                        child: Image.asset(
                      widget.onErrorImage,
                      fit: BoxFit.cover,
                    ));
                  },
                ),
          Positioned(
            top: _util.query.top + 10,
            left: 10,
            child: Parent(
              style: ParentStyle()
                ..padding(all: 2)
                ..overflow.hidden()
                ..background.color(Colors.black12)
                ..borderRadius(all: 50),
              child: IconButton(
                onPressed: () {
                  _util.navigator.pop();
                },
                icon: Icon(
                  Remix.close_line,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildNoDataScreen extends StatefulWidget {
  final String? title;
  final String? assets;

  const BuildNoDataScreen({Key? key, this.title, this.assets})
      : super(key: key);

  @override
  State<BuildNoDataScreen> createState() => _BuildNoDataScreenState();
}

class _BuildNoDataScreenState extends State<BuildNoDataScreen> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Parent(
          style: ParentStyle(),
          child: Image.asset(
            widget.assets ?? 'assets/images/no-data.png',
            width: 200,
            height: 200,
          ),
        ),
        Txt(
          widget.title ?? _util.language.key('no-data'),
          style: TxtStyle()
            ..fontSize(Style.titleSize)
            ..fontWeight(FontWeight.bold)
            ..alignmentContent.center()
            ..margin(top: 16)
            ..textColor(OCSColor.text),
        ),
        SizedBox(height: 100),
      ],
    );
  }
}

class BuildErrorBloc extends StatefulWidget {
  final String? message;
  final Function? onRetry;
  final String? path;

  const BuildErrorBloc({Key? key, this.message, this.onRetry, this.path})
      : super(key: key);

  @override
  State<BuildErrorBloc> createState() => _BuildErrorBlocState();
}

class _BuildErrorBlocState extends State<BuildErrorBloc> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Parent(
      style: ParentStyle()
        ..height(MediaQuery.of(context).size.height)
        ..alignmentContent.center()
        ..padding(all: 20),
      child: Center(
        child: Column(
          children: [
            Expanded(child: SizedBox()),
            Image.asset(
              widget.path == null
                  ? 'assets/images/error-image-computer.png'
                  : (widget.path ?? "assets/images/error-image-computer.png"),
              // width: 80,
              height: 170,
            ),
            SizedBox(height: 15),
            Center(
              child: Txt(
                widget.message?.toUpperCase() ?? "",
                style: TxtStyle()
                  ..fontSize(Style.subTitleSize)
                  ..textColor(OCSColor.text)
                  ..textAlign.center(),
              ),
            ),
            SizedBox(height: 15),
            BuildButton(
              title: _util.language.key('retry'),
              fontSize: 14,
              width: 120,
              height: 40,
              onPress: () {
                if (widget.onRetry != null) widget.onRetry!();
              },
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class BuildSuccessScreen extends StatefulWidget {
  final String? successTitle;
  final String? asset;
  final Color? btnPrimaryColor;
  final Color? btnAccentColor;

  BuildSuccessScreen({
    this.successTitle,
    this.asset,
    this.btnAccentColor,
    this.btnPrimaryColor,
  });

  @override
  _BuildSuccessScreenState createState() => _BuildSuccessScreenState();
}

class _BuildSuccessScreenState extends State<BuildSuccessScreen>
    with SingleTickerProviderStateMixin {
  late var _util = OCSUtil.of(context);
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _controller.reset();
        _util.navigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Parent(
          style: ParentStyle()..padding(all: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: SizedBox()),
              Column(
                children: [
                  widget.asset == null
                      ? Center(
                          child: SizedBox(
                            height: 180,
                            child: lt.Lottie.asset(
                              'assets/gifs/successful.json',
                              controller: _controller,
                              repeat: false,
                              onLoaded: (composition) {
                                _controller.forward();
                              },
                            ),
                          ),
                        )
                      : Center(
                          child: SizedBox(
                            width: 150,
                            child: Image.asset(widget.asset!),
                          ),
                        ),
                  SizedBox(height: 20),
                  Txt(
                    "${widget.successTitle ?? _util.language.key("successfully")}",
                    style: TxtStyle()
                      ..textAlign.center()
                      ..fontSize(Style.titleSize)
                      ..textColor(OCSColor.text),
                  ),
                  SizedBox(height: 20),
                  BuildButton(
                    title: _util.language.key("ok"),
                    width: 160,
                    fontSize: Style.titleSize,
                    iconSize: 18,
                    height: 45,
                    onPress: () {
                      _controller.reset();
                      _util.navigator.pop();
                    },
                    primaryColor: Color(0xff1ebd4b),
                    accentColor: Color(0xff1ebd4b),
                  ),
                ],
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}

class MyVideoPlayer extends StatefulWidget {
  final String path;
  final bool isNetwork;

  MyVideoPlayer({required this.path, this.isNetwork = false});

  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late final _util = OCSUtil.of(context);
  FlickManager? flickManager;
  bool _loading = false;
  bool _isDownload = false;
  File? _file;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    flickManager?.dispose();
  }

  Future _initVideoPlayer() async {
    if (!widget.isNetwork) {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.file(File(widget.path)));
    } else {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(widget.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDownload) deleteFile(_file!);
        flickManager?.flickControlManager!.pause();
        _util.navigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Colors.black,
        ),
        body: SafeArea(
          child: Parent(
            style: ParentStyle()
              ..height(_util.query.height)
              ..alignmentContent.center()
              ..background.color(Colors.black),
            child: Stack(
              children: [
                _loading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Parent(
                        style: ParentStyle()
                          ..margin(bottom: _util.query.bottom)
                          ..height(_util.query.height)
                          ..background.color(Colors.red),
                        child: FlickVideoPlayer(
                          flickManager: flickManager!,
                          flickVideoWithControls: FlickVideoWithControls(
                            videoFit: BoxFit.fitWidth,
                            controls: FlickPortraitControls(),
                          ),
                        ),
                      ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Parent(
                    gesture: Gestures()
                      ..onTap(() {
                        if (_isDownload) deleteFile(_file!);
                        flickManager?.flickControlManager!.pause();
                        _util.navigator.pop();
                      }),
                    style: ParentStyle()
                      ..padding(all: 10, horizontal: 20)
                      ..borderRadius(all: 10)
                      ..background.color(Colors.white.withOpacity(0.6)),
                    child: Icon(
                      Remix.close_line,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigatorBackButton extends StatefulWidget {
  final bool loading;
  final Function()? onPress;
  final Color iconColor;

  const NavigatorBackButton({
    Key? key,
    this.loading = false,
    this.onPress,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  State<NavigatorBackButton> createState() => _NavigatorBackButtonState();
}

class _NavigatorBackButtonState extends State<NavigatorBackButton> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Platform.isAndroid ? Icons.arrow_back_outlined : Icons.arrow_back_ios,
        size: Platform.isAndroid ? 24 : 22,
        color: widget.iconColor,
      ),
      tooltip: _util.language.key('back'),
      onPressed: () {
        if (widget.loading) return;
        if (widget.onPress == null) {
          _util.navigator.pop();
        } else {
          widget.onPress!();
        }
      },
    );
  }
}

class MyCacheNetworkImage extends StatelessWidget {
  final String url;
  final String? defaultAssetImage;
  final double? iconSize;
  final double? width;
  final double? height;

  const MyCacheNetworkImage({
    Key? key,
    required this.url,
    this.defaultAssetImage,
    this.iconSize,
    this.width = null,
    this.height = null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CacheManager instance = CacheManager(
      Config(
        "customCacheKey",
        stalePeriod: const Duration(days: 15),
        maxNrOfCacheObjects: 100,
      ),
    );
    return CachedNetworkImage(
      cacheManager: instance,
      width: width,
      height: height,
      imageUrl: url,
      placeholder: (c, a) {
        return Center(
          child: SizedBox(
            width: iconSize ?? 30,
            child: Image.asset(
              'assets/images/loading.gif',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      errorWidget: (c, a, b) {
        return defaultAssetImage != null
            ? Image.asset(
                defaultAssetImage!,
                fit: BoxFit.cover,
                width: width,
                height: height,
              )
            : Image.asset(
                'assets/images/no-image.png',
                fit: BoxFit.cover,
                height: height,
                width: width,
              );
      },
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class BuildButton extends StatefulWidget {
  final String? title;

  final IconData? iconData;

  final Function? onPress;

  final double? width;

  final double height;

  final double fontSize;

  final Color textColor;

  final Color? primaryColor;
  final Color? accentColor;

  final bool loading;
  final double iconSize;
  final double radius;
  final bool ripple;

  BuildButton({
    required this.title,
    this.iconData,
    this.onPress,
    this.width,
    this.height = 50,
    this.fontSize: 16,
    this.textColor: Colors.white,
    this.primaryColor,
    this.accentColor,
    this.loading = false,
    this.iconSize = 20,
    this.radius = 5,
    this.ripple = true,
  });

  @override
  _BuildButtonState createState() => _BuildButtonState();
}

class _BuildButtonState extends State<BuildButton> {
  Color primary = OCSColor.primary;
  Color accent = OCSColor.primary;
  late var _util = OCSUtil.of(context);

  @override
  void initState() {
    super.initState();
    if (widget.primaryColor != null)
      primary = widget.primaryColor ?? OCSColor.primary;
    if (widget.accentColor != null) accent = widget.accentColor ?? accent;
  }

  @override
  Widget build(BuildContext context) {
    return Parent(
      gesture: Gestures()
        ..onTap(() {
          if (widget.loading == false && widget.onPress != null)
            widget.onPress!();
        }),
      style: ParentStyle()
        ..padding(all: 5)
        ..height(widget.height)
        ..width(widget.width != null ? widget.width! : _util.query.width)
        ..linearGradient(
          colors: [
            widget.onPress == null ? Color(0xffE19382) : primary,
            widget.onPress == null ? Color(0xffE19382) : primary,
            widget.onPress == null ? Color(0xffE19382) : accent
          ],
          end: Alignment(0.8, 1),
          begin: Alignment.topLeft,
          tileMode: TileMode.mirror,
        )
        ..borderRadius(all: widget.radius)
        ..ripple(widget.ripple ? !widget.loading : widget.ripple)
        ..boxShadow(
          color: primary.withOpacity(0.3),
          offset: Offset(0, 1),
          blur: 5.0,
        )
        ..elevation(1, opacity: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.iconData != null) SizedBox(width: 5),
          widget.loading == false
              ? widget.iconData != null
                  ? Icon(
                      widget.iconData,
                      size: widget.iconSize,
                      color: Colors.white,
                    )
                  : SizedBox()
              : SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
          if (widget.loading || widget.iconData != null)
            SizedBox(
              width: 10,
            ),
          Txt(
            "${widget.title}",
            style: TxtStyle()
              ..fontSize(widget.fontSize)
              ..textColor(widget.textColor),
          )
        ],
      ),
    );
  }
}

class BuildSecondButton extends StatefulWidget {
  final String? title;

  final IconData? iconData;

  final Function? onPress;

  final double? width;

  final double? height;

  final double fontSize;

  final Color? textColor;

  final Color? backgroundColor;

  final bool loading;

  BuildSecondButton({
    required this.title,
    this.iconData,
    this.onPress,
    this.width,
    this.height,
    this.fontSize: 18,
    this.textColor: Colors.white,
    this.backgroundColor,
    this.loading = false,
  });

  @override
  _BuildSecondButtonState createState() => _BuildSecondButtonState();
}

class _BuildSecondButtonState extends State<BuildSecondButton> {
  late var _util = OCSUtil.of(context);

  @override
  Widget build(BuildContext context) {
    return Parent(
      gesture: Gestures()
        ..onTap(() {
          if (widget.loading == false) widget.onPress!();
        }),
      style: ParentStyle()
        ..padding(all: 5)
        ..height(widget.height != null ? widget.height! : 50)
        ..width(widget.width != null ? widget.width! : _util.query.width)
        ..background.color(Colors.white)
        ..borderRadius(all: 5)
        ..elevation(1, opacity: 0.2)
        ..border(all: 0.8, color: OCSColor.primary)
        ..ripple(!widget.loading,
            splashColor: OCSColor.primary.withOpacity(0.2),
            highlightColor: OCSColor.primary.withOpacity(0.2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.iconData != null) SizedBox(width: 5),
          widget.loading == false
              ? widget.iconData != null
                  ? Icon(
                      widget.iconData,
                      size: 20,
                      color: OCSColor.primary,
                    )
                  : SizedBox()
              : SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
          if (widget.loading || widget.iconData != null)
            SizedBox(
              width: 10,
            ),
          Txt(
            "${widget.title}",
            style: TxtStyle()
              // ..margin(bottom: 3)
              ..fontSize(widget.fontSize)
              ..textColor(OCSColor.primary),
          )
        ],
      ),
    );
  }
}

class MyTextArea extends StatefulWidget {
  final String? label;
  final String? placeHolder;
  final Function(String)? onChange;
  final TextEditingController controller;
  final int? minLine;
  final double labelSize;
  final Function(String v)? validation;

  const MyTextArea({
    Key? key,
    this.label,
    this.onChange,
    this.placeHolder,
    required this.controller,
    this.minLine = 3,
    this.labelSize = 14,
    this.validation,
  }) : super(key: key);

  @override
  State<MyTextArea> createState() => _MyTextAreaState();
}

class _MyTextAreaState extends State<MyTextArea> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Row(
            children: [
              Txt(
                widget.label ?? "",
                style: TxtStyle()
                  ..fontSize(widget.labelSize)
                  ..textColor(OCSColor.text.withOpacity(0.7)),
              ),
              if (widget.validation != null)
                Text(
                  "*",
                  style: TextStyle(color: Colors.red),
                )
            ],
          ),
        TextFormField(
          controller: widget.controller,
          minLines: widget.minLine,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          autofocus: false,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: Style.subTitleSize,
            color: OCSColor.text,
          ),
          cursorColor: OCSColor.primary,
          cursorWidth: 2,
          onChanged: widget.onChange != null ? widget.onChange : null,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.placeHolder ?? "",
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
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: OCSColor.border, width: 1),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }
}

class MyTextField extends StatefulWidget {
  final bool obscureText, readOnly, autoFocus;
  final IconData? icon, focusIcon, suffixIcon;
  final String? label, placeholder;
  final FocusNode? focusNode;
  final double? height;
  final double? labelTextSize;
  final double? textSize;
  final double? borderWidth;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final Function(bool)? suffixOnPressed, onFocus;
  final Function(String?)? onSubmitted, onChanged, onSave;
  final Function()? onEditingComplete;
  final Color? focusColor;
  final Color? labelColor;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? errorColor;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autoValidateMode;
  final Widget? leading;
  final bool noStar;
  final int? maxLength;
  final Widget? trailing;
  final double? iconSize;

  MyTextField({
    this.obscureText = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.noStar = false,
    this.onFocus,
    this.icon,
    this.focusIcon,
    this.suffixIcon,
    this.label,
    this.placeholder,
    this.focusNode,
    this.controller,
    this.textInputAction,
    this.textInputType,
    this.suffixOnPressed,
    this.onSubmitted,
    this.onChanged,
    this.onSave,
    this.focusColor,
    this.validator,
    this.autoValidateMode,
    this.leading,
    this.height,
    this.maxLength,
    this.textColor,
    this.labelTextSize,
    this.textSize,
    this.backgroundColor,
    this.labelColor,
    this.borderColor,
    this.borderWidth,
    this.trailing,
    this.errorColor,
    this.onEditingComplete,
    this.iconSize,
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  TextEditingController? controller;
  FocusNode? focusNode;
  bool isFocus = false;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return _MyTextField(
      label: widget.label,
      textColor: widget.textColor,
      labelColor: widget.labelColor,
      labelTextSize: widget.labelTextSize,
      textSize: widget.textSize,
      borderColor: widget.borderColor,
      borderWidth: widget.borderWidth,
      backgroundColor: widget.backgroundColor,
      height: widget.height ?? 50,
      focusNode: focusNode,
      placeholder: widget.placeholder,
      icon: widget.icon,
      leading: widget.leading,
      focusIcon: widget.focusIcon,
      obscureText: widget.obscureText,
      controller: controller,
      suffixOnPressed: widget.suffixOnPressed,
      suffixIcon: widget.suffixIcon,
      readOnly: widget.readOnly,
      textInputAction: widget.textInputAction,
      textInputType: widget.textInputType,
      focusColor: widget.focusColor,
      validator: widget.validator,
      autoFocus: widget.autoFocus,
      isFocus: isFocus,
      onSubmitted: widget.onSubmitted,
      maxLength: widget.maxLength,
      onFocus: (b) {
        if (widget.onFocus != null) widget.onFocus!(b);
        setState(() => isFocus = b);
      },
      onSave: widget.onSave,
      onChanged: widget.onChanged,
      noStar: widget.noStar,
      autoValidateMode:
          widget.autoValidateMode ?? AutovalidateMode.onUserInteraction,
      trailing: widget.trailing,
      onEditingComplete: widget.onEditingComplete,
      errorColor: widget.errorColor,
      iconSize: widget.iconSize ?? 22,
    );
  }
}

/// TextField
class _MyTextField extends FormField<String> {
  _MyTextField({
    String? label,
    String? placeholder,
    Widget? leading,
    IconData? icon,
    bool obscureText = false,
    bool isFocus = false,
    bool autoFocus = false,
    bool readOnly = false,
    double height = 50,
    IconData? focusIcon,
    IconData? suffixIcon,
    Color? focusColor,
    Function(bool)? suffixOnPressed,
    TextEditingController? controller,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    TextInputType? textInputType,
    FormFieldValidator<String?>? validator,
    AutovalidateMode? autoValidateMode,
    Function(String)? onSubmitted,
    Function(bool)? onFocus,
    Function(String)? onChanged,
    Function()? onEditingComplete,
    FormFieldSetter<String>? onSave,
    bool noStar = false,
    int? maxLength,
    Color? textColor,
    Color? backgroundColor,
    Color? labelColor,
    Color? borderColor,
    double? labelTextSize,
    double? borderWidth,
    double? textSize,
    Widget? trailing,
    Color? errorColor,
    double? iconSize,
  }) : super(
            validator: validator,
            onSaved: onSave,
            initialValue: controller?.text,
            autovalidateMode: autoValidateMode,
            builder: (FormFieldState<String> state) {
              return Focus(
                  onFocusChange: onFocus,
                  skipTraversal: true,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (label != null)
                          inputLabel(
                            label: label,
                            readOnly: readOnly,
                            textSize: labelTextSize,
                            errorColor: errorColor,
                            color: labelColor,
                            hasError: state.hasError,
                            isRequired: validator != null && !noStar,
                          ),
                        wrapper(
                            isFocus: focusNode!.hasFocus,
                            hasError: state.hasError,
                            borderColor: borderColor,
                            borderWidth: borderWidth,
                            focusColor: focusColor,
                            height: height,
                            backgroundColor: backgroundColor,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (leading != null) leading,
                                (icon == null)
                                    ? SizedBox(width: 10)
                                    : Parent(
                                        style: ParentStyle()
                                          ..width(45)
                                          ..margin(bottom: 2),
                                        child: Icon(
                                          focusIcon == null
                                              ? icon
                                              : focusNode.hasFocus
                                                  ? focusIcon
                                                  : icon,
                                          size: iconSize,
                                          color: focusNode.hasFocus
                                              ? focusColor != null
                                                  ? focusColor
                                                  : OCSColor.primary
                                              : (textColor ?? OCSColor.text)
                                                  .withOpacity(.6),
                                        ),
                                      ),
                                Expanded(
                                  child: Parent(
                                    style: ParentStyle()
                                      ..margin(top: 2)
                                      ..alignment.center(),
                                    child: TextField(
                                      onEditingComplete: onEditingComplete,
                                      controller: controller,
                                      autofocus: autoFocus,
                                      textInputAction: textInputAction,
                                      focusNode: focusNode,
                                      keyboardType: textInputType,
                                      readOnly: readOnly,
                                      cursorColor:
                                          focusColor ?? OCSColor.primary,
                                      style: TextStyle(
                                        fontSize: textSize ?? 14,
                                        color: textColor ??
                                            OCSColor.text
                                                .withOpacity(readOnly ? .5 : 1),
                                      ),
                                      obscureText: obscureText,
                                      onSubmitted: onSubmitted,
                                      onChanged: (v) async {
                                        String tmpVal = '';

                                        if (maxLength != null &&
                                            (v.length > maxLength)) {
                                          tmpVal = v.substring(0, maxLength);
                                          controller?.text = tmpVal;
                                          controller?.selection = TextSelection(
                                            baseOffset: maxLength,
                                            extentOffset: maxLength,
                                          );
                                        } else {
                                          tmpVal = v;
                                        }

                                        state.didChange(tmpVal);
                                        if (onChanged != null)
                                          onChanged(tmpVal);
                                      },
                                      decoration: InputDecoration(
                                        hintText: placeholder,
                                        hintStyle: TextStyle(
                                            color: (textColor ?? OCSColor.text)
                                                .withOpacity(.5)),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                if (trailing != null) trailing,
                                suffixIcon == null
                                    ? SizedBox(width: 16)
                                    : IconButton(
                                        onPressed: () {
                                          if (suffixOnPressed != null)
                                            suffixOnPressed(!obscureText);
                                        },
                                        icon: Icon(
                                          suffixIcon,
                                          color: OCSColor.icon,
                                          size: 20,
                                        ),
                                      ),
                              ],
                            )),
                        errorElement(state),
                        // SizedBox(height: 10),
                      ]));
            });
}

Widget inputLabel({
  required String label,
  required bool hasError,
  bool isRequired = false,
  bool readOnly = false,
  double? textSize,
  Color? errorColor,
  Color? color,
}) =>
    Row(children: [
      Txt(label,
          style: TxtStyle()
            ..fontSize(12)
            ..maxLines(1)
            ..margin(left: 2)
            ..fontWeight(FontWeight.w500)
            ..textOverflow(TextOverflow.ellipsis)
            ..textColor(hasError
                ? (errorColor ?? OCSColor.danger)
                : (color ?? OCSColor.subText))),
      if (isRequired)
        Txt(
          '*',
          style: TxtStyle()
            ..textColor(
                (errorColor ?? OCSColor.danger).withOpacity(readOnly ? .6 : 1))
            ..alignmentContent.topLeft()
            ..overflow.visible()
            ..scale(-1)
            ..fontSize(11)
            ..height(10)
            ..width(5),
        )
    ]);

Widget errorElement(FormFieldState state) => Parent(
      style: ParentStyle()..margin(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (state.hasError) ...[
            Icon(Remix.information_line, color: Colors.red, size: 12),
            SizedBox(width: 2),
            Txt(
              (state.errorText ?? ''),
              style: TxtStyle()
                ..fontFamily('kmFont')
                ..fontSize(10)
                ..textColor(OCSColor.danger),
            ),
          ],
          if (!state.hasError) SizedBox(height: 10),
        ],
      ),
    );

Widget wrapper({
  required Widget child,
  Function()? onTap,
  required bool hasError,
  double? height,
  double? borderWidth,
  bool isFocus = false,
  Color? borderColor,
  Color? focusColor,
  Color? backgroundColor,
}) =>
    Parent(
        gesture: Gestures()
          ..onTap(() {
            if (onTap != null) onTap();
          }),
        style: ParentStyle()
          ..border(
              all: 1,
              color: hasError
                  ? OCSColor.danger
                  : isFocus
                      ? focusColor ?? OCSColor.primary
                      : borderColor ?? OCSColor.border)
          ..borderRadius(all: 5)
          ..height(height ?? 60)
          ..background.color(backgroundColor ?? Colors.transparent)
          ..animate(250, Curves.ease),
        child: child);

class FormattedNumberField extends StatelessWidget {
  const FormattedNumberField({
    Key? key,
    required this.onChange,
    this.label = 'Number',
    this.initialValue,
    this.format = "xxxx xxxx xxxx xxxx",
    this.separator = ' ',
  }) : super(key: key);
  final Function onChange;
  final String format;
  final String separator;
  final String label;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: TextFormField(
        toolbarOptions: const ToolbarOptions(
          copy: true,
          cut: true,
          paste: false,
          selectAll: false,
        ),
        cursorColor: Colors.black,
        maxLines: 1,
        initialValue: getInitialFormattedNumber(format, initialValue ?? ''),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9$separator]")),
          MaskedTextInputFormatter(
            mask: format,
            separator: separator,
          ),
        ],
        decoration: InputDecoration(
          fillColor: Colors.white,
          counterText: "",
          filled: true,
          isDense: true,
          labelText: label,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
              borderSide: BorderSide(color: Colors.blueGrey)),
        ),
        onChanged: (value) {
          onChange(value.replaceAll(separator, ""));
        },
      ),
    );
  }
}

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}

getInitialFormattedNumber(String format, String str) {
  if (str == '') return '';
  var mask = format;
  str.split("").forEach((item) => {mask = mask.replaceFirst('x', item)});
  return mask.replaceAll('x', "");
}
