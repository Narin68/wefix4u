import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:ocs_util/ocs_util.dart';
import 'package:remixicon/remixicon.dart';
import 'package:map_picker/map_picker.dart';
import 'package:search_map_location/search_map_location.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import '/globals.dart';
import 'package:http/http.dart' as http;
import 'widget.dart';

class MyMapPicker extends StatefulWidget {
  final double? lat;

  final double? long;

  final Function? onSubmit;

  MyMapPicker({this.lat, this.long, this.onSubmit});

  @override
  _MyMapPickerState createState() => _MyMapPickerState();
}

class _MyMapPickerState extends State<MyMapPicker> {
  Completer<GoogleMapController> _controller = Completer();
  MapPickerController mapPickerController = MapPickerController();

  GoogleMapController? _googleMapController;

  CameraPosition cameraPosition = CameraPosition(
    target: LatLng(12.5657, 104.9910),
    zoom: 6,
  );

  late var _util = OCSUtil.of(context);

  String _addressLine = "";

  var textController = TextEditingController();
  double _lat = 0;
  double _long = 0;
  bool isSearch = false;
  bool _loading = false;
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: GoogleApiKey.googleApiKey);
  Set<Marker> markers = Set();
  bool _loadingMap = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future _init() async {
    if (widget.lat != null) await initLocation();
    if (widget.lat == null) await getUserLocation();

    if (widget.lat != null) await setMarker();
  }

  initLocation() async {
    CameraPosition cameraPosition = new CameraPosition(
      target: LatLng(widget.lat ?? 0, widget.long ?? 0),
      zoom: 18,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  getUserLocation() async {
    setState(() {
      _loading = true;
    });
    await getUserCurrentLocation().then((value) async {
      // specified current users location
      CameraPosition cameraPosition = new CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 18,
      );
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      _addressLine = "";
    });
    setState(() {
      _loading = false;
    });
    _addressLine = "";
  }

  setMarker() {
    var start = LatLng(widget.lat ?? 0, widget.long ?? 0);

    markers.add(
      Marker(
        markerId: MarkerId(start.toString()),
        position: start,
        infoWindow: InfoWindow(
          title: 'Starting Point ',
          snippet: 'Start Marker',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: NavigatorBackButton(),
        backgroundColor: OCSColor.primary,
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Txt(
            _util.language.key("pin-map"),
            style: TxtStyle()
              ..fontSize(16)
              ..textColor(Colors.white),
          ),
        ),
        actions: [],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Parent(
              style: ParentStyle()
                ..height(_util.query.isKbPopup
                    ? _util.query.height
                    : _util.query.height - _util.query.kbHeight),
              child: MapPicker(
                iconWidget: Icon(
                  Icons.place,
                  size: 45,
                  color: Colors.red,
                ),
                showDot: true,
                mapPickerController: mapPickerController,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  initialCameraPosition: cameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _googleMapController = controller;
                    _controller.complete(controller);
                  },
                  markers: Set<Marker>.of(markers),
                  onCameraMoveStarted: () {
                    mapPickerController.mapMoving!();
                  },
                  onCameraMove: (cameraPosition) {
                    this.cameraPosition = cameraPosition;
                  },
                  onCameraIdle: () async {
                    mapPickerController.mapFinishedMoving!();

                    await _onMoveMap();
                    setState(() {});
                  },
                  onTap: (LatLng latLng) async {
                    var newLatLng = LatLng(latLng.latitude, latLng.longitude);
                    _googleMapController!.animateCamera(
                        CameraUpdate.newCameraPosition(
                            CameraPosition(target: newLatLng, zoom: 18)
                            //17 is new zoom level
                            ));
                    setState(() {});
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: _util.query.width,
                child: SearchLocation(
                  iconColor: OCSColor.primary,
                  icon: Remix.search_2_line,
                  language: Globals.langCode == 'en' ? "en" : "km",
                  placeholder: _util.language.key('search'),
                  country: "kh",
                  apiKey: GoogleApiKey.googleApiKey,
                  onSelected: (Place place) async {
                    await displayPrediction(place.placeId);
                  },
                ),
              ),
            ),
            if (!_util.query.isKbPopup) ...[
              if (_loading)
                Positioned(
                  child: Container(
                    color: Colors.black.withOpacity(.3),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                ),
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getUserCurrentLocation().then((value) async {
            // specified current users location
            CameraPosition cameraPosition = new CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 18,
            );

            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        child: Icon(Icons.person_pin),
      ),
      bottomSheet: _util.query.isKbPopup
          ? SizedBox()
          : Parent(
              style: ParentStyle()
                ..padding(all: 15)
                ..boxShadow(
                  color: Colors.black.withOpacity(0.10),
                  offset: Offset(0, 0),
                  blur: 15,
                )
                ..height(165 + _util.query.bottom)
                ..borderRadius(all: 15)
                ..background.color(Colors.white),
              child: Column(
                children: [
                  if (_loadingMap || _loading) Txt("Loading..."),
                  if (!_loadingMap && !_loading)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Remix.pin_distance_line, color: OCSColor.primary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Txt(
                            "${_addressLine}",
                            style: TxtStyle()
                              ..textColor(Colors.black)
                              ..textColor(OCSColor.text)
                              ..maxLines(3)
                              ..textOverflow(TextOverflow.ellipsis)
                              ..fontSize(Style.subTitleSize),
                          ),
                        ),
                      ],
                    ),
                  Expanded(child: SizedBox()),
                  BuildButton(
                    title: _util.language.key('select'),
                    fontSize: Style.titleSize,
                    height: 45,
                    onPress: _loading || _loadingMap
                        ? null
                        : () {
                            _util.navigator.pop();
                            widget.onSubmit!(_addressLine, _lat, _long);
                          },
                  ),
                ],
              ),
            ),
    );
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  _onMoveMap() async {
    setState(() {
      _loadingMap = true;
    });
    var uri = Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${cameraPosition.target.latitude},${cameraPosition.target.longitude}&key=${GoogleApiKey.googleApiKey}");

    var _res = await http.get(uri);

    if (_res.statusCode == 200) {
      _addressLine = "";
      var data = jsonDecode(_res.body);
      List locations = [];
      locations = data['results'][0]["address_components"];
      for (int i = 1; i < locations.length; i++) {
        _addressLine += locations[i]['long_name'] + ", ";
      }
      if (_addressLine.lastIndexOf(",") >= -1) {
        _addressLine = _addressLine.replaceRange(_addressLine.lastIndexOf(","),
            _addressLine.lastIndexOf(",") + 1, "");
        textController.text = _addressLine;
      } else
        textController.text = _addressLine;
    }
    _lat = cameraPosition.target.latitude;
    _long = cameraPosition.target.longitude;
    setState(() {
      _loadingMap = false;
    });
  }

  Future<Null> displayPrediction(String? p) async {
    if (p != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p);
      double lat = detail.result.geometry?.location.lat ?? 0;
      double lng = detail.result.geometry?.location.lng ?? 0;
      _lat = lat;
      _long = lng;

      var newLatLng = LatLng(lat, lng);

      _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: newLatLng, zoom: 18)
            //17 is new zoom level
            ),
      );
      setState(() {});
    }
  }
}
