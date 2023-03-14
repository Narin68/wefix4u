import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ocs_auth/custom_context.dart';
import 'package:ocs_util/ocs_util.dart';
import '/blocs/service_category/service_category_bloc.dart';
import '/globals.dart';
import '/modals/service_category.dart';
import '/screens/widget.dart';
import 'package:skeletons/skeletons.dart';
import '../select_services.dart';
import 'widget.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late var _util = OCSUtil.of(context);
  List<String> imgList = [];
  List<String> listString = [];
  String filePath = '';
  Uint8List? list;

  @override
  void initState() {
    super.initState();
    context.read<ServiceCategoryBloc>().add(FetchServiceCate(isInit: true));
    if (Globals.hasAuth) context.notificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OCSColor.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          if (Globals.hasAuth) notificationBellBuilder(context),
          // const SizedBox(width: 5),
        ],
        backgroundColor: OCSColor.primary,
        leading: null,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Parent(
              style: ParentStyle()..alignmentContent.center(),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo/logo-white.png',
                    height: 25,
                  ),
                  SizedBox(width: 10),
                  Parent(
                    style: ParentStyle(),
                    child: Image.asset(
                      'assets/logo/wf4u-text.png',
                      height: 15,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Parent(
          style: ParentStyle()..width(_util.query.width),
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<ServiceCategoryBloc>()
                ..add(ReloadServiceCate())
                ..add(FetchServiceCate(isInit: true, getNewData: true));
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Parent(
                    style: ParentStyle(),
                    child: Column(
                      children: [
                        BuildSlider(),
                        _buildCategory(),
                      ],
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

  Widget _buildCategory() {
    return Parent(
      style: ParentStyle(),
      child: BlocBuilder<ServiceCategoryBloc, ServiceCategoryState>(
        builder: (context, state) {
          if (state is ServiceCategoryInitial) {
            return _buildCateLoading();
          }
          if (state is ServiceCategoryLoading) {
            return _buildCateLoading();
          }
          if (state is ServiceCategoryFailure) {
            return SizedBox();
          }
          if (state is ServiceCategorySuccess) {
            if (state.data == null || (state.data?.isEmpty ?? false))
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Parent(
                  style: ParentStyle()
                    ..border(all: 1, color: OCSColor.primary)
                    ..width(_util.query.width)
                    ..background.color(OCSColor.primary.withOpacity(0.2))
                    ..height(45)
                    ..alignmentContent.center()
                    ..borderRadius(all: 5),
                  child: Txt(
                    _util.language.key("no-category"),
                    style: TxtStyle()..fontSize(14),
                  ),
                ),
              );
            return _buildCategoryList(state.data ?? []);
          }
          return _buildCateLoading();
        },
      ),
    );
  }

  Widget _buildCategoryList(List<MServiceCate> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Txt(
              _util.language.key('all-service-cate'),
              style: TxtStyle()
                ..fontSize(Style.titleSize)
                ..fontWeight(FontWeight.bold)
                ..textColor(OCSColor.text)
                ..padding(all: 15, vertical: 5),
            ),
            Expanded(child: SizedBox()),
            Txt(
              _util.language.key('show-all'),
              style: TxtStyle()
                ..padding(all: 15, vertical: 5)
                ..fontSize(Style.subTitleSize)
                ..textColor(OCSColor.primary),
              gesture: Gestures()
                ..onTap(() {
                  _util.navigator.to(
                    SelectServices(),
                    transition: OCSTransitions.UP,
                  );
                }),
            )
          ],
        ),
        Parent(
          style: ParentStyle()
            ..padding(horizontal: 15)
            ..borderRadius(all: 5),
          child: AlignedGridView.count(
            shrinkWrap: true,
            primary: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: data.length,
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            // controller: _scrollCtr,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int i) {
              var imagePath;
              if (i < data.length) {
                imagePath = data[i].imagePath == null
                    ? ''
                    : ApisString.webServer + '/' + (data[i].imagePath ?? "");
              }
              return Parent(
                gesture: Gestures()
                  ..onTap(() {
                    _util.navigator.to(
                      SelectServices(
                        serviceCateId: data[i].id!,
                        serviceCateName: _util.language.by(
                          km: data[i].name,
                          en: data[i].nameEnglish,
                          autoFill: true,
                        ),
                      ),
                      transition: OCSTransitions.UP,
                    );
                  }),
                style: ParentStyle()
                  ..borderRadius(all: 5)
                  ..padding(vertical: 5, horizontal: 5)
                  ..background.color(Colors.white)
                  ..boxShadow(color: Colors.black.withOpacity(0.02), blur: 20),
                child: Parent(
                  style: ParentStyle()..margin(bottom: 5),
                  child: Column(
                    children: [
                      Parent(
                        style: ParentStyle()
                          ..width(65)
                          ..height(65)
                          // todo: change padding
                          ..padding(all: Globals.padding)
                          ..borderRadius(all: 5)
                          ..overflow.hidden()
                          ..background.color(Colors.white),
                        child: MyCacheNetworkImage(
                          iconSize: 20,
                          url: imagePath,
                        ),
                      ),
                      // SizedBox(height: 5),
                      Parent(
                        style: ParentStyle(),
                        child: Txt(
                          _util.language.by(
                            km: data[i].name,
                            en: data[i].nameEnglish,
                            autoFill: true,
                          ),
                          style: TxtStyle()
                            ..fontSize(Style.subTextSize)
                            ..maxLines(3)
                            ..textColor(OCSColor.text)
                            ..textAlign.center()
                            ..textOverflow(TextOverflow.ellipsis),
                        ),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCateLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Txt(
              _util.language.key('all-service-cate'),
              style: TxtStyle()
                ..fontSize(Style.titleSize)
                ..fontWeight(FontWeight.bold)
                ..textColor(OCSColor.text)
                ..padding(all: 15, vertical: 5),
            ),
            Expanded(child: SizedBox()),
            Txt(
              _util.language.key('show-all'),
              style: TxtStyle()
                ..padding(all: 15, vertical: 5)
                ..fontSize(Style.subTitleSize)
                ..textColor(OCSColor.primary),
            )
          ],
        ),
        Parent(
          style: ParentStyle()
            ..borderRadius(all: 5)
            ..padding(horizontal: 15),
          child: AlignedGridView.count(
            shrinkWrap: true,
            primary: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 6,
            crossAxisCount: 3,
            crossAxisSpacing: 7,
            mainAxisSpacing: 7,
            // controller: _scrollCtr,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int i) {
              return Parent(
                style: ParentStyle()
                  ..background.color(Colors.white)
                  ..borderRadius(all: 5)
                  ..height(100)
                  ..padding(vertical: 10, horizontal: 10)
                  ..boxShadow(color: Colors.black.withOpacity(0.05), blur: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        shape: BoxShape.circle,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonLine(
                          style: SkeletonLineStyle(
                              height: 10,
                              width: 80,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
