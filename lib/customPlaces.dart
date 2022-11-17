import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_sa/MyColors.dart';
import 'package:explore_sa/customMap.dart';
import 'package:explore_sa/locationServices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as GooglePlace;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scrollable_panel/scrollable_panel.dart';
import 'package:http/http.dart' as http;
import 'customPlace.dart';
import 'globals.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:accordion/accordion.dart';

class CustomPlaces extends StatefulWidget {
  final Stream<LatLng> stream;
  final Function changeViewToMap;
  CustomPlaces({Key? key, required this.stream, required this.changeViewToMap}) : super(key: key);

  @override
  _CustomPlacesState createState() => _CustomPlacesState();
}

class _CustomPlacesState extends State<CustomPlaces> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  List<String> favLocationIDs = [];
  List<Place> favPlacesData = [];
  List<Result> favPlacesResult = [];
  bool showBuilder = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      Globals.showSpinner = true;
    });

    LocationServices.processNearbyPlaces().then((value) {
      Globals.nearbySearchResult = value;
      //fav
      getSavedFavs().then((value) {
        value.forEach((element) {
        getFavPlacesDetailResult(element).then((value) {
            Globals.favPlacesDetailResult.add(value);
            if (favLocationIDs.length == Globals.favPlacesDetailResult.length){
              //Globals.inFocusPlaceResult = value;
              setState(() {
                Globals.inFocusPlaceResult = value;
                Globals.showSpinner = false;
              });
            }
          });
        });
      });
      //pref
      getPrefPlaces().then((value) {
        value.forEach((element) {
          getPrefPlacesDetailResult(element!).then((value) {
            setState(() {
              Globals.prefPlacesDetailResult.add(value);
              Globals.inFocusPlaceResult = value;
              Globals.showSpinner = false;
            });
          });
        });
      });
    });
    widget.stream.listen((latlng) {
      navigate(latlng);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.lightGreen.shade200,
      child: Globals.showSpinner ?
      Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: Colors.lightGreen.shade200,
        child: Center(
          child: Wrap(
            direction: Axis.vertical,
            alignment: WrapAlignment.center,
            children: [
              Center(child: CircularProgressIndicator(color: MyColors.xLightTeal,)),
              SizedBox(height: height * 0.1,),
            ],
          ),
        ),
      ):
          Container(
            width: double.infinity,
            height: height,
            child: Stack(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0, height * 0.08, 0, 0),
                              width: width * 0.9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MyColors.xLightTeal,
                              ),
                              child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: height * 0.01),
                                  child: Text("Favourites", textAlign: TextAlign.center, style: TextStyle(color: MyColors.darkTeal, fontSize: 16, fontWeight: FontWeight.bold),)
                              ),
                            ),
                            Wrap(
                              children: [
                                Globals.favPlacesDetailResult.length < 1 ?
                                Container(width: width * 0.9, height: height * 0.3, child: Text("No Data Available", textAlign: TextAlign.center, style: TextStyle(color: MyColors.xLightTeal),), padding: EdgeInsets.symmetric(vertical: height * 0.1, horizontal: 0),):
                                Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    width: width * 0.9,
                                    height: height * 0.3,
                                    child: CarouselSlider(
                                      options: CarouselOptions(height: height * 0.3),
                                      items: Globals.favPlacesDetailResult.map((i) {
                                        return Builder(
                                            builder: (BuildContext context) {
                                              return Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                                    child: _boxes(
                                                        "https://maps.googleapis.com/maps/api/place/photo?maxwidth=195&photoreference=${i?.photos?.first.photoReference}&key=AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc",
                                                        i?.name,
                                                        i?.rating,
                                                        i?.geometry?.location?.lat,
                                                        i?.geometry?.location?.lng,
                                                        i?.types,
                                                        i?.placeId,
                                                      i?.reviews?.length
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      color: MyColors.xLightTeal,
                                                    ),
                                                    width: width * 0.9,
                                                    height: height * 0.06,
                                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        GestureDetector(
                                                          child: Icon(Icons.favorite_rounded, size: 32, color: MyColors.darkTeal,),
                                                          onTap: () async {
                                                            setState(() {
                                                              Globals.showSpinner = true;
                                                            });
                                                            bool done = false;
                                                            var val=[];
                                                            val.add('${i?.placeId}');
                                                            await usersRef.doc(auth.currentUser?.uid).update({"favLocations":FieldValue.arrayRemove(val)}).then((value){
                                                              print("DONE =======================> DATA REMOVED");
                                                            });
                                                            setState(() {
                                                              Globals.showSpinner = false;
                                                            });
                                                          },
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 8.0),
                                                          child: Container(
                                                              width: width * 0.35,
                                                              child: Wrap(
                                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                                direction: Axis.horizontal,
                                                                alignment: WrapAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    "${i?.name}",
                                                                    style: TextStyle(
                                                                      color: MyColors.darkTeal,
                                                                      fontSize: 12.0,
                                                                      fontWeight: FontWeight.bold,),
                                                                    textAlign: TextAlign.center,
                                                                  )],
                                                              )),
                                                        ),
                                                        GestureDetector(
                                                          child: Container(child: Icon(Icons.info_outline_rounded, size: 32, color: MyColors.darkTeal,)),
                                                          onTap: () {
                                                            Globals.lat = Globals.infoOfFavSelectedPlace?.geometry?.location?.lat;
                                                            Globals.lng = Globals.infoOfFavSelectedPlace?.geometry?.location?.lng;
                                                            Globals.infoOfFavSelectedPlace = i;
                                                            Globals.favPlacesImages = [];
                                                            Globals.reviewsOfSelectedPlace.clear();
                                                            Globals.favPlacesDetailResult.forEach((element1) {
                                                              if (element1?.placeId == i?.placeId) {
                                                                element1?.photos?.forEach((element2) {
                                                                  Globals.favPlacesImages.add(element2.photoReference);
                                                                });
                                                              }
                                                            });
                                                            Globals.infoOfFavSelectedPlace?.reviews?.forEach((element) {
                                                              Globals.reviewsOfSelectedPlace.add(element);
                                                            });

                                                            showMaterialModalBottomSheet(context: context, builder: (context){
                                                              return PlaceInfo(placeId: i?.placeId,);
                                                            },
                                                                bounce: true,
                                                                duration: Duration(seconds: 1));
                                                            //Globals.streamController.add(LatLng(lat!, lng!));
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: width * 0.05),
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      }).toList(),
                                    )
                                )],
                            ),
                            //PREFERENCES
                            Container(
                              margin: EdgeInsets.fromLTRB(0, height * 0.08, 0, 0),
                              width: width * 0.9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MyColors.xLightTeal,
                              ),
                              child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: height * 0.01),
                                  child: Text("Preferences", textAlign: TextAlign.center, style: TextStyle(color: MyColors.darkTeal, fontSize: 16, fontWeight: FontWeight.bold),)
                              ),
                            ),
                            Wrap(
                              children: [
                                Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    width: width * 0.9,
                                    height: height * 0.3,
                                    child: CarouselSlider(
                                      options: CarouselOptions(height: height * 0.3),
                                      items: Globals.prefPlacesDetailResult.map((i) {
                                        return i?.rating == null ?
                                        Container(width: double.infinity, child: Text("No Data Available", textAlign: TextAlign.center, style: TextStyle(color: MyColors.xLightTeal),), padding: EdgeInsets.symmetric(vertical: height * 0.1, horizontal: 0),):
                                        Builder(
                                            builder: (BuildContext context) {
                                              return Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                                    child: _boxes(
                                                        "https://maps.googleapis.com/maps/api/place/photo?maxwidth=195&photoreference=${i?.photos?.first.photoReference}&key=AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc",
                                                        i?.name,
                                                        i?.rating,
                                                        i?.geometry?.location?.lat,
                                                        i?.geometry?.location?.lng,
                                                        i?.types,
                                                        i?.placeId,
                                                      i?.reviews?.length
                                                    ),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      color: MyColors.xLightTeal,
                                                    ),
                                                    width: width * 0.9,
                                                    height: height * 0.06,
                                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        GestureDetector(
                                                          child: Icon(Icons.favorite_rounded, size: 32, color: MyColors.xLightTeal,),
                                                          onTap: () async {
                                                            DocumentSnapshot result;

                                                            await usersRef.doc(auth.currentUser?.uid).get().then((value) {
                                                              result = value;
                                                              try {
                                                                List<dynamic> data = result.get('favLocations');
                                                              } catch (error){
                                                                List<String> initialField = [];
                                                                usersRef.doc(auth.currentUser?.uid).update({'favLocations': FieldValue.arrayUnion(initialField)});
                                                              } finally {
                                                                //usersRef.doc(auth.currentUser?.uid).update({'favLocations': FieldValue.arrayUnion(fav)});
                                                              }
                                                            });

                                                          },
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 8.0),
                                                          child: Container(
                                                              width: width * 0.35,
                                                              child: Wrap(
                                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                                direction: Axis.horizontal,
                                                                alignment: WrapAlignment.center,
                                                                children: [
                                                                  Text(
                                                                    "${i?.name}",
                                                                    style: TextStyle(
                                                                      color: MyColors.darkTeal,
                                                                      fontSize: 12.0,
                                                                      fontWeight: FontWeight.bold,),
                                                                    textAlign: TextAlign.center,
                                                                  )],
                                                              )),
                                                        ),
                                                        GestureDetector(
                                                          child: Container(child: Icon(Icons.info_outline_rounded, size: 32, color: MyColors.darkTeal,)),
                                                          onTap: () {
                                                            Globals.lat = Globals.infoOfFavSelectedPlace?.geometry?.location?.lat;
                                                            Globals.lng = Globals.infoOfFavSelectedPlace?.geometry?.location?.lng;
                                                            Globals.infoOfFavSelectedPlace = i;
                                                            Globals.favPlacesImages = [];
                                                            Globals.reviewsOfSelectedPlace.clear();
                                                            Globals.prefPlacesDetailResult.forEach((element1) {
                                                              if (element1?.placeId == i?.placeId) {
                                                                element1?.photos?.forEach((element2) {
                                                                  Globals.favPlacesImages.add(element2.photoReference);
                                                                });
                                                              }
                                                            });
                                                            Globals.infoOfFavSelectedPlace?.reviews?.forEach((element) {
                                                              Globals.reviewsOfSelectedPlace.add(element);
                                                            });

                                                            showMaterialModalBottomSheet(context: context, builder: (context){
                                                              return PlaceInfo(placeId: i?.placeId,);
                                                            },
                                                                bounce: true,
                                                                duration: Duration(seconds: 1));
                                                            //Globals.streamController.add(LatLng(lat!, lng!));
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: width * 0.05),
                                                  ),
                                                ],
                                              );
                                            }
                                        );
                                      }).toList(),
                                    )
                                )],
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
    );
  }

  Future<GooglePlace.DetailsResult?> getFavPlacesDetailResult(String placeId) async {
    var googlePlace = GooglePlace.GooglePlace("AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc");
    GooglePlace.DetailsResponse? result = await googlePlace.details.get(placeId);
    print("PROCESS_NEARBY_PLACES ======================================> RESULT FOUND ${result?.result?.name}");
    return result?.result;
  }

  Future<GooglePlace.DetailsResult?> getPrefPlacesDetailResult(String placeId) async {
    var googlePlace = GooglePlace.GooglePlace("AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc");
    GooglePlace.DetailsResponse? result = await googlePlace.details.get(placeId);
    print("PROCESS_NEARBY_PLACES ======================================> RESULT FOUND ${result?.result?.name}");
    return result?.result;
  }

  //extract fav IDs
  Future<List<String>> getSavedFavs() async {
    DocumentSnapshot result;
    List<String> fav = [];
    await usersRef.doc(auth.currentUser?.uid).get().then((value) {
      result = value;
      try {
        List<dynamic> data = result.get('favLocations');
        data.forEach((element) {
          fav.add(element);
        });
        favLocationIDs = fav;
      } catch (error){
        List<String> initialField = [];
        usersRef.doc(auth.currentUser?.uid).update({'favLocations': FieldValue.arrayUnion(initialField)});
      } finally {
        usersRef.doc(auth.currentUser?.uid).update({'favLocations': FieldValue.arrayUnion(fav)});
      }
    });

    return fav;
  }

  //for a specific preference
  Future<List<String?>> getPrefPlaces() async {
    List<String?> prefIDs = [];

    Globals.nearbySearchResult.forEach((element) {
      if (element.types?.contains(Globals.usersPrefValue) == true){
        print("########################################## PREFERRED PLACE FOUND ${element.types}");
        prefIDs.add(element.placeId);
      }
    });
    return prefIDs;
  }

  //for a specific place
  Future<Place> getPlaceDetails(String? placeID) async {
    http.Response result;
    result = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc&place_id=$placeID"));
    print(result.body);
    return Place.fromJson(jsonDecode(result.body));
  }

  //for a specific place
  Future<Place> getPreferredPlaces(String? placeID) async {
    http.Response result;
    result = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc&place_id=$placeID"));
    print(result.body);
    return Place.fromJson(jsonDecode(result.body));
  }

  Widget _boxes(String? _image, String? placeName, double? rating, double? lat, double? lng, List<String>? types, String? placeId, int? reviewCount) {
    return  GestureDetector(
      child: Container(
        child: new FittedBox(
          child: Material(
              color: MyColors.xLightTeal,
              borderRadius: BorderRadius.circular(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 400,
                    height: 400,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: NetworkImage(_image!),
                      ),
                    ),),
                  Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: myDetailsContainer1(placeName!, rating!, types, lat, lng, placeId, reviewCount),
                        ),
                      ],
                    )
                  ),

                ],)
          ),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String placeName, double rating, List<String>? types, double? lat, double? lng, String? placeId, int? reviewCount) {
    FirebaseAuth auth = FirebaseAuth.instance;
    CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
    List<String> fav = ["$placeId"];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              width: 250,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    placeName,
                    style: TextStyle(
                      color: MyColors.darkTeal,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,),
                    textAlign: TextAlign.center,
                  )],
              )),
        ),
        SizedBox(height:5.0),
        Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    child: Text(
                      rating.toString(),
                      style: TextStyle(
                        color: MyColors.darkTeal,
                        fontSize: 18.0,
                      ),
                    )),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStar,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                  child: Icon(
                    FontAwesomeIcons.solidStarHalf,
                    color: Colors.amber,
                    size: 15.0,
                  ),
                ),
                Container(
                    child: Text(
                      "($reviewCount)",
                      style: TextStyle(
                        color: MyColors.darkTeal,
                        fontSize: 18.0,
                      ),
                    )),
              ],
            )),
        SizedBox(height:5.0),
        Container(
            child: Text(
              "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
              style: TextStyle(
                color: MyColors.darkTeal,
                fontSize: 18.0,
              ),
            )),
        SizedBox(height:5.0),
        Container(
            child: Text(
              "Closed \u00B7 Opens 17:00 Thu",
              style: TextStyle(
                  color: MyColors.darkTeal,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            )),

      ],
    );
  }

  void navigate(LatLng targetLatLng) async {
    print("STARTING NAVIGATION =====================+> ");
    bool val = true;
    LocationServices.resetMap();
    setState(() {
      Globals.showSpinner = true;
      LocationServices.destinationLatLng = targetLatLng;
    });

    await LocationServices.addMarkers(LocationServices.currentLatLng, targetLatLng).then((value) {
      setState(() {
      });
    });

    await LocationServices.setPolylines().then((value) {
      setState(() {
        //Globals.showPage = CustomMap(stream: Globals.cusMapStreamController.stream);
        val = !val;
        Globals.showSpinner = false;
        widget.changeViewToMap();
      });

    });
  }
}

