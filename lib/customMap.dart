import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_sa/customFloatingActionButton.dart';
import 'package:explore_sa/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as GooglePlace;
import 'MyColors.dart';
import 'application_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_panel/scrollable_panel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'locationServices.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

String selectedType = "";
List<GooglePlace.SearchResult> custom = [];


class CustomMap extends StatefulWidget {
  final Stream<LatLng> stream;
  const CustomMap({Key? key, required this.stream}) : super(key: key);

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {

  //config declaration
  bool refreshView = false;
  bool showFloatinActionButton = true;
  bool destinationMarkerAdded = false;

  //scrollable panel declarations
  PanelController _panelController = PanelController();

  //other declarationns
  Completer<GoogleMapController> _controller = Completer();
  var googlePlace = GooglePlace.GooglePlace("AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc");
  final appBloc = new ApplicationBloc();
  var result;
  List<GooglePlace.AutocompletePrediction> acp = [];
  final searchTextField = TextEditingController();

  //user
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  List<String> favLocations = [];


  @override
  void initState() {
    super.initState();
    setState(() {
      Globals.showSpinner = true;
    });
    LocationServices.getUserAddress().then((value) {
      print("USER ADDRESS FOUND IN INIT ==================> ${value.streetAddress}");
    });
    LocationServices.polylinePoints = PolylinePoints();
    setState(() {
    });
    LocationServices.processNearbyPlaces().then((value) {
      Globals.nearbySearchResult = value;
      setState(() {
        Globals.showSpinner = false;
      });
    });

    widget.stream.listen((latlng) {
      navigate(latlng);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
          child: Scaffold(
              body: Container(
                width: size.width,
                child: Globals.showSpinner ? Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.lightGreen.shade200,
                  child: Center(
                    child: Wrap(
                      direction: Axis.vertical,
                      alignment: WrapAlignment.center,
                      children: [
                        Center(child: CircularProgressIndicator(color: MyColors.xLightTeal,)),
                        SizedBox(height: size.height * 0.1,),
                      ],
                    ),
                  ),
                ):
                Stack(
                  children: [
                    LocationServices.currentLatLng == new LatLng(109, 109) ?
                    Center(child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.lightGreen.shade200,
                      child: Center(
                        child: Wrap(
                          direction: Axis.vertical,
                          alignment: WrapAlignment.center,
                          children: [
                            Center(child: CircularProgressIndicator(color: MyColors.xLightTeal,)),
                            SizedBox(height: size.height * 0.1,),
                          ],
                        ),
                      ),
                    )
                    ) :
                    Container(
                      child: GoogleMap(
                        markers: LocationServices.markers.length <= 2 ? Set<Marker>.from(LocationServices.markers) : Set<Marker>.from(LocationServices.multipleMarkers),
                        polylines: LocationServices.getPolylines(),
                        trafficEnabled: false,
                        rotateGesturesEnabled: true,
                        buildingsEnabled: true,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(target: LocationServices.currentLatLng, zoom: 15),
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          LocationServices.setPolylines();
                        },
                      ),
                    ),
                    //KM & MILES
                    Globals.distance > 0 ?
                    Container(
                      width: size.width,
                      margin: EdgeInsets.symmetric(vertical: size.height * 0.03, horizontal: (size.width * 0.05)),
                      child: Row(
                        children: [
                          GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: MyColors.darkTeal,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                child: Row(
                                  children: [
                                    Icon(Icons.speed_rounded, color: MyColors.xLightTeal, size: 18,),
                                    Text(" ${getDistance()} ${Globals.measureSystem == "Miles" ? "MI": "KM"}", style: TextStyle(color: MyColors.xLightTeal, fontSize: 12, fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                          ),
                        ],
                      ),
                    ): Container(),
                    Container(
                      width: size.width * 1,
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04, vertical: size.height * 0.01),
                      margin: EdgeInsets.symmetric(
                          vertical: size.height * 0.07, horizontal: size.width * 0.04),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: Icon(Icons.my_location_rounded, size: 30,),
                          ),
                          Container(
                            width: size.width * 0.65,
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(
                                    color: MyColors.darkTeal))
                            ),
                            child: TextField(
                                controller: searchTextField,
                                decoration: InputDecoration(
                                    hintText: "Search for destination",
                                    hintStyle: TextStyle(
                                        color: Colors.grey),
                                    border: InputBorder.none
                                ),
                                onChanged: (value) async {
                                  LocationServices.polylines = Set<Polyline>();
                                  LocationServices.polineCoordinates = [];
                                  LocationServices.polylinePoints = new PolylinePoints();
                                  result = await googlePlace.autocomplete.get(value, radius: 0);
                                  setState(() {
                                    appBloc.searchPlace(value);
                                    acp = result.predictions.toList();
                                  });
                                }
                            ),
                          ),
                          Icon(AntDesign.search1)
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(size.width * 0.05, size.height * 0.155, 0, 0),
                      width: size.width * 0.9,
                      height: 30,
                      child: ListView(
                            children: [
                              //RESTAURANT
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.restaurant_rounded, color: Colors.deepOrange, size: 18,), Text(" Restaurants", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Restaurant"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Finance
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.attach_money_rounded, color: Colors.deepOrange, size: 18,), Text("Finance", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Finance"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Health
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.local_hospital_rounded, color: Colors.deepOrange, size: 18,), Text(" Health", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Health"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Landmark
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.landscape_rounded, color: Colors.deepOrange, size: 18,), Text(" Landmark", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Landmark"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Nature
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.nature_people, color: Colors.deepOrange, size: 18,), Text(" Nature", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Nature"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Holy Places
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.wb_shade, color: Colors.deepOrange, size: 18,), Text(" Holy Places", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Holy Places"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Interests
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.fireplace_rounded, color: Colors.deepOrange, size: 18,), Text(" Interests", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Interests"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Political
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.local_police_rounded, color: Colors.deepOrange, size: 18,), Text(" Political", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Political"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Bar
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.sports_bar_rounded, color: Colors.deepOrange, size: 18,), Text(" Bar", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Bar"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Park
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.park, color: Colors.deepOrange, size: 18,), Text(" Park", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Park"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                              SizedBox(width: 5,),
                              //Cafe
                              GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade900,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      color: Colors.yellow.shade200,
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                                    child: Row(
                                      children: [
                                        Icon(Icons.local_cafe_rounded, color: Colors.deepOrange, size: 18,), Text(" Cafe", style: TextStyle(color: Colors.deepOrange, fontSize: 12, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    _panelController.open();
                                    Globals.placeTypes.forEach((key, value) {
                                      if (key == "Cafe"){
                                        print("VALUE OF SELECTED PLACE IS $value");
                                        selectedType = value;
                                      }
                                    });
                                    //LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                                    //getPhoto();
                                  }
                              ),
                            ],
                            scrollDirection: Axis.horizontal,
                      ),
                    ),
                    Column(
                      children: [
                        Container(height: size.height * 0.08,),
                        acp.isEmpty || acp.length == 0
                            ? Container()
                            : Container(
                          margin: EdgeInsets.fromLTRB(0, size.height * 0.04, 0, 0),
                          height: size.height * 0.355,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      LocationServices.polylines = Set<Polyline>();
                                      LocationServices.polineCoordinates = [];
                                      LocationServices.polylinePoints = new PolylinePoints();
                                      //LocationServices.resetMap();
                                      GooglePlace.DetailsResponse? endResult = await googlePlace
                                          .details.get(acp[index].placeId!);
                                      GooglePlace.DetailsResponse? startResult = await googlePlace
                                          .details.get(acp[index].placeId!);
                                      LatLng targetLatLng = LocationServices.destinationLatLng = new LatLng(
                                          endResult!.result!.geometry!.location!.lat!,
                                          endResult.result!.geometry!.location!.lng!);
                                      final GoogleMapController controller = await _controller.future;
                                      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LocationServices.destinationLatLng, zoom: 15)
                                      )
                                      );
                                      _panelController.close();
                                      LocationServices.destinationLatLng = targetLatLng;
                                      setState(() {
                                        Globals.showSpinner = true;
                                      });

                                      await LocationServices.addMarkers(LocationServices.currentLatLng, LocationServices.destinationLatLng).then((value) {
                                        setState(() {
                                          searchTextField.text = "";
                                          acp = [];
                                          setState(() {
                                            Globals.showSpinner = false;
                                          });
                                        });
                                      });
                                      await LocationServices.setPolylines().then((value) {
                                        setState(() {
                                          searchTextField.text = "";
                                          acp = [];
                                          showFloatinActionButton = true;
                                          Globals.showSpinner = false;
                                        });
                                      });
                                    },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_on),
                                                Container(
                                                    width: size.width * 0.7,
                                                    child: Text("  " + acp[index].description!,)
                                                )
                                              ]
                                              ,),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 20),
                                            margin: EdgeInsets.symmetric(
                                                vertical: 2,
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius
                                                    .circular(20)
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }, itemCount: acp.length),
                        ),
                      ],
                    ),
                    ScrollablePanel(
                      controller: _panelController,
                      defaultPanelState: PanelState.close,
                      onOpen: () => {
                        setState(() {
                          showFloatinActionButton = false;
                        })
                      },
                      onClose: () => {
                        setState(() {
                          showFloatinActionButton = true;
                        })
                      },
                      onExpand: () => print("Panel has been expanded"),
                      builder: (context, controller) {
                        return SingleChildScrollView(
                          controller: controller,
                          child: _PanelView(nearbySearchResult: LocationServices.getNearbySearchResult()),
                        );
                      },
                    )
                  ],
                ),
              ),
              floatingActionButton: showFloatinActionButton ? CustomFloatingActionButton(
                currentLatLng: LocationServices.currentLatLng,
                destinationLatLng: LocationServices.destinationLatLng,
                currentPositionFAB: _currentPositionFAB,
                context: context,
                polylineCoordinates: LocationServices.polineCoordinates,
                resetMap: LocationServices.resetMap,
                resetView: refreshViewF,
              ) : FloatingActionButton(onPressed: () => print(""), foregroundColor: MyColors.darkTeal, backgroundColor: MyColors.darkTeal,)
          ),
        ),
      );
  }

  Future<void> _currentPositionFAB() async {
    print("ANIMATING TO CURRENT LOCATION ===========================> " + LocationServices.currentLatLng.toString());
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LocationServices.currentLatLng, zoom: 15)));
  }

  Future<Map<String, Uint8List>> getPhoto() async {
    Map<String, Uint8List> data = new Map<String, Uint8List>();

    LocationServices.getNearbySearchResult().forEach((i1) {
      i1.photos!.forEach((i2) async {
        http.Response result = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=&key=AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc"));
        if (result != null && mounted) {
          print(result.body);
          //data.putIfAbsent('${i1.placeId}', () => result);
        }
      });
    });

    return data;
  }

  refreshViewF(){
    setState(() {
      refreshView = !refreshView;
      _currentPositionFAB();
    });
  }

  String getDistance(){
    double totalDistance = 0.0;

    for (int i = 0; i < LocationServices.polineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        LocationServices.polineCoordinates[i].latitude,
        LocationServices.polineCoordinates[i].longitude,
        LocationServices.polineCoordinates[i + 1].latitude,
        LocationServices.polineCoordinates[i + 1].longitude,
      );
    }

