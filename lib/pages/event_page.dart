import 'dart:async';

import 'package:awarenett/pages/add_events_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MyEventsPage extends StatefulWidget {
  MyEventsPage({Key key}) : super(key: key);

  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int totalEventsCount = 0;
  var userName = '';
  String userInstituteLocation = '';

  String eventTypeSelected = 'All';

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
          this.userInstituteLocation =
              profileDataSnap.data['userInstituteLocation'];
          this.userName = profileDataSnap.data['userName'];
        });
      } else {
        print('profile data does not exist');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print('event page initState');


    try {
      FirebaseAuth.instance.currentUser().then((onlineUser) {
        setState(() {
          print('user is ${onlineUser.uid}');
          loadProfileData(onlineUser);
        });
      }).catchError((e) {
        print(e.toString());
      });
    } catch (e) {
      print(e.toString());
    }


  }

  @override
  void dispose() {
    profileColSubscription?.cancel();
    locationController?.dispose();
    searchEventController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'AWARENETT',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2.0, right: 2.0, top: 10),
              child: Text(
                '•',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 2),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 170,
                    child: Text(
                      this.userInstituteLocation,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  )),
            )
          ],
        ),
        actions: <Widget>[
          GestureDetector(
            child: Icon(
              Icons.more_vert,
            ),
            onTap: () {
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        title: Text(
                          'Are you sure you want to log out?',
                          textAlign: TextAlign.center,
                        ),
                        content: FlatButton(
                          padding: EdgeInsets.all(20),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          },
                          color: Colors.grey[200],
                          child: Text('Logout'),
                        ));
                  });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 5.0),
                        SizedBox(
                          height: 10.0,
                        ),
                        getSearchBar(),
                        SizedBox(
                          height: 6.0,
                        ),
                        getEventsCategory(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            eventTypeSelected == 'searchQuery'
                ? loadSearchList()
                :
//            loadEventsListt(),
                loadEventsList()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 10,
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyAddEventPage())),
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }



  loadSearchList() {
    return StreamBuilder<QuerySnapshot>(
      stream: eventColRef
          .where('userInstituteLocation', isEqualTo: this.userInstituteLocation)
          .where('eventSearchQuery',
              arrayContains: enteredSearchQuery.toLowerCase())
          .orderBy('serverTimeStamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          // : do something with the data
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // : do something with the error
          return Text(snapshot.error.toString());
        }
        // : the data is not ready, show a loading indicator
        return Padding(
          padding: const EdgeInsets.all(0.0),
          child: Container(
            // width: 200.0,
            // height: 400.0,
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              //  controller: _scrollController,
              itemCount: snapshot.data.documents.length + 2,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (index == 0) {
                  this.totalEventsCount =
                      // snapshot.length;
                      snapshot.data.documents.length;
                  // snapshot.data.documents.length;

                  return totalEventsCountTemplate(context, totalEventsCount);
                }
                if (index == totalEventsCount + 1) {
                  return Container(height: 100);
                } else {
                  DocumentSnapshot docSnap =
                      // snapshot[index-1];
                      snapshot.data.documents[index - 1];
//                  print('Snap length $totalEventsCount');
                  return _buildEventCard(docSnap);
                }
              },
            ),
          ),
        );
      },
    );
  }

  CollectionReference eventColRef = Firestore.instance.collection('events');

  bool isClicked = false;
  bool isShowDescriptionClicked = false;
  Widget _buildEventCard(doc) {
    return Padding(
        padding: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: AnimatedContainer(
            duration: Duration(seconds: 2),
            curve: Curves.easeOutSine,
            // height: isClicked ? null : 262,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  offset: Offset(0, 10),
                  blurRadius: 8,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),

                  ),
                  width: MediaQuery.of(context).size.width - 20,
                  child:
                      Image.network(doc.data['eventImage'], fit: BoxFit.cover),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 15.0, right: 14.0, bottom: 0.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        // color: Colors.blue,
                        child: Text(
                          '${doc['eventName']}',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      )),
                      SizedBox(width: 16.0),
                      InkWell(
                        onTap: () {
                          // dialogs.showReportDialog(
                          //     eventColRef, context, doc.documentID);
                        },
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
                ExpansionTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          '${doc['eventVenue']}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          '${doc['eventDateAndTime'] == null ? '' : doc['eventDateAndTime']}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          doc['club_organiserName'] == null
                              ? ''
                              : '${doc['club_organiserName']}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 8.0, bottom: 4.0),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(doc.data['eventDescription'] == null
                              ? 'event desc'
                              : doc.data['eventDescription'])),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          doc['eventLink'] == null || doc['eventLink'] == ''
                              ? Container()
                              : Expanded(
                                  child: IconButton(
                                    onPressed: () {
                                      openLink(doc['eventLink']);
                                    },
                                    icon: Icon(Icons.link),
                                  ),
                                ),

                          Expanded(
                            child: IconButton(
                              onPressed: () {
                                String contactNo =
                                    doc.data['club_organiserContactNo'];
                                debugPrint('phone no: $contactNo');
                                if (contactNo == null || contactNo == '') {
                                  final snackBar = SnackBar(
                                      content: Text(
                                          'No contact number provided by the organiser.'));

                                  _scaffoldKey.currentState
                                      .showSnackBar(snackBar);

                                  return;
                                }
                                launch("tel:$contactNo");
                              },
                              icon: Icon(Icons.call),
                            ),
                          ),

                          // Text(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

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
                    // : the data is not ready, show a loading indicator

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    // : do something with the error
                    return Text(snapshot.error.toString());
                  }
                  // : do something with the data

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      var length = snapshot.data.documents.length;
                      print('in listbuilder , length = $length');
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: getCurrentLocationTemplate(length),
                        );
                      } else {
                        DocumentSnapshot institutionNameDoc =
                            snapshot.data.documents[index - 1];

                        String institutionName =
                            institutionNameDoc.data['instituteLocation'];

                        return ListTile(
                          title: institutionName == null ||
                                  institutionName == ''
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
                              this.userInstituteLocation = institutionName;
                              this.locationQuery = '';
                              Navigator.pop(context);
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

  Widget getEventsCategory(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Container(
        // color: Colors.black,
        padding: EdgeInsets.all(4.0),
        height: 60.0,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          physics: ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            getEventsChip('All'),
            SizedBox(
              width: 6.0,
            ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: InkWell(
        onTap: () {
          setState(() {
            this.eventTypeSelected = clickedEventType;
            this.searchEventController.text = '';
          });

        },
        child: Chip(
          backgroundColor: eventTypeSelected == clickedEventType
              ? Colors.black
              : Colors.black54.withOpacity(0.13),
          label: Text(
            clickedEventType,
            style: TextStyle(
              color: eventTypeSelected == clickedEventType
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  queryEventsByCategory() {
    print('Event Clicked $eventTypeSelected');
    return Firestore.instance
        .collection('events')
        .where('userInstituteLocation', isEqualTo: userInstituteLocation)
        .where('eventType', isEqualTo: eventTypeSelected)
        .orderBy('serverTimeStamp', descending: true)
        .snapshots();
  }

  Widget loadEventsList() {
    Stream stream;
    if (eventTypeSelected == 'All') {
      //index made in firestore.
      stream = Firestore.instance
          .collection('events')
          .where('userInstituteLocation', isEqualTo: userInstituteLocation)
          .orderBy('serverTimeStamp', descending: true)
          .snapshots();
    } else if (eventTypeSelected == 'searchQuery') {
      stream = searchQuery();
    } else {
      //index made in firestore.
      stream = queryEventsByCategory();
    }

    return Container(
      // color: Colors.blue[100],

      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            print('event snap has data');
            // : do something with the data
            //  QuerySnapshot querySnapshot =snapshot.data;

            return ListView.builder(
                itemCount: snapshot.data.documents.length + 2,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    this.totalEventsCount = snapshot.data.documents.length;

                    return totalEventsCountTemplate(context, totalEventsCount);
                  }
                  if (index == totalEventsCount + 1) {
                    return Container(height: 100);
                  }
                  // else {
                  DocumentSnapshot doc = snapshot.data.documents[index - 1];
                  return _buildEventCard(doc);

                  // }
                });
            // _buildEventTemplate(snapshot);
          } else if (snapshot.hasError) {
            print('event snap no data');
            // : do something with the error
            return Text(snapshot.error.toString());
          }
          // : the data is not ready, show a loading indicator
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  //paginatin starts
  Firestore firestore = Firestore.instance;

  List<DocumentSnapshot> products = []; // stores fetched products

  bool isLoading = false; // track if products fetching

  bool hasMore = true; // flag for more products available or not

  int documentLimit = 5; // documents to be fetched per request

  DocumentSnapshot
      lastDocument; // flag for last document from where next 10 records to be fetched

// listener for listview scrolling
  //pagination ends



  searchQuery() {
    print('searching query');
    //  return Firestore.instance.collection('events').where('eventName', isEqualTo: enteredSearchQuery).snapshots();
    return Firestore.instance
        .collection('events')
        .where('eventSearchQuery',
            arrayContains: enteredSearchQuery.toLowerCase())
        .where('userInstituteLocation', isEqualTo: userInstituteLocation)
        // .orderBy('eventSearchQuery', descending: false)
        // .orderBy('userInstituteLocation', descending: false)
        .orderBy('serverTimeStamp', descending: true)
        .snapshots();

    // return Firestore.instance.collection('events').startAt(queryList).snapshots();
  }

  Widget totalEventsCountTemplate(BuildContext context, int length) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              searchEventController.text.length >= 0 &&
                      eventTypeSelected == 'searchQuery'
                  ? Text('Search Result: ')
                  : Container(),
              Text(
                length > 9 && length < 11 ? '+9' : '$length',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 7.0),
              Text(
                'Events ',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  var features = '';
  void showBottomSheet(context) {
    Firestore.instance
        .collection('whatsNext')
        .document('upcoming')
        .get()
        .then((docData) {
      setState(() {
        this.features = docData['features'];
      });
    });
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        features,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  openLink(String eventLink) async {
    // bool _validURL = Uri.parse(eventLink).isAbsolute;
    // var url = eventLink;
    // 'https://www.gmail.com';

    // if (_validURL) {
    if (await launch(eventLink)) {
      debugPrint("launching");
      await launch(eventLink);
    } else {
      //throw 'Could not launch $url';
      debugPrint("can't launch");
    }
    // }
  }

  bool isImageExpanded = false;
  var imageContainerHeight = 200.0;
  var tappedImage;
  var imagefit = BoxFit.cover;

  getImage(doc) {
    return InkWell(
      onTap: () {
        setState(() {
          this.imageContainerHeight = 400.0;
          this.imagefit = BoxFit.contain;

          this.tappedImage = doc['eventImage'];

          if (tappedImage != doc['eventImage']) {
            this.isImageExpanded = false;
          }

          isImageExpanded = isImageExpanded ? false : true;
        });
      },
      child: AnimatedContainer(
        // color: Colors.blue,
        duration: Duration(milliseconds: 1000),
        curve:

            // Curves.easeIn,
            Curves.fastOutSlowIn,
        width: double.infinity,

        height: doc['eventImage'] == '' || doc['eventImage'] == 'eventImage'
            ? 0.0
            :
            // isImageExpanded
            //     ? tappedImage == doc['eventImage'] ? imageContainerHeight : 100.0
            //     : 100.0,

            tappedImage == doc['eventImage']
                ? isImageExpanded ? imageContainerHeight : 200
                : 200,
        // color: Colors.cyan,
        child: SizedBox(
          child: doc['eventImage'] == ''
              ? Container()
              : Stack(
                  children: <Widget>[
                    Center(child: CircularProgressIndicator()),
                    SizedBox.expand(
                      child: FadeInImage.memoryNetwork(
                        placeholder:
                            //  Image.network('http://entechdesigns.com/new_site/wp-content/themes/en-tech/images/not_available_icon.jpg'),

                            kTransparentImage,
                        image: "${doc['eventImage']}",
                        fit: tappedImage == doc['eventImage']
                            ? isImageExpanded ? imagefit : BoxFit.cover
                            : BoxFit.cover,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  var searchEventController = TextEditingController();
  // var queryList = [''];
  var enteredSearchQuery = '';
  getSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Container(
          height: 50.0,
          // color: Colors.white,
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],

            // color: Colors.blueGrey[100].withOpacity(.5),
            // Colors.grey[200],
            //use here Colors.white, and in the scaffold-> backgroundColor: Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(15),

            border: Border.all(
                color:
//                Colors.black,
                    Colors.transparent,
                style: BorderStyle.solid,
                width: 0.75),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: TextField(
              controller: searchEventController,
              onChanged: (String enteredSearchQuery) {
                setState(() {
                  this.eventTypeSelected =
                      // searchEventController.text.length == 0
                      //     ? this.eventTypeSelected = 'All'
                      // :
                      'searchQuery';
                  this.enteredSearchQuery = enteredSearchQuery;
                });
              },
              decoration: InputDecoration(
                focusColor: Colors.indigo[50],
                hintText: "Search Events...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                fillColor: Colors.blue[50],
              ),
            ),
          ),
        ),
      ),
    );
  }

  var locationQuery = '';
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
          this.userInstituteLocation,
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
}
