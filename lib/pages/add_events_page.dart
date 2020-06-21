import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyAddEventPage extends StatefulWidget {
  MyAddEventPage({Key key}) : super(key: key);

  @override
  _MyAddEventPageState createState() => _MyAddEventPageState();
}

class _MyAddEventPageState extends State<MyAddEventPage> {
//image picker

  File _imageFile;
  File compressedImage;

  TextEditingController eventLinkController = TextEditingController();

  var phoneController = TextEditingController();

  Future pickImage(ImageSource imageSource) async {

    var image = await ImagePicker.pickImage(
      source: imageSource,
       imageQuality: 20,
    );

    setState(() {
       _imageFile = image;

      print('image before compress: ${image?.lengthSync()}');

      print('compressedimagesize: ${_imageFile?.lengthSync()}');

      print(_imageFile?.lengthSync());
    });
  }
//image picker ends



  var _formKey = GlobalKey<FormState>();
  TextEditingController eventNameController = TextEditingController();

  TextEditingController eventDescriptionController = TextEditingController();

  TextEditingController eventVenueController = TextEditingController();
  TextEditingController eventDateAndTimeController = TextEditingController();

  TextEditingController clubOrganiserNameController = TextEditingController();

  @override
  void dispose() {
    // implement dispose
    eventNameController?.dispose();
    eventDescriptionController?.dispose();
    eventVenueController?.dispose();
    eventDateAndTimeController?.dispose();
    clubOrganiserNameController?.dispose();
    phoneController?.dispose();
    profileColSubscription?.cancel();

    super.dispose();
  }


  String eventTypeSelected = "";
  //drop down ends

  String userName = '';
  String userPhoneNo = '';
  String clubOrganiserContactNo = '';

  String clubOrganiserName = '';
  String fetchedclubOrganiserName = '';
  String userInstituteLocation = '';
  String eventLink = '';

  FirebaseUser user;

  CollectionReference userProfileCollection =
      Firestore.instance.collection('userProfile');

  StreamSubscription<DocumentSnapshot> profileColSubscription;

  loadProfileData(FirebaseUser user) async {
    profileColSubscription = userProfileCollection
        .document('${user.uid}')
        .snapshots()
        .listen((profileDataSnap) {
      if (profileDataSnap.exists) {
        print('profile data exists');
        setState(() {
          this.userName = profileDataSnap.data['userName'];

          clubOrganiserNameController.text = this.clubOrganiserName =
              profileDataSnap.data['club_organiserName'] == null
                  ? ''
                  : profileDataSnap['club_organiserName'];
          this.fetchedclubOrganiserName = clubOrganiserName;
          this.userInstituteLocation =
              profileDataSnap.data['userInstituteLocation'];
          phoneController.text =
              this.userPhoneNo = profileDataSnap.data['userPhoneNo'];
          this.clubOrganiserContactNo = this.userPhoneNo;
          // nameController.text = this.name;
        });
      } else {
        print('profile data does not exist');
      }
    });
  }

