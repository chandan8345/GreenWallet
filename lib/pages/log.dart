import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/pages/onboarding.dart';
import 'package:wallet/pages/recovery.dart';
import 'package:wallet/pages/register.dart';
import 'package:easy_localization/easy_localization.dart';

class Log extends StatefulWidget {
  Log({Key key}) : super(key: key);
  @override
  _LogState createState() => _LogState();
}

class _LogState extends State<Log> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController mobileCtrl = new TextEditingController();
  TextEditingController passwordCtrl = new TextEditingController();
  var mobile, password;
  final db = Firestore.instance;
  ProgressDialog pr;
  SharedPreferences sp;
  Map<dynamic, dynamic> statement;

  _submit() async {
    if (_formKey.currentState.validate()) {
      if (await ConnectionVerify.connectionStatus()) {
        pr.update(message: 'progress_wait'.tr());
        pr.show();
        db
            .collection('users')
            .where('mobile', isEqualTo: mobile)
            .where('password', isEqualTo: password)
            .snapshots()
            .listen((data) {
          if (data.documents.length > 0) {
            DocumentSnapshot d = data.documents[0];
            pr.hide();
            setSharedPreference(
                data.documents[0]['name'],
                data.documents[0]['mobile'],
                data.documents[0]['email'],
                data.documents[0]['password'],
                data.documents[0]['image'],
                d.documentID);
            Route route = MaterialPageRoute(builder: (context) => Home());
            Navigator.pushReplacement(context, route);
          } else {
            pr.hide();
            toast("connection_notify1".tr());
          }
        });
      } else {
        pr.hide();
        toast("connection_notify2".tr());
      }
    }
  }

  Future setSharedPreference(name, mobile, email, password, image, id) async {
    sp = await SharedPreferences.getInstance();
    sp.setString('name', name);
    sp.setString('mobile', mobile);
    sp.setString('password', password);
    sp.setString('email', email);
    sp.setString('imgurl', image);
    sp.setString("userid", id);
    print('sucess store');
  }

  void toast(String text) {
    Fluttertoast.showToast(
        msg: "$text",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true);
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Form(
            key: _formKey,
            child: ListView(children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2.9),
              ),
              Column(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, bottom: 0, top: 10),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'signin'.tr(),
                              textAlign: TextAlign.start,
                              style:
                                  TextStyle(color: Colors.green, fontSize: 25),
                            ),
                            Column(children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 5, top: 0),
                                child: TextFormField(
                                  controller: mobileCtrl,
                                  decoration: new InputDecoration(
                                    labelText: 'mobile'.tr(),
                                    fillColor: Colors.white,
                                    icon: Icon(Icons.phone),
                                    border: UnderlineInputBorder(),
                                    //fillColor: Colors.green
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'signin_notify1'.tr();
                                    }
                                    // else if (value.length != 11) {
                                    //   return 'Mobile no must be 11 Digits';
                                    // }
                                    else {
                                      return null;
                                    }
                                  },
                                  keyboardType: TextInputType.phone,
                                  style: new TextStyle(
                                    fontFamily: "Poppins",
                                  ),
                                  onSaved: (String val) {
                                    this.mobile = val;
                                  },
                                  onChanged: (String val) {
                                    setState(() {
                                      this.mobile = val;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 20, top: 0),
                                child: TextFormField(
                                    controller: passwordCtrl,
                                    obscureText: true,
                                    decoration: new InputDecoration(
                                      labelText: 'pass'.tr(),
                                      fillColor: Colors.white,
                                      icon: Icon(Icons.lock),
                                      border: UnderlineInputBorder(),
                                    ),
                                    //fillColor: Colors.green
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'signin_notify2'.tr();
                                      }
                                      return null;
                                    },
                                    style: new TextStyle(
                                      fontFamily: "Poppins",
                                    ),
                                    onSaved: (String val) {
                                      this.password = val;
                                    },
                                    onChanged: (String val) {
                                      setState(() {
                                        this.password = val;
                                      });
                                    }),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => Register());
                                Navigator.pushReplacement(context, route);
                              },
                              child: Text(
                                "demo".tr(),
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            Text(
                              "|",
                              style: TextStyle(color: Colors.black),
                            ),
                            InkWell(
                              onTap: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => Forgot());
                                Navigator.push(context, route);
                              },
                              child: Text(
                                "forgot".tr(),
                                style: TextStyle(color: Colors.deepOrange),
                              ),
                            )
                          ],
                        ),
                      ),
                      Center(
                        child: InkWell(
                          onTap: _submit,
                          child: roundedRectButton(
                              "submit".tr(), signInGradients, false),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ]),
          ),
        ),
        // ignore: missing_return
        onWillPop: () {
          Navigator.of(context).pop();
        });
  }
}

Widget roundedRectButton(
    String title, List<Color> gradient, bool isEndIconVisible) {
  return Builder(builder: (BuildContext mContext) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment(1.0, 0.0),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(mContext).size.width / 2.7,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            padding: EdgeInsets.only(top: 16, bottom: 16),
          ),
          Visibility(
            visible: isEndIconVisible,
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ImageIcon(
                  AssetImage("images/ic_forward.png"),
                  size: 30,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  });
}

const List<Color> signInGradients = [
  Color(0xFF0EDED2),
  Color(0xFF03A0FE),
];

const List<Color> signUpGradients = [
  Color(0xFFFF9945),
  Color(0xFFFc6076),
];
