import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:explore_sa/models/places_search.dart';

class PlacesService {

  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc';

    var res = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(res.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }

  // Future<Place>getPlace(String search) async {
  //   var url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$search&key=AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI';
  //
  //   var res = await http.get(Uri.parse(url));
  //   var json = convert.jsonDecode(res.body);
  //   var jsonResult = json['result'] as Map<String, dynamic>;
  //   return Place.fromJson(jsonResult);
  // }
}