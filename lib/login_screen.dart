import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'authservice.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = new GlobalKey<FormState>();
  String phoneNo, verificationId, smsCode;
  bool codeSent = false, showSpinner = false;

  widgetDisplayHeader(String text, double fontSize) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 3.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      color: Colors.white,
      inAsyncCall: showSpinner,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color(0xff6B63FF),
        body: SafeArea(
          child: Form(
              key: formKey,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          colors: [Colors.deepPurple[400], Color(0xff6B63FF)],
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 30.0),
                            widgetDisplayHeader('Hi!', 40.0),
                            widgetDisplayHeader('Welcome to Multi Box', 18.0),
                            SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(left: 2.0, right: 2.0),
                        height: MediaQuery.of(context).size.height / 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [
                              Colors.deepPurple[400],
                              Color(0xff6B63FF),
                            ],
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(40.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.elliptical(70, 100),
                                  bottomRight: Radius.elliptical(70, 50),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 25.0, right: 25.0),
                                      child: TextFormField(
                                        cursorColor: Colors.white,
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Colors.deepPurple[800],
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          hintText: 'Enter phone number',
                                          hintStyle: TextStyle(
                                              color: Colors.deepPurple[800],
                                              fontSize: 15.0),
                                          hoverColor: Colors.white,
                                          focusColor: Colors.white,
                                          icon: Icon(
                                            Icons.phone,
                                            color: Colors.deepPurple[800],
                                            size: 30.0,
                                          ),
                                        ),
                                        onChanged: (val) async {
                                          setState(() {
                                            this.phoneNo = '+91$val';
                                          });
                                        },
                                      )),
                                  codeSent
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0, right: 25.0),
                                          child: TextFormField(
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                                hintText: 'Enter OTP'),
                                            onChanged: (val) {
                                              setState(() {
                                                this.smsCode = val;
                                              });
                                            },
                                          ))
                                      : Container(),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 25.0, right: 25.0),
                                    child: RaisedButton(
                                        elevation: 10.0,
                                        color: Colors.deepPurple[800],
                                        padding: EdgeInsets.all(10.0),
                                        child: Center(
                                            child: codeSent
                                                ? Text(
                                                    'Verify',
                                                    style: TextStyle(
                                                        fontSize: 20.0,
                                                        color: Colors.white),
                                                  )
                                                : Text(
                                                    'Register / Login',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: Colors.white),
                                                  )),
                                        onPressed: () async {
                                          setState(() {
                                            showSpinner = true;
                                          });
                                          if (codeSent) {
                                            await AuthService().signInWithOTP(
                                                smsCode, verificationId);
                                            final snapShot = await Firestore.instance
                                                .collection('records')
                                                .document('$phoneNo')
                                                .get();
                                            if(snapShot == null || !snapShot.exists) {
                                              await Firestore.instance
                                                  .collection('records')
                                                  .document('$phoneNo')
                                                  .setData({
                                                'phone': phoneNo,
                                              });
                                            }
                                            setState(() {
                                              AuthService().handleAuth();
                                              showSpinner = false;
                                            });
                                          } else {
                                            await verifyPhone(phoneNo);
                                            setState(() {
                                              AuthService().handleAuth();
                                              showSpinner = false;
                                            });
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