  void updateProfileData() {
    userProfileCollection.document('${user.uid}').updateData(
        {'club_organiserName': clubOrganiserNameController.text}).then((_) {
      print('profile data saved');
      final snackBar = SnackBar(content: Text('Your data has been saved.'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }).catchError((e) {
      print(e.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    eventTypeSelected = '';

    //get user
    try {
      FirebaseAuth.instance.currentUser().then((user) {
        if (user != null) {
          setState(() {
            print('user is ${user.uid}');
            this.user = user;
            this.userPhoneNo = user.phoneNumber;
          });
          loadProfileData(user);
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

  Widget _addPhoto() {
    return Center(
      child: _imageFile == null
          ? Container(
              height: 200.0,
              child:
                  Center(child: Text('No image selected.\n       (Optional)')))
          :
          // height: 400.0,
          // width: MediaQuery.of(context).size.width,
          Container(
              height: 400.0,
              child: Image.file(
                _imageFile,
                fit: BoxFit.contain,
              ),
            ),
    );
  }

  Widget _textFormFieldTemplate(
      String labelText, String hintText, TextEditingController controller) {
    return Container(
      child: TextFormField(
          validator: (String value) {
            if (controller != eventDescriptionController) {
              if (value.isEmpty) {
                return 'Required';
              } else
                return null;
            } else
              return null;
          
          },
          controller: controller,

          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
        
            errorStyle: TextStyle(color: Colors.red, fontSize: 14.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
          )),
    );
  }


  void postEvent(String uploadedEventImageUrl) {
    Firestore.instance.collection("events").add({
      // 'eventId' :
      'eventName': eventNameController.text,
      'eventVenue': eventVenueController.text,
      'eventDateAndTime': eventDateAndTimeController.text,
      'eventDescription': eventDescriptionController.text,
      'eventImage': uploadedEventImageUrl,
      'eventType': eventTypeSelected,
      'eventLink': eventLinkController.text,

      //for query:
      'eventSearchQuery':
          setSearchParam(eventNameController.text.toLowerCase()),

      //organiser's contact
      'userId': user.uid,
      'userName': this.userName,
      'club_organiserName': this.clubOrganiserName,
      'userPhoneNo': this.userPhoneNo,
      'club_organiserContactNo': this.clubOrganiserContactNo == ''
          ? ''
          : this.clubOrganiserContactNo,
      'userInstituteLocation': this.userInstituteLocation,
      // 'organiser's : this.club_organiserName

      'serverTimeStamp': FieldValue.serverTimestamp()
    }).then((_) {
      if (fetchedclubOrganiserName == null || fetchedclubOrganiserName == '') {
        print('club name null... updating profile');
        updateProfileData();
      }

      Future.delayed(Duration(seconds: 2)).then((onValue) {
        setState(() {
          print('posting = false');
          // isUploading = false;
          uploaded = true;
          resetPage();
        });
        final snackBar = SnackBar(content: Text('Event Posted!'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }).catchError((onError) {
        print(onError.toString());
      });
      // isUploading = false;
    }).catchError((e) => print(e));
  }

  void resetPage() {
    eventNameController.text = '';
    eventDateAndTimeController.text = '';
    eventVenueController.text = '';
    eventDescriptionController.text = '';
    eventTypeSelected = '';
    eventLinkController.text = '';
    _imageFile = null;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool uploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('ADD EVENT'),
          centerTitle: true,
        ),
        body: isUploading ? showProgressScreen() : bodyContent());
  }

  showProgressScreen() {
    return
        // _imageFile == null
        //     ?
        Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        !uploaded
            ? CircularProgressIndicator()
            : Text(
                '🎉🎉🎉',
                style: TextStyle(fontSize: 20.0),
              ),
        Text(
          !uploaded ? 'Uploading. Please wait...' : 'Your Post is now Live!',
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    ));

  }

  bodyContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: 5.0,
            ),
            _addPhoto(),

            Card(
              elevation: 3.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 8.0,
                        ),
                        Container(
                            // color: Colors.blue,
                            child: Text(
                          ('Add Image (optional)'),
                          style: TextStyle(fontSize: 16.0),
                          textAlign: TextAlign.start,
                        )),
                        IconButton(
                          icon: Icon(Icons.add_a_photo),
                          onPressed: () {
                            pickImage(ImageSource.camera);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.photo_library),
                          onPressed: () {
                            pickImage(ImageSource.gallery);
                          },
                        ),
                        Spacer()
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Choose Event Type',
                              style: TextStyle(fontSize: 16.0)),
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: getEventsCategory(context)
                            // _addDropdown(),
                            ),
                      ],
                    ),
                    SizedBox(
                      height: 7.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            // width: 150.0,
                            child: _textFormFieldTemplate(
                                "Event Name", "", eventNameController),
                          ),
                        ),
                        SizedBox(
                          width: 7.0,
                        ),
                        Text(
                          'at',
                          style: TextStyle(fontSize: 17.0),
                        ),
                        SizedBox(
                          width: 4.0,
                        ),
                        Expanded(
                          child: Container(
                            width: 100.0,
                            child: _textFormFieldTemplate(
                                "Event Venue", "", eventVenueController),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 7.0,
                    ),
                    _textFormFieldTemplate(
                        "Event Date and Time",
                        "Eg: 22nd jan . 7 pm - 8 pm",
                        eventDateAndTimeController),
                    SizedBox(
                      height: 7.0,
                    ),
                    _textFormFieldTemplate("Event Description (optional)", "",
                        eventDescriptionController),
                    SizedBox(
                      height: 7.0,
                    ),
                    addLinkTextForm(),
                    SizedBox(
                      height: 7.0,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 5.0,
            ),
            Card(
                elevation: 3.0,
                // color: Colors.blue[50],
                // .withOpacity(.2),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Club Info',
                              style: TextStyle(fontSize: 24.0))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Club Name:',
                            ),
                          ),
                          // club_organiserName == null || club_organiserName == ''

                          fetchedclubOrganiserName == null ||
                                  fetchedclubOrganiserName == ''
                              ? Expanded(
                                  child: TextFormField(
                                    // club_organiserName,
                                    validator: (value) {
                                      setState(() {
                                        this.clubOrganiserName = value;
                                      });
                                      if (value.isEmpty)
                                        return 'Required';
                                      else
                                        return null;
                                    },
                                    controller: clubOrganiserNameController,

                                    decoration: InputDecoration(
                                        hintText: 'Write your Club Name'),
                                  ),
                                  flex: 2,
                                )
                              : Expanded(
                                  flex: 2,
                                  child: Text(
                                    clubOrganiserName,
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: (Text('Contact No:')),
                          ),
                          Expanded(
                              flex: 2,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(),
                                controller: phoneController,
                                onChanged: (enteredPhoneNo) {
                                  setState(() {
                                    this.clubOrganiserContactNo =
                                        enteredPhoneNo;
                                  });
                                },
                              )
                              //  Text(phoneNo),
                              ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Institute Location:',
                            ),
                          ),
                          Expanded(
                            child: Text(userInstituteLocation),
                            flex: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
         
            isUploading
                ? Center(child: CircularProgressIndicator())
                : RaisedButton(
                    color: Colors.black54,
                    child: Text('Post Event',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      bool _validURL =
                          Uri.parse(eventLinkController.text).isAbsolute;

                      if (_imageFile == null) {
                        if (eventTypeSelected == '') {
                          final snackBar = SnackBar(
                              content: Text('Please choose an Event Type'));

                          // Find the Scaffold in the widget tree and use it to show a SnackBar.
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                          //Scaffold.of(context).showSnackBar(snackBar);

                        } else if (eventLinkController.text.isNotEmpty &&
                            !_validURL) {
                          final snackBar = SnackBar(
                              content: Text(
                                  'Invalid Link. Please recheck the link you provided.'));

                          // Find the Scaffold in the widget tree and use it to show a SnackBar.
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                          //Scaffold.of(context).showSnackBar(snackBar);
                        } else {
                          if (_formKey.currentState.validate()) {
                            // postEvent('');
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AlertDialog(
                                  title: new Text("Disclaimer",
                                      style: TextStyle(color: Colors.black87)),
                                  content: new Text(
                                      "Do you accept responsibility that the given details "
                                      "are true to the best of your knowledge "
                                      "& don't contain any inappropriate content?",
                                      style: TextStyle(color: Colors.black54)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)),
                                  actions: <Widget>[
                                    // usually buttons at the bottom of the dialog
                                    new FlatButton(
                                      child: new Text(
                                        "No, edit post",
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    new FlatButton(
                                      child: new Text("Yes"),
                                      onPressed: () {
                                        setState(() {
                                          isUploading = true;

                                          postEvent('');
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      } else if (eventTypeSelected == '') {
                        final snackBar = SnackBar(
                            content: Text('Please choose an Event Type'));

                        // Find the Scaffold in the widget tree and use it to show a SnackBar.
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                        //Scaffold.of(context).showSnackBar(snackBar);

                      } else {
                        if (_formKey.currentState.validate()) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Text("Disclaimer",
                                    style: TextStyle(color: Colors.black87)),
                                content: new Text(
                                    "Do you accept responsibility that the given details "
                                    "are true to the best of your knowledge "
                                    "& don't contain any inappropriate content?",
                                    style: TextStyle(color: Colors.black54)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0)),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text(
                                      "No, edit post",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  new FlatButton(
                                    child: new Text("Yes"),
                                    onPressed: () {
                                      setState(() {
                                        _startUpload(_imageFile);

                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
            SizedBox(
              height: 40.0,
            )
          ],
        ),
      ),
    );
  }

  setSearchParam(String searchQuery) {
    List<String> searchQueryList = List();
    String temp = "";
    int shortLength = searchQuery.length > 17 ? 17 : searchQuery.length;
    for (int i = 0; i < shortLength; i++) {
      temp = temp + searchQuery[i];
      searchQueryList.add(temp);
    }
    return searchQueryList;
  }

  Widget getEventsCategory(context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        // color: Colors.black,
        // padding: EdgeInsets.all(4.0),
        height: 50.0,
        width: MediaQuery.of(context).size.width - 32.0,
        child: ListView(
          // padding: EdgeInsets.all(10.0),
          // shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            getEventsChip('Technical'),
            SizedBox(
              width: 6.0,
            ),
            getEventsChip('Cultural'),
            SizedBox(
              width: 6.0,
            ),
            getEventsChip('Sports'),
            SizedBox(
              width: 6.0,
            ),
            getEventsChip('Fun'),
            SizedBox(
              width: 6.0,
            ),
            getEventsChip('Entrepreneurship'),
            SizedBox(
              width: 6.0,
            ),
            getEventsChip('Competetition'),
            SizedBox(
              width: 6.0,
            ),
            getEventsChip('Body, Mind & Soul'),
            SizedBox(
              width: 6.0,
            ),
            getEventsChip('Others'),
            SizedBox(
              width: 6.0,
            ),
          ],
        ),
      ),
    );
  }

  getEventsChip(String clickedEventType) {
    return InkWell(
      onTap: () {
        setState(() {
          this.eventTypeSelected = clickedEventType;
        });
      },
      child: Chip(
          label: Text(
            clickedEventType,
            style: TextStyle(
                color: eventTypeSelected == clickedEventType
                    ? Colors.white
                    : Colors.black),
          ),
          backgroundColor:
              // Colors.grey[300],
              // chipColor,
              eventTypeSelected == clickedEventType
                  ? Colors.black
                  : Colors.grey[300]
          // chipColor
          ),
    );
  }

  StorageUploadTask _uploadTask;
  bool isUploading = false;
  _startUpload(File imageToUpload) async {
    debugPrint('inside _startUpload');
    String _uploadedfileurl = "";


    String filePath = 'images/${DateTime.now()}.png';

    StorageReference _storageReference =
        FirebaseStorage.instance.ref().child(filePath);

    setState(() {
      isUploading = true;
      _uploadTask = _storageReference.putFile(imageToUpload);
    });
    await _uploadTask.onComplete.whenComplete(() {
      print('File Uploaded');
      //getting download link of image uploaded.
      _storageReference.getDownloadURL().then((fileurl) {
        setState(() {
          _uploadedfileurl = fileurl;
          debugPrint(_uploadedfileurl);
        });

        postEvent(_uploadedfileurl);

      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  void showRegisterDialog(BuildContext context) {
    var alertDialog = AlertDialog(
      title: Text("Event registered successfully"),
      content: Text("have a nice day"),
    );
    showDialog(
        context: context,
     

        builder: (BuildContext context) => alertDialog);
  }

  Widget addLinkTextForm() {
    return TextFormField(
       
        controller: eventLinkController,

        decoration: InputDecoration(
          labelText: 'Add Link (Optional)',
          hintText: 'E.g. Google Form Link',
        
          errorStyle: TextStyle(color: Colors.red, fontSize: 14.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
        ));
  }
}