class PlaceInfo extends StatefulWidget {
  final String? placeId;
  const PlaceInfo({Key? key, this.placeId}) : super(key: key);

  @override
  _PlaceInfoState createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {
  List<String> temp = [];

  @override
  void initState() {
    super.initState();
    print("STATE HAS BEEN IMPLEMENTED ======= ======== ====== ====== ======= =====");
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.yellow.shade100,
      width: width,
      height: height * 0.9,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                  child: Container(
                      width: width * 0.35,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.start,
                        children: [
                          Text(
                            "${Globals.infoOfFavSelectedPlace?.name}",
                            style: TextStyle(
                              color: MyColors.darkTeal,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,),
                            textAlign: TextAlign.start,
                          )],
                      ),
                    margin: EdgeInsets.fromLTRB(10, 20, 0, 10)
                  ),
              ),
              SizedBox(width: 10,),
              GestureDetector(
                child: Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade500,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.navigation_rounded, color: Colors.yellow, size: 30,),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        margin: EdgeInsets.fromLTRB(0, 20, 10, 0)
                    )
                ),
                onTap: () async {
                  double? lat = Globals.infoOfFavSelectedPlace?.geometry?.location?.lat;
                  double? lng = Globals.infoOfFavSelectedPlace?.geometry?.location?.lng;
                  Globals.cusPlacesStreamController.add(
                      LatLng(lat!, lng!)
                  );
                },
              ),
              SizedBox(width: 10,)
            ],
          ),
          //open-closed logic
          Row(children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                  "${Globals.infoOfFavSelectedPlace?.openingHours?.openNow == true ? "Open Now": "Closed"}",
                  style: TextStyle(color: MyColors.darkTeal),
              ),
            ),
          ],),
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text("${Globals.infoOfFavSelectedPlace?.rating}", style: TextStyle(color: MyColors.darkTeal)),
              ),
              Container(
                child: RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Container(
                    child: Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  onRatingUpdate: (rating) {
                  },
                  itemSize: 16,
                ),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Text(" (${Globals.infoOfFavSelectedPlace?.userRatingsTotal})",
                    style: TextStyle(color: MyColors.darkTeal),
                  )
              ),
            ],
          ),
          SizedBox(height: height * 0.02,),
          Row(
            children: [
              Container(
                width: width,
                child: CarouselSlider.builder(
                  itemCount: Globals.favPlacesImages.length,
                  itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                        Globals.favPlacesImages.length == 0 ? Container(
                            child:
                            Row(
                              children: [
                                Icon(Icons.error, color: Colors.red,),
                                Text(" No Images Found", style: TextStyle(color: MyColors.xLightTeal),),
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: MyColors.darkTeal
                            ),
                          padding: EdgeInsets.symmetric(vertical: 60, horizontal: 80),
                        ):
                        ClipRRect(
                        borderRadius: new BorderRadius.circular(10),
                          child: Image(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                                Globals.favPlacesImages == null ? "Hi" :
                                "https://maps.googleapis.com/maps/api/place/photo?maxwidth=195&photoreference=${Globals.favPlacesImages[itemIndex]}&key=AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc",
                            ),
                          ),
                      ), options: CarouselOptions(
                            height: 200,
                            aspectRatio: 16/9,
                            viewportFraction: 0.8,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration: Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                ),
                ),
              )
            ],
          ),
          Container(
            height: height * 0.5,
            width: width,
            child: Accordion(
              headerBackgroundColor: Colors.deepOrange,
              contentBackgroundColor: Colors.white,
              contentBorderColor: Colors.deepOrange,
              contentBorderWidth: 4,
              headerTextAlign: TextAlign.center,
              maxOpenSections: 1,
              headerTextStyle: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              children: [
                AccordionSection(
                  leftIcon: Icon(Icons.preview_rounded, color: Colors.white,),
                  isOpen: true,
                  headerText: 'Overview',
                  content: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.title_rounded, ),
                            Text(" ${Globals.infoOfFavSelectedPlace?.name}"),
                          ],
                        ),
                        Divider(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on),
                            Container(
                                width: width * 0.6,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  direction: Axis.horizontal,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Text(
                                      " ${Globals.infoOfFavSelectedPlace?.formattedAddress}",
                                      style: TextStyle(
                                        color: MyColors.darkTeal,
                                      ),
                                      textAlign: TextAlign.center,
                                    )],
                                )),
                          ],
                        ),
                        Divider(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone),
                            Text(" ${Globals.infoOfFavSelectedPlace?.formattedPhoneNumber}"),
                          ],
                        ),
                        Divider(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work),
                            Text(" ${Globals.infoOfFavSelectedPlace?.businessStatus}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AccordionSection(
                  leftIcon: Icon(Icons.rate_review_rounded, color: Colors.white,),
                  isOpen: false,
                  headerText: 'Reviews',
                  content: CarouselSlider.builder(
                    itemCount: Globals.reviewsOfSelectedPlace.length,
                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                                width: width * 0.6,
                                height: height * 0.2,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  direction: Axis.horizontal,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Text(
                                      "${Globals.reviewsOfSelectedPlace[itemIndex].authorName}",
                                      style: TextStyle(
                                        color: MyColors.darkTeal,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 5,),
                                    Text(
                                      "${Globals.reviewsOfSelectedPlace[itemIndex].text}",
                                      style: TextStyle(
                                        color: MyColors.darkTeal,
                                        fontSize: 14.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  runAlignment: WrapAlignment.center,
                                )),
                          ),
                        ),
                    options: CarouselOptions(
                    height: 200,
                    aspectRatio: 16/9,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                  ),
                  ),
                ),
                AccordionSection(
                  leftIcon: Icon(Icons.info_rounded, color: Colors.white,),
                  isOpen: false,
                  headerText: 'Additional Info',
                  content: Text("No data available", textAlign: TextAlign.center,)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


class _PanelView extends StatefulWidget {
  final GooglePlace.DetailsResult? inFocusPlaceResult;
  const _PanelView({Key? key, this.inFocusPlaceResult}) : super(key: key);

  @override
  _PanelViewState createState() => _PanelViewState();
}

class _PanelViewState extends State<_PanelView> {
  GooglePlace.DetailsResult? inFocusPlaceResult;
  _PanelViewState({this.inFocusPlaceResult});
  late GooglePlace.DetailsResult? data;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    const double circularBoxHeight = 18.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height + kToolbarHeight + 44.0,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            decoration: BoxDecoration(
              color: MyColors.xLightTeal,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(circularBoxHeight), topRight: Radius.circular(circularBoxHeight)),
              border: Border.all(color: MyColors.darkTeal),
            ),
            width: width,
            child: Text("${inFocusPlaceResult?.name}", textAlign: TextAlign.center,),
          ),
        );
      },
    );
  }
}
