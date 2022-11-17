import 'dart:async';
import 'package:explore_sa/models/places_search.dart';
import 'package:explore_sa/services/geolocator.dart';
import 'package:explore_sa/services/placesService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ApplicationBloc with ChangeNotifier {
  final geolocatorService = CustomGeolocator();
  final placesService = PlacesService();

  late Position currentLocation;
  late List<PlaceSearch> places;
  //StreamController<Place> selectedLocation = StreamController<Place>();
  var gottenPlace;

  ApplicationBloc(){
    setCurrentLocation();
    places = [];
  }

  setCurrentLocation() async {
    currentLocation = await geolocatorService.getCurrentPosition();
    notifyListeners();
  }

  searchPlace(String search) async {
    places = await placesService.getAutocomplete(search);
    notifyListeners();
  }

  // setSelectedLocation(String search) async {
  //   selectedLocation.add(await placesService.getPlace(search));
  //   gottenPlace = await placesService.getPlace(search);
  //   notifyListeners();
  // }

  @override
  void dispose() {
    //selectedLocation.close();
    super.dispose();
  }
}