// Storing the calculated total distance of the route
    setState(() {
      totalDistance = totalDistance;
      print('DISTANCE: ${totalDistance} km');
    });

    if (Globals.measureSystem == "Miles"){
      totalDistance = totalDistance * 0.621371;
    }
    return totalDistance.toStringAsFixed(2);

  //   return Geolocator.distanceBetween(
  //       LocationServices.currentLatLng.latitude,
  //       LocationServices.currentLatLng.longitude,
  //       LocationServices.destinationLatLng.latitude,
  //       LocationServices.destinationLatLng.longitude);
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void navigate(LatLng targetLatLng) async {
    bool val = true;
    Globals.distance = 0;
    LocationServices.resetMap();
    setState(() {
      _panelController.close();
      Globals.showSpinner = true;
      LocationServices.destinationLatLng = targetLatLng;
    });

    await LocationServices.addMarkers(LocationServices.currentLatLng, targetLatLng).then((value) {
      setState(() {
        searchTextField.text = "";
        acp = [];
      });
    });

    await LocationServices.setPolylines().then((value) {
      setState(() {
        Globals.enRoute = true;
        val = !val;
        searchTextField.text = "";
        acp = [];
        showFloatinActionButton = true;
        Globals.showSpinner = false;
      });
    }).then((value) {
      Globals.distance = double.parse(getDistance());
    });
  }
}

