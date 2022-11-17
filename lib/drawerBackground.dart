import 'package:explore_sa/MyColors.dart';
import 'package:explore_sa/customMap.dart';
import 'package:explore_sa/customPlaces.dart';
import 'package:explore_sa/customSettings.dart';
import 'package:flutter/material.dart';

import 'globals.dart';


class DrawerBackground extends StatefulWidget {
  const DrawerBackground({Key? key}) : super(key: key);

  @override
  _DrawerBackgroundState createState() => _DrawerBackgroundState();
}

class _DrawerBackgroundState extends State<DrawerBackground> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: MyColors.xLightTeal,
        width: width,
        height: height,
        child: Container(
          margin: EdgeInsets.fromLTRB(width*0.03, height*0.05, 0, height*0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  child: Text("DRAWER", style: TextStyle(fontSize: 24),),
                width: width * 0.4,
                color: Colors.red,
              ),
              GestureDetector(
                child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        Text("Account", style: TextStyle(fontSize: 24),),
                      ],
                    ),
                  width: width * 0.4,
                  color: Colors.green,
                ),
                onTap: () {
                  //Globals.drawerController.close!();
                  //Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CustomSettings()));
                },
              ),
              GestureDetector(
                child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.map),
                        Text("Map", style: TextStyle(fontSize: 24),),
                      ],
                    ),
                  width: width * 0.4,
                  color: Colors.yellow,
                ),
                onTap: () {
                  //Globals.drawerController.close!();
                  //Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CustomMap(stream: Globals.cusMapStreamController.stream),),);
                },
              ),
              GestureDetector(
                child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.favorite_rounded),
                        Text("Favourites", style: TextStyle(fontSize: 24),),
                      ],
                    ),
                  width: width * 0.4,
                  color: Colors.purple,
                ),
                onTap: () {
                  //Globals.drawerController.close!();
                  //Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CustomSettings(),),);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
