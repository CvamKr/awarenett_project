import 'package:awarenett/pages/add_events_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class MyPasscodeDialog{
 String enteredPassword = '';
  String enteredInstaId = '';
  Future<bool> showClubCodeDialog(BuildContext context, _scaffoldKey) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return new AlertDialog(
          // title: Text('Enter The PassCode'),
          content: ListView(
            children: <Widget>[
              TextField(
                onChanged: (enteredPassword) {
                  this.enteredPassword = enteredPassword;

                  // this.smsOtp = enteredCode;
                },
                decoration: InputDecoration(hintText: 'Enter Passcode'),
              ),
              // enteredPassword == 'clubsrock'
              //     ? Text('Entered password is incorrect. ')
              //     : Container(),
              //  Text("Yay, verified. Let's add an event"),
              SizedBox(
                height: 10.0,
              ),
              Text(
                  'To prevent unwanted posts, clubs and organisers are required to enter The PassCode. '),
              SizedBox(
                height: 20.0,
              ),
              ExpansionTile(
                title: Text('How to get The PassCode:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: <Widget>[
                  Text(
                      "Enter your club's/organisation's  official instagram handle."),
                  TextField(
                    onChanged: (enteredInstaId) {
                      this.enteredInstaId = enteredInstaId;
                    },
                    decoration: InputDecoration(hintText: "Enter Instagram handle"),
                  ),
                  FlatButton(
                    color: Colors.blue,
                    child: Text(
                      'Send',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async{
                    await  sendInstaId();
                    Navigator.pop(context);

                    final snackBar = SnackBar(content: Text("Sent Successfully!\n\nSee you at Instagram dm soon."));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
      _scaffoldKey.currentState.showSnackBar(snackBar);
//Scaffold.of(context).showSnackBar(snackBar);
                    
                    },
                  ),
                  Text(
                      "• Our Verification Team will verify it soon."
                    "\n• From our instagram handle @yozznet.official, we'll dm you the passcode.",
                      style: TextStyle(fontWeight: FontWeight.normal)),

                      SizedBox(height: 20.0,),

                       RichText(
                  text: TextSpan(
                    text: "• Follow our Instagram handle ",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      // fontWeight: FontWeight.bold
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "@yozznet.official ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "for more updates.",
                        style: TextStyle(
                          color: Colors.black,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                        Text(
                      "\nPs. We are working on a better way. For any suggestions, queries, feedback, feel free to use our 'drop a suggestion!' box or dm us on Instagram:)",
                      style: TextStyle(fontWeight: FontWeight.normal)),

                      SizedBox(height: 10.0,),
                ],
              ),

              // Text(),
            ],
          ),
          contentPadding: EdgeInsets.all(8.0),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Verify Passcode'),
              onPressed: () {
                if (enteredPassword == '') {
                  Fluttertoast.showToast(
                      msg: "Forgot to write passcode? Someone's a fan of Ghajini ;)",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else if (enteredPassword == 'myclubrocks') {
                  Fluttertoast.showToast(
                      msg: "Yay, verified. Let's add an event",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);


                  Future.delayed(Duration(seconds: 1)).then((onValue) {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyAddEventPage()),
                    );
                  }).catchError((onError) {
                    print(onError.toString());
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: "Oops, wrong Passcode.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            )
          ],
        );
      },
    );
  }
   sendInstaId() async {
    return await Firestore.instance
        .collection('userInteraction')
        .add({
      'receivedInstaId': this.enteredInstaId,
      'serverTimeStamp' : FieldValue.serverTimestamp(),
        })
        .then((_) {})
        .catchError((e) {
          print(e.toString());
        });
  }
}