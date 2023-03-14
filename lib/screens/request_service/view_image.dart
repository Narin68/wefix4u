import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';

class ViewMultiImage extends StatefulWidget {
  final List<XFile>? images;
  final String? path;
  final List<String>? paths;
  final bool isXFile;
  final int? index;
  final bool showNum;

  ViewMultiImage({
    this.images,
    this.path,
    this.index = 0,
    this.paths,
    this.isXFile = true,
    this.showNum = true,
  });

  @override
  _ViewMultiImageState createState() => _ViewMultiImageState();
}

class _ViewMultiImageState extends State<ViewMultiImage> {
  late final _util = OCSUtil.of(context);

  PageController? _pageController;

  int? index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index!);
    index = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Parent(
        style: ParentStyle()
          ..width(_util.query.width)
          ..height(_util.query.height),
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount:
                  widget.isXFile ? widget.images!.length : widget.paths!.length,
              builder: (context, i) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: widget.isXFile
                      ? FileImage(
                          File(widget.images![i].path),
                        )
                      : NetworkImage(widget.paths![i]) as ImageProvider,
                  maxScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                );
              },
              onPageChanged: (page) {
                index = page;
                setState(() {});
              },
            ),
            Positioned(
                top: _util.query.top - 10,
                child: IconButton(
                  onPressed: () {
                    _util.navigator.pop();
                  },
                  icon: const Icon(
                    Remix.close_line,
                    size: 30,
                    color: Colors.white,
                  ),
                )),
            if (widget.showNum)
              Positioned(
                bottom: _util.query.bottom,
                left: 20,
                child: Txt(
                  "Images ${index! + 1}/${widget.isXFile ? widget.images?.length : widget.paths?.length}",
                  style: TxtStyle()
                    ..textColor(Colors.white)
                    ..fontSize(14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
