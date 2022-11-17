import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'MyColors.dart';
import 'globals.dart';

class CustomFloatingActionButton extends StatefulWidget {
  LatLng currentLatLng;
  LatLng destinationLatLng;
  final Function currentPositionFAB;
  final Function resetMap;
  final BuildContext context;
  List<LatLng> polylineCoordinates;
  Function resetView;
  CustomFloatingActionButton({
    Key? key,
    required this.currentLatLng,
    required this.destinationLatLng,
    required this.currentPositionFAB,
    required this.context,
    required this.polylineCoordinates,
    required this.resetMap,
    required this.resetView
  }) : super(key: key);
  @override
  _CustomFloatingActionButtonState createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton> {
  late MapBoxNavigation _directions;
  late MapBoxOptions _options;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _directions = MapBoxNavigation();
  }

  @override
  Widget build(BuildContext context) {
    context = widget.context;
    return SpeedDial(
      marginEnd: 18,
      marginBottom: 20,
      // animatedIcon: AnimatedIcons.menu_close,
      // animatedIconTheme: IconThemeData(size: 22.0),
      /// This is ignored if animatedIcon is non null
      icon: Icons.add,
      activeIcon: Icons.remove,
      // iconTheme: IconThemeData(color: Colors.grey[50], size: 30),
      /// The label of the main button.
      // label: Text("Open Speed Dial"),
      /// The active label of the main button, Defaults to label if not specified.
      // activeLabel: Text("Close Speed Dial"),
      /// Transition Builder between label and activeLabel, defaults to FadeTransition.
      // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
      /// The below button size defaults to 56 itself, its the FAB size + It also affects relative padding and other elements
      buttonSize: 56.0,
      visible: true,
      /// If true user is forced to close dial manually
      /// by tapping main button and overlay is not rendered.
      closeManually: false,
      /// If true overlay will render no matter what.
      renderOverlay: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.yellow.shade700,
      foregroundColor: MyColors.xLightTeal,
      elevation: 8.0,
      shape: CircleBorder(),
      // orientation: SpeedDialOrientation.Up,
      // childMarginBottom: 2,
      // childMarginTop: 2,
      children: [
        //FIRST ICON
        if (widget.polylineCoordinates.length > 0) SpeedDialChild(
          child: Icon(Icons.cancel, color: Colors.white, ),
          backgroundColor: Colors.red,
          label: 'Cancel',
          labelStyle: TextStyle(fontSize: 12.0, color: MyColors.mediumTeal),
          foregroundColor: MyColors.xLightTeal,
          labelBackgroundColor: MyColors.xLightTeal,
          onTap: () {
            Globals.distance = 0;
            widget.resetMap();
            widget.resetView();
          },
          onLongPress: () => print('FIRST CHILD LONG PRESS'),
        ),
        //SECOND ICON
        if (widget.polylineCoordinates.length > 0) SpeedDialChild(
          child: Icon(Icons.navigation_rounded, color: Colors.white, ),
          backgroundColor: MyColors.lightTeal,
          label: 'Navigate',
          labelStyle: TextStyle(fontSize: 12.0, color: MyColors.darkTeal),
          foregroundColor: MyColors.xLightTeal,
          labelBackgroundColor: MyColors.xLightTeal,
          onTap: () => navigate(),
          onLongPress: () => print('SECOND CHILD LONG PRESS'),
        ),
        //THIRD ICON
         SpeedDialChild(
          child: Icon(Icons.location_on, color: Colors.white,),
          backgroundColor: MyColors.mediumTeal,
          label: 'Home',
          foregroundColor: MyColors.xLightTeal,
          labelBackgroundColor: MyColors.xLightTeal,
          labelStyle: TextStyle(fontSize: 12.0),
          onTap: () => widget.currentPositionFAB(),
          onLongPress: () => print('THIRD CHILD LONG PRESS'),
        ),
      ],
    );
  }
  navigate() async {
    MapBoxOptions _options = MapBoxOptions(
        initialLatitude: widget.currentLatLng.latitude,
        initialLongitude: widget.currentLatLng.longitude,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: Globals.measureSystem == "Kilometers" ? VoiceUnits.metric: VoiceUnits.imperial,
        simulateRoute: true,
        language: "en",
    );
    print("=================================================> DESTINATION LAT LNG FOR NAVIGATION " + widget.destinationLatLng.latitude.toString() + " " + widget.destinationLatLng.longitude.toString());
    final origin = WayPoint(name: "Durban", latitude: widget.currentLatLng.latitude, longitude: widget.currentLatLng.longitude);
    final stop = WayPoint(name: "Ballito", latitude: widget.destinationLatLng.latitude, longitude: widget.destinationLatLng.longitude);

    List<WayPoint> wayPoints = [];
    wayPoints.add(origin);
    wayPoints.add(stop);

    await _directions.startNavigation(wayPoints: wayPoints, options: _options,).then((val) => print("===================> REACHED DESTINATION " + val)).onError((error, stackTrace) {
      print("================> ERROR OCCURRED WHILE NAVIGATING");
    });
  }

  Future<Address> getUserAddress() async {//call this async method from whereever you need
    final geoCode = new GeoCode();
    Address address = new Address();
    try {
      address = await geoCode.reverseGeocoding(latitude: widget.currentLatLng.latitude, longitude: widget.currentLatLng.longitude);
    } catch (e) {
      print(e);
    }
    return address;
  }

  Future<Address> getDestinationAddress() async {//call this async method from whereever you need
    final geoCode = new GeoCode();
    Address address = new Address();
    try {
      address = await geoCode.reverseGeocoding(latitude: widget.destinationLatLng.latitude, longitude: widget.destinationLatLng.longitude);
    } catch (e) {
      print(e);
    }
    return address;
  }
  }
