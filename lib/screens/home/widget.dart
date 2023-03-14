import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';

class BuildSlider extends StatefulWidget {
  const BuildSlider({Key? key}) : super(key: key);

  @override
  State<BuildSlider> createState() => _BuildSliderState();
}

class _BuildSliderState extends State<BuildSlider> {
  List<String> listString = [];
  int _currentIndex = 0;
  late var _util = OCSUtil.of(context);
  List<String> imgList = [
    "assets/banners/slider-1.jpg",
    "assets/banners/slider-2.jpg",
    "assets/banners/slider-3.jpg",
    "assets/banners/slider-4.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return _sliderSection(imgList);
  }

  Widget _sliderSection(List<String> data) {
    imgList = data;

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 7),
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            pageSnapping: true,
            onPageChanged: (index, reason) {
              _currentIndex = index;
              setState(() {});
            },
            enlargeStrategy: CenterPageEnlargeStrategy.scale,
            height: _util.query.width / 2,
          ),
          items: imgList
              .map((item) => Container(
                    child: Center(
                      child: Parent(
                          style: ParentStyle()
                            ..overflow.hidden()
                            ..elevation(1, opacity: 0.2)
                            ..borderRadius(all: 5)
                            ..background.color(Colors.white),
                          child: Image.asset(item)),
                    ),
                  ))
              .toList(),
        ),
        Positioned(
          bottom: -10,
          // left: _util.query.width / 2.2,
          child: Parent(
            style: ParentStyle()..width(_util.query.width),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.map(
                (urlOfItem) {
                  int index = imgList.indexOf(urlOfItem);
                  return Parent(
                    style: ParentStyle()
                      ..border(all: 1, color: OCSColor.primary)
                      ..height(8)
                      ..width(_util.query.width)
                      ..borderRadius(all: 20)
                      ..margin(vertical: 10, horizontal: 2.0)
                      ..animate()
                      ..elevation(1, opacity: 0.2)
                      ..background.color(_currentIndex == index
                          ? OCSColor.primary
                          : Colors.white)
                      ..width(8),
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
