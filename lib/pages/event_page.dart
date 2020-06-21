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
  // widget.currentInstitutionName = '';
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
//        if(mounted){
//          getEventsData();
//
//        }
        getEventsData();
      } else {
        print('profile data does not exist');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print('event page initState');

    _scrollController = ScrollController();

    // this.widget.currentInstitutionName = '';
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
    searchEventController?.dispose();

    super.dispose();
  }

  // bool _isOnTop = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Colors.blueGrey.withOpacity(.8),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('AWARENETT',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 2
              ),),
            Padding(
              padding: const EdgeInsets.only(left: 2.0, right: 2.0,top: 10),
              child: Text('•',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:4.0),
              child: Container(
                width:
//                200,
                MediaQuery.of(context).size.width-170,

                child: Text('Manipal Institute of Technology',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        )
      ),


      body: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: ListView(
          controller: _scrollController,
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
                    // color: Colors.blue[400].withOpacity(.8),
                    decoration: BoxDecoration(

                    ),
                    //-----------------------------------------------
                    child: Column(
                    children: <Widget>[
                        SizedBox(height: 5.0),


                        SizedBox(
                          height: 5.0,
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

             loadEventsList(),


          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 10,
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => MyAddEventPage()
        )),
        child: Icon(Icons.add, size: 30,),
      ),

      // _getEventsList(),
    );
  }


  loadSearchList() {
    // reloadP2PList();
    return StreamBuilder<QuerySnapshot>(
      stream: eventColRef
          .where('userInstituteLocation', isEqualTo: this.userInstituteLocation)
          .where('eventSearchQuery',
          arrayContains: enteredSearchQuery.toLowerCase())
      // .orderBy('itemSearchQuery')
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

                // return ListTile(
                //   contentPadding: EdgeInsets.all(5),
                //   title: Text(products[index].data['itemName']),
                //   subtitle: Text(
                //       '${products[index].data['userName']} ${products.length}'),
                // );
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
    // bool isClicked = false;
    // bool isClicked = false;

    //  handleClick(){
    //    isClicked = (isClicked == true) ? false : true;
    // }

    return Padding(
        padding: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: AnimatedContainer(
            duration: Duration(seconds: 2),
            curve: Curves.easeOutSine,
            // height: isClicked ? null : 262,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
//              boxShadow: [
//                BoxShadow(
//                  color: Colors.black.withOpacity(.12),
//                  offset: Offset(0, 10),
//                  blurRadius: 8,
//                )
//              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedContainer(
                  //image
                  duration: Duration(seconds: 2),
                  curve: Curves.easeOutSine,
                  // child: Image(
                  //   image: AssetImage(imgpath),
                  //   height: isClicked? 300 : 125,
                  //   width: MediaQuery.of(context).size.width,
                  //   fit: BoxFit.cover,
                  // )
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    child: getImage(doc),
                  ),
                ),
                // SizedBox(
                //   height: 5,
                // ),
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
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                      SizedBox(width: 16.0),
                      // Expanded(
                      //   child: Align(
                      //     alignment: Alignment.centerRight,
                      //     child: Container(
                      //       // color: Colors.green,
                      //       child: Text(
                      //         doc['club_organiserName'] == null
                      //             ? ''
                      //             : '${doc['club_organiserName']}',
                      //       ),
                      //     ),
                      //   ),
                      // ),

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
                        padding: const EdgeInsets.only(top:10.0),
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
                          doc['eventLink'] == null || doc['eventLink'] ==''? Container(): Expanded(
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
                                  final snackBar = SnackBar(content: Text('No contact number provided by the organiser.'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
                                  _scaffoldKey.currentState.showSnackBar(snackBar);
//Scaffold.of(context).showSnackBar(snackBar);
                                  // showDialog();
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


  Widget getEventsCategory(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Container(
        // color: Colors.black,
        padding: EdgeInsets.all(4.0),
        height: 60.0,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          // padding: EdgeInsets.all(10.0),
          // shrinkWrap: true,
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
              ?
          // Colors.blue
          Colors.black

              : Colors.black54.withOpacity(0.13),
          label: Text(
            clickedEventType,
            style: TextStyle(
                color: eventTypeSelected == clickedEventType
                    ? Colors.white
                    : Colors.black,
              // Colors.blue[400],
              //  Colors.blue,
            ),
          ),
        ),
      ),
      // ),
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

    //   .listen((query){
    // print('query on $giaType done. ${query.documents.length} $giaType');
    //   });
    //   .then((QuerySnapshot querySnapshot) {
    // print('query on $giaType done. ${querySnapshot.documents.length} $giaType');
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
        // searchQuery(),

        //  eventTypeSelected == 'All'
        //     ? Firestore.instance.collection('events').snapshots()
        //     : queryEvents(),
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

  ScrollController _scrollController =
  ScrollController(); // listener for listview scrolling
  //pagination ends

  getEventsData() async {
    print('get product called');
    if (!hasMore) {
      print('has more = $hasMore');
      return;
    }
    if (isLoading) {
      print('isLoading = $isLoading');

      return;
    }
    setState(() {
      isLoading = true;
      print('isLoadinggg= $isLoading');
      print(
          'inside get products. GiaTypeSeleceted = ${this.eventTypeSelected}');
    });

    print('inside get products. GiaTypeSeleceted = ${this.eventTypeSelected}');
    Query query;
    if (eventTypeSelected == 'All') {
      query = eventColRef
          .where('userInstituteLocation', isEqualTo: this.userInstituteLocation)
      // .orderBy('userInstituteLocation', descending: true);
          .orderBy('serverTimeStamp', descending: true);
    } else if (eventTypeSelected == 'searchQuery') {
      print(
          'inside get products. GiaTypeSeleceted = ${this.eventTypeSelected}');
      setState(() {
        isLoading = false;
      });
      // query = searchQuery();
      return;
    } else {
      print(
          'inside get products. GiaTypeSeleceted = ${this.eventTypeSelected}');

      query = queryEventsByCategory();
    }

    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await query.limit(10).getDocuments();
    } else {
      querySnapshot = await query
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .getDocuments();

      // print('userInstituteLocation: ${this.userInstituteLocation}');
      // querySnapshot = await firestore
      //     .collection('p2pNetwork')
      //     .where('userInstituteLocation', isEqualTo: this.userInstituteLocation)
      //     // .orderBy('userInstituteLocation', descending: true)
      //     .orderBy('serverTimeStamp', descending: true)
      //     // .orderBy('userInstituteLocation')
      //     // .startAfterDocument(lastDocument)
      //     .limit(documentLimit)
      //     .getDocuments();

      print(1);
    }
    if (querySnapshot.documents.length < documentLimit) {
      hasMore = false;
    }
    if (querySnapshot.documents.length - 1 < 0) {
      lastDocument = null;
    } else {
      lastDocument =
      querySnapshot.documents[querySnapshot.documents.length - 1];
    }
    products.addAll(querySnapshot.documents);
    if(this.mounted){
      setState(() {
        isLoading = false;
      });
    }

  }


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
    // print('Total events $length');

    // var giaTypee;
    // if (giaType == 'All' || giaType == 'others') {
    //   giaTypee = 'item(s)';
    // } else if (giaType == 'Item Or Contribution Request') {
    //   giaTypee = 'Request(s)';
    // } else {
    //   giaTypee = giaType;
    // }

    //   var lengthh;
    //     // print('lengthh $lengthh');

    // Future.delayed(Duration(seconds: 3)).then((onValue) {
    //   setState(() {
    //     lengthh = length;
    //     print('lengthh $lengthh');
    //   });
    // });

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Icon(Icons.event),
          // SizedBox(width: 8.0 ,),
          Row(
            children: <Widget>[
              // lengthh == null
              //     ? Center(child: CircularProgressIndicator())
              //     :

              searchEventController.text.length >= 0 &&
                  eventTypeSelected == 'searchQuery'
                  ? Text('Search Result: ')
                  : Container(),

              Text(
                length > 9 && length < 11 ? '+9' : '$length',
                // '${Firestore.instance.collection('lostAndFoundPage').snapshots().length}',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  // Colors.white,
                  // textColor,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 7.0),
              Text(
                'Events ',
                // '${Firestore.instance.collection('lostAndFoundPage').snapshots().length}',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  // Colors.white,
                  // textColor,

                  // fontWeight: FontWeight.bold,
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
                // new ListTile(
                //     leading: new Icon(Icons.update),
                //     title: new Text('Update'),
                //     onTap: () => {}),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        features,
                        // 'Upcoming features...',
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Text(
                      //       '- sort Events by Time eg (this hour, today, tommorrow...)'),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Text('- improved User Interface.'),
                      // ),
                      // Text('Got suggestion for us?!',
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.bold, fontSize: 16.0)),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: <Widget>[
                      //     Expanded(
                      //       flex: 4,
                      //       child: TextField(
                      //         onChanged: (inputValue){

                      //         },
                      //         decoration: InputDecoration(
                      //             hintText: 'Write your suggestion'),
                      //       ),
                      //     ),
                      //     Expanded(
                      //         flex: 1,
                      //         child: IconButton(
                      //           icon: Icon(Icons.send),
                      //           onPressed: () {},
                      //         ))
                      //   ],
                      // ),
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

  // var imageContainerHeight = 100.0;



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
          // if (isImageExpanded == false) {
          //   this.isImageExpanded = true;
          // } else {
          //   this.isImageExpanded = false;
          // }
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
            ? isImageExpanded ? imageContainerHeight :200
            :200,
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

//            boxShadow: [
//              BoxShadow(
//                color: Colors.black.withOpacity(.15),
//                offset: Offset(0, 10),
//                blurRadius: 8,
//              )
//            ],
          ),

          // child: Row(
          //   children : <Widget>[
          //     Icon(Icons.search),

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
              // controller: lnfSearchController,
              // keyboardType: TextInputType.number,
              decoration: InputDecoration(
                focusColor: Colors.indigo[50],
                hintText: "Search Events...",
                hintStyle: TextStyle(color: Colors.grey),
                // labelText: "Search Events",
                // hintText: "Search for lost or found items e.g. wallet",
                border: InputBorder.none,
                fillColor: Colors.blue[50],
                // border: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(4.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
