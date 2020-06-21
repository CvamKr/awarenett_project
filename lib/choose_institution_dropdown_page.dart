import 'package:awarenett/pages/event_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ChooseInstitutionDdPage extends StatefulWidget {
  final FirebaseUser user;
  ChooseInstitutionDdPage(this.user, {Key key}) : super(key: key);

  @override
  _ChooseInstitutionDdPageState createState() =>
      _ChooseInstitutionDdPageState();
}

class _ChooseInstitutionDdPageState extends State<ChooseInstitutionDdPage> {
  // var institutionName = [
  //   'Mit Manipal',
  //   'Kmc Manipal',
  //   'Soc Manipal',
  //   'Doc Manipal',
  // ];
  String currentInstitutionSelected = "Select Location";
  String userPhoneNo = '';

  @override
  void initState() {
// implement initState
    super.initState();
    currentInstitutionSelected = "Select Location";
    getUser();
  }

  Future getUser() async {
    try {
      await FirebaseAuth.instance.currentUser().then((user) {
        if (user != null) {
          setState(() {
            print('user is ${user.uid}');
            // this.user = user;
            this.userPhoneNo = user.phoneNumber;
          });
          // loadProfile Data(user);
        } else {
          print('user is $user');
        }
      }).catchError((e) {
        print(e.toString());
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //parthiv

  openInstitutionDialogBox() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Container(
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    // locationQuery
                    locationController.text == ''
                        ? Firestore.instance
                            .collection('institutesLocation')
                            .orderBy('instituteLocation', descending: false)
                            .snapshots()
                        : Firestore.instance
                            .collection('institutesLocation')
                            .where('instituteLocationSearchQuery',
                                arrayContains:
                                    locationController.text.toLowerCase())
                            // .orderBy('institutionName', descending: false)
                            .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    //  the data is not ready, show a loading indicator

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    //  do something with the error
                    return Text(snapshot.error.toString());
                  }
                  //  do something with the data

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length + 2,
                    itemBuilder: (BuildContext context, int index) {
                      var length = snapshot.data.documents.length;
                      print('in listbuilder , length = $length');
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: getCurrentLocationTemplate(length),
                        );
                      }
                      else {
                        DocumentSnapshot institutionNameDoc =
                            snapshot.data.documents[index - 1];

                        String institutionName =
                            institutionNameDoc.data['instituteLocation'];

                        return ListTile(
                          title:
                              institutionName == null || institutionName == ''
                                  ? Center(child: CircularProgressIndicator())
                                  : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(institutionName),
                                      ),
                                      Container(height: 1, color: Colors.grey)
                                    ],
                                  ),
                          onTap: () {
                            setState(() {
                              currentInstitutionSelected = institutionName;
                              this.locationQuery = '';
                              Navigator.pop(context);
                              this.locationQuery = '';
                              print('locationquery = $locationQuery');
                            });
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  String locationQuery = '';
  var length = 0;
  var locationController = TextEditingController();

  getCurrentLocationTemplate(length) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(alignment: Alignment.topLeft, child: Text('Current Location: ')),
        // SizedBox(
        //   height: 10.0,
        // ),
        Text(
          currentInstitutionSelected,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 15.0,
        ),

        TextField(
          controller: locationController,
          onChanged: (enteredLocation) {
            setState(() {
              this.locationQuery =
                  // locationController.text == '' ? ''
                  // :
                  enteredLocation;
            });
            print('locatinQuery = $locationQuery');
          },
          decoration: InputDecoration(hintText: "Search Institute Location"),
        ),
        // Container(height: 1.0, color: Colors.black),
        SizedBox(
          height: 15.0,
        ),
        Text(
          '(Type first few letters & press enter)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 5.0,
        ),

        Text(locationController.text == ''
            ? 'Total Institutes: $length'
            : 'search result: $length')
        // Text('$length result(s)'),
      ],
    );
  }

//parthiv

  // Widget getInstitutionDropDown() {
  //   return Container(
  //     // margin: EdgeInsets.all(16.0),
  //     decoration: BoxDecoration(
  //         color: Colors
  //             .white, //use here Colors.white, and in the scaffold-> backgroundColor: Colors.blueGrey[50],
  //         borderRadius: BorderRadius.circular(8),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(.12),
  //             offset: Offset(0, 10),
  //             blurRadius: 30,
  //           )
  //         ]),
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: DropdownButton<String>(
  //         value: currentInstitutionSelected,
  //         items: institutionName.map((String dropDownStringItem) {
  //           return DropdownMenuItem<String>(
  //               value: dropDownStringItem, child: Text(dropDownStringItem));
  //         }).toList(),
  //         onChanged: (String newValueSelected) {
  //           setState(() {
  //             this.currentInstitutionSelected = newValueSelected;
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    // implement dispose
    locationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[50],
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select your Institute location',
                style: TextStyle(fontSize: 20.0),
              ),
              // SizedBox(
              //   height: 10.0,
              // ),
              // getInstitutionDropDown(),
              // getInstitutionDropDown2(),
              FlatButton(
                onPressed: () {
                  openInstitutionDialogBox();
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.expand_more),
                      Container(
                        width: MediaQuery.of(context).size.width-110,
                        child: Text(
                          currentInstitutionSelected,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // IconButton(icon: Icon(Icons.keyboard_arrow_down), onPressed:(){openInstitutionDialogBox();},),

              SizedBox(
                height: 20.0,
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Note: Once selected, the Institute location can\'t be changed by you. To change you will have to contact us using our in app feedback box or dm us on Instagram @yozznet.official ',
                  style: TextStyle(color: Colors.red, fontSize: 16.0,),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 100.0,
                  child: RaisedButton(
                      color: Colors.greenAccent,
                      onPressed: () async {
                        if (currentInstitutionSelected == 'Select Location') {
                          Fluttertoast.showToast(
                            msg: "Please Select a Location",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          return;
                        }
                        await saveProfileData();
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              MyEventsPage()),
//                              MyHomePage()),
                        );
                      },
                      child: Text('Ok')),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  // Future<bool> showInstitutionConfirmationDialog(BuildContext context) {
  //   var alertDialog = AlertDialog(
  //     title: Text("Confirm Institution?"),
  //     content: Text(
  //       '[Note: Once selected, the institution can\'t be changed by you! To change you need to contact us] ',
  //       style: TextStyle(color: Colors.red),
  //     ),
  //     actions: <Widget>[
  //       FlatButton(
  //         child: Text('Confirm'),
  //         onPressed: () async {
  //           await saveProfileData();
  //           Navigator.pop(context);
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => MyHomePage(currentInstitutionSelected)),
  //           );
  //         },
  //       ),
  //       FlatButton(
  //         child: Text('Change'),
  //         onPressed: () {
  //           // showCirularBar();
  //           Navigator.pop(context);
  //         },
  //       ),
  //     ],
  //   );
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,

  //       //builder: (BuildContext context){ // builder returns a widget
  //       //return alertDialog;
  //       //}

  //       builder: (BuildContext context) => alertDialog);
  // }

  CollectionReference userProfileCollection =
      Firestore.instance.collection('userProfile');

  saveProfileData() {
    userProfileCollection.document('${widget.user.uid}').setData({
      'userInstituteLocation': currentInstitutionSelected,
      'userPhoneNo': userPhoneNo
    }).then((_) {
      print('user institution saved');
    }).catchError((e) {
      print(e.toString());
    });
  }
}