import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as GooglePlace;
import 'package:http/http.dart' as http;
import 'MyColors.dart';
import 'globals.dart';

class LocationServices{

  //polylines declaration
  static Set<Polyline> polylines = Set<Polyline>();
  static List<LatLng> polineCoordinates = [];
  static PolylinePoints polylinePoints = new PolylinePoints();

  //location declaration
  static LatLng currentLatLng = new LatLng(109, 109);
  static LatLng destinationLatLng = new LatLng(109, 109);

  //markers declaration
  static Set<Marker> markers = {};
  static Set<Marker> multipleMarkers = {};


  //methods
  static Set<Polyline> getPolylines(){
    return polylines;
  }

  static Future<bool> setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc",
        PointLatLng(currentLatLng.latitude, currentLatLng.longitude),
        PointLatLng(destinationLatLng.latitude, destinationLatLng.longitude)
    );

    if (result.status == 'OK'){
      result.points.forEach((PointLatLng point) {
        polineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
     polylines.add(
          Polyline(
            width: 3,
            polylineId: PolylineId('polyLine'),
            color: MyColors.darkTeal,
            points: polineCoordinates,
          )
      );
    return true;
  }

  static Future<bool> addMarkers(LatLng origin, LatLng destination) async {

    Marker startMarker = Marker(
      markerId: MarkerId(origin.toString()),
      position: LatLng(
        origin.latitude,
        origin.longitude,
      ),
      infoWindow: InfoWindow(
          title: 'Origin',
          snippet: "originSnippet"
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    // Destination Location Marker
    Marker destinationMarker = Marker(
      markerId: MarkerId(destination.toString()),
      position: LatLng(
        destination.latitude,
        destination.longitude,
      ),
      infoWindow: InfoWindow(
          title: "Destination",
          snippet: "destinationSnippet"
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    markers.add(startMarker);
    markers.add(destinationMarker);
    return true;

  }

  static Future<Address> getUserAddress() async {//call this async method from whereever you need
    print("CONFIRM LAT LNG BEFORE ADDRESS PROCESSS ==================> ${currentLatLng.latitude}/${currentLatLng.longitude}");
    final geoCode = new GeoCode();
    Address address = new Address();
    address = await geoCode.reverseGeocoding(latitude: currentLatLng.latitude, longitude: currentLatLng.longitude).then((value) {
      print("==================================> ADDRESS HAS FINALLY BEEN GENERATED ${value.streetAddress}");
      return value;
    });

    return address;
  }

  static Future<Address> getDestinationAddress() async {//call this async method from whereever you need
    final geoCode = new GeoCode();
    Address address = new Address();
    try {
      address = await geoCode.reverseGeocoding(latitude: destinationLatLng.latitude, longitude: destinationLatLng.longitude);
    } catch (e) {
      print(e);
    }
    return address;
  }

  static Future<List<GooglePlace.SearchResult>> processNearbyPlaces() async {

    await Geolocator.getCurrentPosition().then((currLocation){
        LocationServices.currentLatLng = new LatLng(currLocation.latitude, currLocation.longitude);
    });

    print("'getNearbyPlaces()' ======================================> LATLNG " + currentLatLng.latitude.toString() + " / " + currentLatLng.longitude.toString());
    List<GooglePlace.SearchResult>? temp = [];
    var googlePlace = GooglePlace.GooglePlace("AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc");
    var result = await googlePlace.search.getNearBySearch(GooglePlace.Location(lat: currentLatLng.latitude, lng: currentLatLng.longitude), 1500);

    if (result != null) {
      result.results?.forEach((element) {
        if (element.photos?.first.photoReference != null){
          temp.add(element);
        }
      });
      print("'getNearbyPlaces()' ===================> NEARBY PLACES " + temp.length.toString());
    }
    return temp;
  }

  static Future<GooglePlace.DetailsResult?> processFavPlace(String placeId) async {

    print("PROCESS_NEARBY_PLACES ======================================> CURRENT LAT LNG " + currentLatLng.latitude.toString() + " / " + currentLatLng.longitude.toString());
    var googlePlace = GooglePlace.GooglePlace("AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc");
    GooglePlace.DetailsResponse? result = await googlePlace.details.get(placeId);

    if (result != null) {
      print("PROCESS_NEARBY_PLACES ======================================> RESULT FOUND");
      return result.result;
    }
  }

  static Future navigateToSelectedDestination(double lat, double lng) async {
    Completer<GoogleMapController> _controller = Completer();
    LatLng targetLatLng = new LatLng(lat, lng);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: targetLatLng, zoom: 15)));

    addMarkers(currentLatLng, targetLatLng);
    setPolylines();
  }

  static Future<bool> resetMap() async {
      LocationServices.polineCoordinates.clear();
      LocationServices.polylines.clear();
      LocationServices.polylinePoints = PolylinePoints();
      LocationServices.markers.clear();
      LocationServices.markers = {};
      return true;
  }

  static addMultipleMarkers(List<GooglePlace.SearchResult> nearbySearchResult) {
    print("'addMultipleMarkers()' ====================> ${nearbySearchResult.length}");

    for (var i in nearbySearchResult){
      double? lat = 0;
      double? lng = 0;
      if (i.geometry!.location!.lat != null){
        lat = i.geometry!.location!.lat;
      }
      if (i.geometry!.location!.lng != null){
        lng = i.geometry!.location!.lng;
      }

      print("LAT LNG OF MARKER TO ADD ${i.geometry!.location!.lat} ${i.geometry!.location!.lng}");
      Marker marker = Marker(
        markerId: MarkerId(i.geometry!.location.toString()),
        position: LatLng(lat!, lng!),
        infoWindow: InfoWindow(
            title: 'Origin',
            snippet: "originSnippet"
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
        LocationServices.multipleMarkers.add(marker);
    }
    //this print line confirms that 20 marks have have been successfully stored in 'multipleMarkers' array
    print("============> TOTAL MARKERS " + LocationServices.multipleMarkers.length.toString());
  }

  static List<GooglePlace.SearchResult> getNearbySearchResult(){
    return Globals.nearbySearchResult;
  }

  static Future<LatLng> getCurrentLatLng() async {
    LatLng result = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) {
      currentLatLng = LatLng(value.latitude, value.longitude);
      return LatLng(value.latitude, value.longitude);
    });
    return result;
  }


}