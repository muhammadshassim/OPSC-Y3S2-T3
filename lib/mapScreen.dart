import 'package:explore_sa/application_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:explore_sa/MyColors.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:provider/provider.dart';

class Map extends StatefulWidget {

  // Completer<GoogleMapController> mapController;
  // Map({this.mapController});
  @override
  _MapState createState() => _MapState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class _MapState extends State<Map> {
  List<Marker> markers = [];
  late LatLng currentLatLng;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState(){
    super.initState();
    Geolocator.getCurrentPosition().then((currLocation){
      setState((){
        currentLatLng = new LatLng(currLocation.latitude, currLocation.longitude);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final appBloc = Provider.of<ApplicationBloc>(context);
    return new Scaffold(
      body: Stack(
          children: [
            currentLatLng == null ?
            Center(child: CircularProgressIndicator(),) :
            GoogleMap(
              onTap: handletap,
              markers: Set.from(markers),
              trafficEnabled: false,
              rotateGesturesEnabled: true,
              buildingsEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(target: LatLng(appBloc.currentLocation.latitude, appBloc.currentLocation.longitude), zoom: 15),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);

              },
            ),
          ],
      ),
      floatingActionButton: Platform.isAndroid ? FloatingActionButton(
        child: const Icon(Icons.my_location, color: Colors.white,),
        backgroundColor: MyColors.darkTeal,
        onPressed: () => _currentPosition(),
      ) : FloatingActionButton(
        child: const Icon(Icons.my_location, color: Colors.white,),
        backgroundColor: MyColors.darkTeal,
        onPressed: () => _currentPosition(),
      ),
    );
  }

  Future<void> _currentPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLatLng, zoom: 15)));
  }

  handletap(LatLng point) {
    setState(() {
      markers = [];
      markers.add(
        Marker(markerId: MarkerId(point.toString()), position: point, draggable: true, onDragEnd: (finalLatLng) {
          print(" ===================================> " + finalLatLng.longitude.toString());
        })
      );
    });
  }


}