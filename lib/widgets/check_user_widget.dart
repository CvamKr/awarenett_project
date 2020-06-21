
import 'package:awarenett/pages/event_page.dart';
import 'package:awarenett/widgets/awarenett_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../phone_login_page.dart';



class CheckUserWidget extends StatefulWidget {
  @override
  _CheckUserWidgetState createState() => _CheckUserWidgetState();
}

class _CheckUserWidgetState extends State<CheckUserWidget> {
  dynamic relevantPage = MyYozznetLogo();
  var user;
  bool userProfileExists = false;

  @override
  void initState() {
    // : implement initState

    super.initState();

    // checkProfile();
  }

  

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((user) {
      if (user == null) {
        // debugPrint('1. inside if(user == null)');
        // debugPrint('1. user null and user is $user ');
        setState(() {
          this.relevantPage =
//                 MyWelcomePage();;
          MyPhoneLoginPage();
        });

        return relevantPage;
      } else {


        setState(() {
          this.relevantPage =
              MyEventsPage();
//              MyHomePage();
          //  ChooseInstitutionDdPage(user);
        });

        return relevantPage;
      }
    }).catchError((e) {
      debugPrint(e.toString());
    });

    return relevantPage;


  }


}
