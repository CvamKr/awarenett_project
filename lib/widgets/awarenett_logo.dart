import 'package:flutter/material.dart';

class MyYozznetLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color:
        Colors.teal.withOpacity(.9),
//         Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Awarenett',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 50.0,
                  ),
                ),
                Text('',
//                'An app for all your college needs',

//                'enriching college experience',
                  style: TextStyle(fontSize: 22.0, color: Colors.white, ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