Widget showNearbyData(List<GooglePlace.SearchResult> nearbySearchResult, BuildContext context) {
  custom = [];
  bool proceed = true;
  nearbySearchResult.forEach((element) {
    if (element.types?.contains(selectedType) == true){
      print("FOUND PLACE =========+> ${custom.length}");
      custom.add(element);
    }
  });

  custom.forEach((element) {
    if (element.photos?.length == 0 || element.photos == null){
      proceed = false;
    }
    if (element.rating == null){
      proceed = false;
    }
  });

  print("PROCEED IS <<<<<<<<<<======================================>>>>>>>>> $proceed");

  return custom.length == 0 ?
  Container(padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50), width: MediaQuery.of(context).size.width, child: Text("No Places Found Nearby", textAlign: TextAlign.center, style: TextStyle(color: MyColors.xLightTeal),),
  ): proceed ? Container(
      child: CarouselSlider(
        options: CarouselOptions(height: 170),
        items: custom.map((i) {
          print("I AM PASSING THIS TO THE DISPLAY ${i.name} ${i.rating} ${i.types} ${i.placeId} ${i.geometry?.location?.lat} ${i.geometry?.location?.lng}");
          return Builder(
            builder: (BuildContext context) {
            //if (i.types?.contains(userPref) == true){
            return Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 30),
              child: _boxes(
                  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=195&photoreference=${i.photos?.first.photoReference}&key=AIzaSyBCixLmt9EfFn3t1hiFLfKYoCcdv18NjNc",
                  i.name!,
                  i.rating!,
                  i.geometry?.location?.lat,
                  i.geometry?.location?.lng,
                  i.types,
                  i.placeId,
                context
                )
              );
             }
              // else {
            //   return Container();
            // }
             // }
              );
          }
        ).toList(),
      )
  ):
  Container(padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50), width: MediaQuery.of(context).size.width, child: Text("No Places Found Nearby", textAlign: TextAlign.center, style: TextStyle(color: MyColors.xLightTeal),));
}

