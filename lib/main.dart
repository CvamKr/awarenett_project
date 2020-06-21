import 'package:awarenett/widgets/check_user_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String passedInstitutionName = 'Mit Manipal';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    print('in main.dart');

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: ThemeData(
          //applies to whole app
          brightness: Brightness
              .light, //changes color of the entire app to black and text colors to white
          primaryColor: Colors
              .black, //changes the color of the appbar, applies dark of primaryColor to top of app //bar
          //primaryColor: Color(0xff075E54),
          accentColor: Colors
              .indigoAccent //color of the arc that is made when top/bottom of the list is pulled //down/up
          ),
      home:
          CheckUserWidget()
           );
  }
}
