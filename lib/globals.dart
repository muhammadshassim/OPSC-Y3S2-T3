import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as GooglePlace;
import 'customSettings.dart';

class Globals{
  static bool showSpinner = false;
  static String usersName = "non";
  static String usersPrefValue = "non";
  static String usersPrefKey = "non";
  static String measureSystem = "non";
  static double distance = 0;
  static List<GooglePlace.SearchResult> nearbySearchResult = [];
  static StreamController<LatLng> cusMapStreamController = StreamController.broadcast();
  static StreamController<LatLng> cusPlacesStreamController = StreamController.broadcast();
  static GooglePlace.DetailsResult? inFocusPlaceResult;
  static List<GooglePlace.DetailsResult?> favPlacesDetailResult = [];
  static List<GooglePlace.DetailsResult?> prefPlacesDetailResult = [];
  static List<String?> favPlacesImages = [];
  static GooglePlace.DetailsResult? infoOfFavSelectedPlace;
  static List<GooglePlace.Review> reviewsOfSelectedPlace = [];
  static List<String?> iDsOfPreferredPlaces = [];
  static bool enRoute = false;
  static Widget showPage = CustomSettings();

  //only being used for favourites section map routing navigation process
  static double? lat = 0;
  static double? lng = 0;

  static Map<String, String> placeTypes = {
    "Finance": "finance",
    "Restaurant": "food",
    "Health": "health",
    "Landmark": "landmark",
    "Nature": "natural_feature",
    "Holy Places": "place_of_worship",
    "Interests": "point_of_interest",
    "Political": "political",
    "Bar": "bar",
    "Bank": "bank",
    "Park": "amusement_park",
    "Cafe": "cafe",
  };

}
