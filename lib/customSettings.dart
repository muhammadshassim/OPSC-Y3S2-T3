import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_sa/MyColors.dart';
import 'package:explore_sa/globals.dart';
import 'package:explore_sa/services/authService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:scrollable_panel/scrollable_panel.dart';
import 'package:provider/provider.dart';
import 'locationServices.dart';

//----------------------------------_> Figure out how to add user data when signing up
class CustomSettings extends StatefulWidget {
  const CustomSettings({Key? key}) : super(key: key);

  @override
  _CustomSettingsState createState() => _CustomSettingsState();
}

class _CustomSettingsState extends State<CustomSettings> {

  Map<String, String> placeTypes = {
    "Finance": "finance",
    "Restaurant": "food",
    "Health": "health",
    "Landmark": "landmark",
    "Nature": "natural_feature",
    "Holy Places": "place_of_worship",
    "Interests": "point_of_interest",
    "Political": "political",
  };

  //scrollable panel declarations
  PanelController _panelController = PanelController();

  late PanelView panelView;
  late Widget rootPage;

  TextEditingController nameTextField = TextEditingController();
  TextEditingController prefTextField = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    setState(() {
      Globals.showSpinner = true;
    });
    extractUserName().then((value) {
      Globals.usersName = value;
    });
    extractUserPref().then((value) {
      Globals.usersPrefValue = value;
    });
    extractUserMetric().then((value) {
      Globals.measureSystem = value;
    });
    LocationServices.getCurrentLatLng().then((value) => {
      print("WE FOUND LOCATION ON LOGIN ==================> ${value.latitude}/${value.longitude}"),
      setState(() {Globals.showSpinner = false;})
    });
  }

  @override
  Widget build(BuildContext context) {
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;
      return Container(
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
            Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: Colors.lightGreen.shade200,
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 50),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                AntDesign.arrowleft,
                                color: MyColors.darkTeal,
                              ),
                              GestureDetector(
                                child: Icon(
                                  AntDesign.logout,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  context.read<AuthService>().signOut();
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontFamily: 'Nisebuschgardens',
                            ),
                          ),
                          SizedBox(
                            height: 22,
                          ),

                          Container(
                            height: height * 0.40,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double innerHeight = constraints.maxHeight;
                                double innerWidth = constraints.maxWidth;
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Positioned(
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(
                                            0, height * 0.08, 0, 0),
                                        height: innerHeight * 0.50,
                                        width: innerWidth,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          color: MyColors.xLightTeal,
                                        ),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 45,
                                            ),
                                            Flexible(
                                              child: Text(
                                                '${Globals.usersName}',
                                                style: TextStyle(
                                                    color: MyColors.darkTeal,
                                                    fontFamily: 'Nunito',
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: width * 0.8,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.04,
                                                  vertical: height * 0.01),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: height * 0.07,
                                                  horizontal: width * 0.01),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(
                                                      20)
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Icon(Icons
                                                      .drive_file_rename_outline),
                                                  Container(
                                                    width: width * 0.55,
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                color: MyColors
                                                                    .darkTeal))
                                                    ),
                                                    child: TextField(
                                                      controller: nameTextField,
                                                      decoration: InputDecoration(
                                                          hintText: '${Globals
                                                              .usersName}',
                                                          hintStyle: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey),
                                                          border: InputBorder.none
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: Icon(
                                                        Icons.done_outline_rounded),
                                                    onTap: () {
                                                      usersRef.doc(
                                                          getCurrentUserUID()).update(
                                                          {
                                                            'displayName': nameTextField
                                                                .text,
                                                            'uid': getCurrentUserUID()
                                                          }
                                                      ).catchError((onError) =>
                                                          print(onError));

                                                      setState(() {
                                                        changeDisplayName();
                                                        extractUserName();
                                                        nameTextField.clear();
                                                      });
                                                      //printData();

                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          child: Image.asset(
                                            'assets/images/user.png',
                                            width: innerWidth * 0.30,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: height * 0.3,
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: MyColors.xLightTeal,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.settings),
                                        Text(
                                          ' Preferences',
                                          style: TextStyle(
                                            color: MyColors.darkTeal,
                                            fontSize: 20,
                                            fontFamily: 'Nunito',
                                          ),
                                        ),
                                      ]
                                  ),
                                  Divider(
                                    thickness: 2.5,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 20),
                                        child: Row(
                                          children: [
                                            Icon(Icons.add_location_alt_rounded),
                                            Container(
                                              width: width * 0.62,
                                              child: Container(
                                                child: Text("${Globals.usersPrefKey}",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: MyColors.darkTeal),),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10, horizontal: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        child: Icon(Icons.edit_outlined),
                                        onTap: () {
                                          _panelController.open();
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            Icon(Icons.speed_rounded),
                                            Container(
                                              width: width * 0.62,
                                              child: Container(
                                                child: Text(
                                                  "${Globals.measureSystem}",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: MyColors.darkTeal),),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5, horizontal: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        child: Icon(Icons.compare_arrows_rounded),
                                        onTap: () async {
                                          extractUserMetric();
                                          if (Globals.measureSystem == "Kilometers") {
                                            await usersRef.doc(getCurrentUserUID())
                                                .update({'measureSystem': "Miles"})
                                                .catchError((onError) =>
                                                print(onError));
                                          } else {
                                            await usersRef.doc(getCurrentUserUID())
                                                .update(
                                                {'measureSystem': "Kilometers"})
                                                .catchError((onError) =>
                                                print(onError));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                ScrollablePanel(
                  controller: _panelController,
                  defaultPanelState: PanelState.close,
                  onExpand: () {
                    _panelController.open();
                  },
                  builder: (context, controller) {
                    return SingleChildScrollView(
                      controller: controller,
                      child: PanelView(placesTypes: placeTypes,
                        panelController: _panelController,
                        changeUserPref: changeDisplayPref,
                        extractUserPref: extractUserPref,),
                    );
                  },
                )
              ],
            ),
          );
  }

  String getCurrentUserUID() {
    final User? user = auth.currentUser;
    return user!.uid;
  }


  void changeDisplayName() async {
    Globals.showSpinner = true;
    if (Globals.showSpinner) CircularProgressIndicator();
    await usersRef.doc(getCurrentUserUID()).get().then((value) {
      setState(() {
        Globals.usersName = value['displayName'];
        Globals.showSpinner = false;
      });
    });
  }

  Future<String> extractUserName() async {
    var result;
    await usersRef.doc(getCurrentUserUID()).get().then((value) {
      result = value.data();
      return value.data();
    });
    setState(() {
      Globals.usersName = result['displayName'];
    });
    print("EXTRACTED USER NAME ================> ${result['displayName']}");
    return result['displayName'];
  }

  void changeDisplayMetric() async {
    Globals.showSpinner = true;
    if (Globals.showSpinner) CircularProgressIndicator();
    await usersRef.doc(getCurrentUserUID()).get().then((value) {
      setState(() {
        Globals.measureSystem = value['measureSystem'];
        Globals.showSpinner = false;
      });
    });
  }

  Future<String> extractUserMetric() async {
    var result;
    await usersRef.doc(getCurrentUserUID()).get().then((value) {
      result = value.data();
      return value.data();
    });
    setState(() {
      Globals.measureSystem = result['measureSystem'];
    });
    print("EXTRACTED USER SYSTEM ================> ${result['measureSystem']}");
    return result['measureSystem'];
  }

  void changeDisplayPref() async {
    Globals.showSpinner = true;
    if (Globals.showSpinner) CircularProgressIndicator();
    await usersRef.doc(getCurrentUserUID()).get().then((res) {
      Globals.placeTypes.forEach((key, value) {
        String extractedPref = res['locationPref'];
        if (value == extractedPref){
          print("===========================================================================");
          setState(() {
            Globals.usersPrefValue = value;
            Globals.usersPrefKey = key;
            Globals.showSpinner = false;
          });
        }
      });
      // setState(() {
      //   Globals.usersPrefValue = res['locationPref'];
      //   Globals.showSpinner = false;
      // });
    });
  }

  Future<String> extractUserPref() async {
    var result;
    await usersRef.doc(getCurrentUserUID()).get().then((value) {
      result = value.data();
      return value.data();
    });

    setState(() {
      Globals.placeTypes.forEach((key, value) {
        String extractedPref = result['locationPref'];
        if (value == extractedPref){
          setState(() {
            Globals.usersPrefValue = value;
            Globals.usersPrefKey = key;
            //Globals.showSpinner = false;
          });
        }
      });
    });
    print("EXTRACTED USER PREF ================> ${result['locationPref']}");
    return result['locationPref'];
  }

  Future<bool> prepareUserDetails() async {
    if (Globals.usersName == "non") {
      await usersRef.doc(getCurrentUserUID()).set(
          {
            'displayName': "Name",
            'uid': getCurrentUserUID(),
            'locationPref': 'All',
            'measureSystem': 'Kilometers'
          }
      ).catchError((onError) {
        print(onError);
      });
    }
    return true;
  }
}

class PanelView extends StatefulWidget {
  final Map<String, String> placesTypes;
  final PanelController panelController;
  final Function changeUserPref;
  final Function extractUserPref;
  const PanelView({Key? key, required this.placesTypes, required this.panelController, required this.changeUserPref, required this.extractUserPref}) : super(key: key);

  @override
  _PanelViewState createState() => _PanelViewState(placesTypes: placesTypes, panelController: panelController, changeUserPref: changeUserPref, extractUserPref: extractUserPref);
}

class _PanelViewState extends State<PanelView> {
  final Map<String, String> placesTypes;
  PanelController panelController;
  final Function changeUserPref;
  final Function extractUserPref;
  _PanelViewState({required this.placesTypes, required this.panelController, required this.changeUserPref, required this.extractUserPref});

  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  String getCurrentUserUID(){
    final User? user = auth.currentUser;
    return user!.uid;
  }

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
            child: Container(
                child: Globals.showSpinner ? CircularProgressIndicator():
                CarouselSlider(
                  options: CarouselOptions(height: 50),
                  items: placesTypes.keys.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: MyColors.xLightTeal,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Expanded(flex: 1, child: Icon(Icons.add_location_alt_rounded)),
                                  Expanded(flex: 4, child: Text(i, style: TextStyle(fontWeight: FontWeight.bold),),),
                                ],
                              ),
                            ),
                            onTap: () async {
                              Globals.placeTypes.forEach((key, value) {
                                if (key == i){
                                  Globals.usersPrefValue = value;
                                  Globals.usersPrefKey = key;
                                }
                              });
                              await usersRef.doc(getCurrentUserUID()).update({'locationPref': "${Globals.usersPrefValue}"})
                                  .catchError((onError) => print(onError));
                              panelController.close();
                              await extractUserPref();
                              setState(() {
                                changeUserPref();
                              });
                            }
                        );
                      },
                    );
                  }).toList(),
                )
            ),
          ),
        );
      },
    );
  }
}

Widget showNearbyData(Map<String, String> placesTypes){

  return Container(
      child: CarouselSlider(
        options: CarouselOptions(height: 50),
        items: placesTypes.keys.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: MyColors.xLightTeal,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white,
                    ),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: Icon(Icons.add_location_alt_rounded)),
                      Expanded(flex: 4, child: Text(i, style: TextStyle(fontWeight: FontWeight.bold),),),
                    ],
                  ),
                ),
                onTap: () {
                }
              );
            },
          );
        }).toList(),
      )
  );

}