import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:explore_sa/customMap.dart';
import 'package:explore_sa/customPlaces.dart';
import 'package:explore_sa/navigation.dart';
import 'package:explore_sa/neabyPlaces.dart';
import 'package:explore_sa/services/authService.dart';
import 'package:explore_sa/userLogReg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:explore_sa/MyColors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'application_bloc.dart';
import 'customSettings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mapbox_navigation/library.dart';

import 'globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.yellow,
      primarySwatch: Colors.yellow,
    ),
    home: Main(),
  ));
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(logo: Image(image: AssetImage('assets/icons/map.png')),
        title: Text('Nova Maps', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),),
        durationInSeconds: 5,
      navigator: MultiProvider(
        providers: [
          Provider<AuthService>(create: (_) => AuthService(FirebaseAuth.instance),),
          StreamProvider(create: (context) => context.read<AuthService>().authStateChanges, initialData: null,)
        ],
        child: AuthenticationWrapper(),
      ),
    );
  }
}


class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {

  //variables
  final appBloc = new ApplicationBloc();
  late MapBoxNavigation _directions;


  int _page = 0;
  late final CustomMap mapWidget;
  late CustomPlaces places;
  CustomSettings settings = CustomSettings();
  CustomNavigation navigation = CustomNavigation();

  Widget _pagePicker(int page){
    switch (page) {
      case 0:
        return places;
        break;
      case 1:
        return mapWidget;
        break;
      case 2:
        return settings;
        break;
      default:
        return mapWidget;
        break;
    }
  }

  @override
  void initState(){
    super.initState();
    Globals.cusMapStreamController = StreamController.broadcast();
    Globals.cusPlacesStreamController = StreamController.broadcast();
    mapWidget = CustomMap(stream: Globals.cusMapStreamController.stream,);
    places = CustomPlaces(stream: Globals.cusPlacesStreamController.stream, changeViewToMap: changeViewToMap,);
    _directions = MapBoxNavigation();
  }

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int defaultPage = 1;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return Scaffold(
          bottomNavigationBar: CurvedNavigationBar(
            color: Colors.deepOrange,
            backgroundColor: Colors.deepOrange.shade100,
            buttonBackgroundColor: Colors.lightGreen,
            index: 2,
            height: 50,
            key: _bottomNavigationKey,
            items: <Widget>[
              Icon(Icons.location_on, size: 40, color: Colors.deepOrange.shade100,),
              Icon(Icons.map_rounded, size: 40, color: Colors.deepOrange.shade100,),
              Icon(Icons.house_rounded, size: 40, color: Colors.deepOrange.shade100,),
            ],
            onTap: (int tappedIndex) => changeView(tappedIndex),
          ),
          body: Center(
              child: Stack(
                children: [
                  Globals.showPage,
                ],
              )
          ));
    } else {
      return Scaffold(
        body: LoginScreen(),
      );
    }
  }

  changeView(int tappedIndex){
    setState(() {
      Globals.showPage = _pagePicker(tappedIndex);
    });
  }

  changeViewToMap(){
    setState(() {
      Globals.showPage = _pagePicker(1);
    });
  }

  navigate() async {
    MapBoxOptions _options = MapBoxOptions(
        initialLatitude: 36.1175275,
        initialLongitude: -115.1839524,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        mapStyleUrlDay: "https://url_to_day_style",
        mapStyleUrlNight: "https://url_to_night_style",
        units: VoiceUnits.imperial,
        simulateRoute: true,
        language: "en");

    final origin = WayPoint(name: "Durban", latitude: -29.858681, longitude: 31.021839);
    final stop = WayPoint(name: "Ballito", latitude: -29.547177, longitude: 31.178887);

    List<WayPoint> wayPoints = [];
    wayPoints.add(origin);
    wayPoints.add(stop);

    await _directions.startNavigation(wayPoints: wayPoints, options: _options);
  }
}
