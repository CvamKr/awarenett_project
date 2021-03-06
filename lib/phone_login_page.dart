import 'package:awarenett/pages/event_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPhoneLoginPage extends StatefulWidget {
  MyPhoneLoginPage({Key key}) : super(key: key);

  @override
  _MyPhoneLoginPageState createState() => _MyPhoneLoginPageState();
}

class _MyPhoneLoginPageState extends State<MyPhoneLoginPage> {
  String phone, smsOtp, verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String userId = '';

  bool otpReceived = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal,
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.transparent
                      ])),
                ),
                Positioned(
                    top: 85,
                    child: Padding(
                        padding: EdgeInsets.only(top: 120),
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            // Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(60)),
                          ),
                        ))),
                Positioned(
                    top: 135,
                    left: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 55,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Awarenett",
                          style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                    )),
                Positioned(
                  top: 280,
                  child: Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 60,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  // Colors.black,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                  padding: EdgeInsets.only(left: 75),
                                  child: TextField(
                                      onChanged: (enteredPhoneNum) {
                                        this.phone = '+91$enteredPhoneNum';
                                      },
                                      style: TextStyle(color: Colors.white),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: "Enter your phone number",
                                        hintStyle: TextStyle(
                                            color: Colors.grey[100]
                                                .withOpacity(0.70),
                                            fontSize: 15),
                                        border: InputBorder.none,
                                      ),
                                      cursorColor: Colors.white,
                                      cursorRadius: Radius.circular(30),
                                      cursorWidth: 2)),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          !otpReceived
                              ? Center(child: CircularProgressIndicator())
                              : InkWell(
                                  onTap: () {
                                    if (phone == null || phone.length < 10) {
                                      Fluttertoast.showToast(
                                        msg: "Enter all 10 digits.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIos: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                      return;
                                    }
                                    otpReceived = false;

                                    print("verification started...");

                                    verifyPhone();
                                  },
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Container(
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white),
                                          child: Center(
                                              child: Text(
                                            "VERIFY",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800),
                                          )))),
                                ),
                          SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ])),
        ));
  }

  bool autoRetrivedTimeOut = false;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print('auto retrieving code timeout');
      this.verificationId = verificationId;
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      setState(() {
        otpReceived = true;
      });
      smsOtpDialog(context).then((onValue) {
        // print('sign in');
      }).catchError((e) {
        print(e.toString);
      });
    };

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential _authCredential) {
      debugPrint('verified');

      _auth.signInWithCredential(_authCredential).then((AuthResult value) {
        if (value.user != null) {
          setState(() {
            debugPrint('Auth successful');
            debugPrint('user id after auth success ${value.user.uid}');
          });
          onAuthenticationSuccessful(value.user);
        } else {
          setState(() {});
        }
      }).catchError((e) {
        print(e.toString());
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      print('verification failed. ${authException.message}');
      Fluttertoast.showToast(
        msg:
            "Verification Failed. Try later.\nError cause: ${authException.message}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        otpReceived = true;
      });
    };

    await _auth.verifyPhoneNumber(
      phoneNumber: phone, // PHONE NUMBER TO SEND OTP
      timeout: const Duration(seconds: 10),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    otpController?.dispose();

    super.dispose();
  }

  var otpController = TextEditingController();
  smsOtpDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: Text('Enter Otp, if auto verification fails'),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
          ),
          contentPadding: EdgeInsets.all(8.0),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close')),
            FlatButton(
              child: Text('Done'),
              onPressed: () async {
                if (mounted) {
                  setState(() {
                    this.smsOtp = otpController.text;
                  });
                }
                print('opt dialog done clickedd');

                if (user != null) {
                  Navigator.pop(context);

                  onAuthenticationSuccessful(user);
                } else {
                  Navigator.pop(context);
                  signIn();
                }
              },
            ),
          ],
        );
      },
    );
  }

  signIn() async {
    print('in sign in method...');
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOtp,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)) as FirebaseUser;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      onAuthenticationSuccessful(currentUser);
    } catch (e) {
      print(e.toString());
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        Fluttertoast.showToast(
          msg: "Invalid code",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.pop(context);

        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  void onAuthenticationSuccessful(user) {
    debugPrint('inside onAuthenticationSuccesful');

    if (user != null) {
      debugPrint('user is not null, user is ${user.uid}');

      //check if user profile already exists
      Firestore.instance
          .collection('userProfile')
          .document(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          debugPrint('profile exists while logging');
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyEventsPage()),
          );
        }
      }).catchError((e) {
        print(e.toString());
      });
    } else {
      debugPrint('user is null');
      Navigator.pop(context);
    }
  }
}
