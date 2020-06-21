import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Dialogs {
 void showReportDialog(colRef, context, String docId) {
                    var alertDialog = AlertDialog(
                      title: Text("Report this?"),
                      content: Text(
                          "If this post contains some inappropriate content, kindly report this to us.\n\nLet's keep Yozznet clean :)"),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel')),
                        FlatButton(
                            onPressed: () {
                              reportTheDoc(context, colRef, docId);
                            },
                            child: Text('Report')),
                      ],
                    );
                    showDialog(
                        context: context,
                        //builder: (BuildContext context){ // builder returns a widget
                        //return alertDialog;
                        //}
                
                        builder: (BuildContext context) => alertDialog);
                  }
                
                  void reportTheDoc(context, colRef, String docId) {
                    colRef.document(docId).updateData({
                      'reported': true,
                    }).then((_) {
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                        msg: "Thank you for reporting. We'll look into this.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }).catchError((e) {
                      print(e.toString());
                      Fluttertoast.showToast(
                        msg: "Coundn't report. Check connection.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    });
                  }
}