Widget _boxes(String _image, String placeName, double rating, double? lat, double? lng, List<String>? types, String? placeId, BuildContext context) {
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
                  width: 300,
                  height: 250,
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(24.0),
                    child: Image(
                      fit: BoxFit.fill,
                      image: NetworkImage(_image),
                    ),
                  ),),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: myDetailsContainer1(placeName, rating, types, lat, lng, placeId, context),
                  ),
                ),

              ],)
        ),
      ),
    ),
  );
}

Widget myDetailsContainer1(String placeName, double rating, List<String>? types, double? lat, double? lng, String? placeId, BuildContext context) {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  List<String> fav = ["$placeId"];

  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Row(
        children: [
          GestureDetector(
            child: Icon(Icons.favorite_border_rounded, size: 70, color: MyColors.darkTeal,),
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
                  usersRef.doc(auth.currentUser?.uid).update({'favLocations': FieldValue.arrayUnion(fav)});
                }
              });
              showTopSnackBar(
                context,
                CustomSnackBar.success(
                  message:
                  "Place Saved",
                  backgroundColor: MyColors.xLightTeal,
                  textStyle: TextStyle(color: MyColors.darkTeal, fontWeight: FontWeight.bold),
                )
              );
            },
          ),
          GestureDetector(
            child: Container(
                child: Icon(Icons.navigation_outlined, size: 70, color: MyColors.darkTeal,)
            ),
            onTap: () async {
              Globals.cusMapStreamController.add(LatLng(lat!, lng!));
            },
          ),
        ],
      ),
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
                    "(946)",
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

class _PanelView extends StatefulWidget {
  final List<GooglePlace.SearchResult> nearbySearchResult;
  const _PanelView({Key? key, required this.nearbySearchResult}) : super(key: key);

  @override
  _PanelViewState createState() => _PanelViewState(nearbySearchResult: nearbySearchResult);
}

class _PanelViewState extends State<_PanelView> {
  List<GooglePlace.SearchResult> nearbySearchResult;
  _PanelViewState({required this.nearbySearchResult});

  @override
  Widget build(BuildContext context) {
    const double circularBoxHeight = 18.0;
    final Size size = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: size.height + kToolbarHeight + 44.0,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 720),
            decoration: BoxDecoration(
              color: MyColors.darkTeal,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(circularBoxHeight), topRight: Radius.circular(circularBoxHeight)),
              border: Border.all(color: MyColors.xLightTeal),
            ),
            child: showNearbyData(nearbySearchResult, context),
          ),
        );
      },
    );
  }
}
