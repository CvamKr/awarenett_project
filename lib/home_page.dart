//
//import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
//import 'package:flutter/material.dart';
//
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//import 'package:yozznett/pages/events/event_page.dart';
//import 'package:yozznett/pages/p2p_network/p2p_page.dart';
//import 'package:yozznett/pages/profile_page.dart';
//
//class MyHomePage extends StatefulWidget {
//  MyHomePage();
//
//  @override
//  _MyHomePageState createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  int _currentIndex = 0;
//  List<Widget> _pages = [
//
//    MyP2pPage(),
//    MyEventsPage(), MyProfilePage(),
//  ];
//
//
//
//  @override
//  Widget build(BuildContext context) {
//// debugPrint('inside build context');
//
//    return SafeArea(
//      child: Scaffold(
//        // appBar:  getCustomAppbar(),
//        body: _pages[_currentIndex],
//        // MyLostAndFoundPage(),
//
// bottomNavigationBar:BubbleBottomBar(
//          backgroundColor: Colors.transparent,
//            opacity: 1,
//            elevation: 0,
//          onTap: (index) {
//            setState(() {
//              _currentIndex = index;
//            });
//          },
//          currentIndex: _currentIndex,
//
//          items: <BubbleBottomBarItem>[
//
//            BubbleBottomBarItem(
//              backgroundColor: Colors.teal,
//              icon: Icon(MdiIcons.accountGroup, color: Colors.black,),
//              activeIcon: Icon(MdiIcons.accountGroup, color: Colors.white),
//              title: Text("P2P Network",
//               style: TextStyle(
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//
//                  ),
//                ),
//              ),
//
//              BubbleBottomBarItem(
//              backgroundColor: Colors.teal,
//              icon: Icon(Icons.event, color: Colors.black,),
//              activeIcon:Icon(Icons.event, color:Colors.white),
//              title: Text("Events",
//              style: TextStyle(
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//
//                  ),
//                  ),
//              ),
//
//              BubbleBottomBarItem(
//              backgroundColor: Colors.teal,
//              icon: Icon(Icons.tag_faces, color: Colors.black,),
//              activeIcon:Icon(Icons.tag_faces, color: Colors.white,),
//              title: Text("Profile",
//              style: TextStyle(
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//
//                  ),
//              ),
//              ),
//
//
//          ],
//        ),
//      // ),
//
//        // bottomNavigationBar: BottomNavigationBar(
//        //   onTap: (index) {
//        //     setState(() {
//        //       _currentIndex = index;
//        //     });
//        //   },
//        //   currentIndex: _currentIndex,
//        //   type: BottomNavigationBarType.fixed,
//        //   items: [
//        //     BottomNavigationBarItem(
//        //         icon: Icon(MdiIcons.accountGroup), title: Text("P2P Network")),
//        //     // BottomNavigationBarItem(
//        //     //     icon: Icon(Icons.event), title: Text("Orange")),
//        //     BottomNavigationBarItem(
//        //         icon: Icon(Icons.event), title: Text("Events")),
//        //     BottomNavigationBarItem(
//        //         icon: Icon(Icons.tag_faces), title: Text("Profile")),
//        //   ],
//        // ),
//      ),
//    );
//  }
//}
