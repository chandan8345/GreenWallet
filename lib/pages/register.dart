import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:wallet/pages/log.dart';
import 'package:easy_localization/easy_localization.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameCtrl = new TextEditingController();
  TextEditingController emailCtrl = new TextEditingController();
  TextEditingController mobileCtrl = new TextEditingController();
  TextEditingController passCtrl = new TextEditingController();
  String name, email, mobile, password;
  static Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  File _image;
  List country;
  bool status = false;
  ProgressDialog pr;
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final db = Firestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _submit() async {
      if (_formKey.currentState.validate()) {
        if (_image != null) {
        if (await ConnectionVerify.connectionStatus()) {
          pr.update(message: 'progress_wait'.tr());
          pr.show();
          await exist();
          if(status != false){
          StorageReference ref =
              storageReference.child("images/").child("$mobile");
          StorageUploadTask task = ref.putFile(_image);
          var imageUrl = await (await task.onComplete).ref.getDownloadURL();
          db
              .collection('users')
              .where('mobile', isEqualTo: mobile)
              .getDocuments()
              .then((data) {
            print(data.documents.length);
            if (data.documents.length != 1) {
              db.collection("users").add({
                'name': nameCtrl.text,
                'mobile': mobileCtrl.text,
                'email': emailCtrl.text,
                'password': passCtrl.text,
                'image': imageUrl
              }).then((_) {
                pr.hide();
                toast("reg_sucess".tr());
                this.status = false;
              });
            } else {
              pr.hide();
              toast("exist".tr());
            }
          });
        }else{
          pr.hide();
          toast("exist".tr());
        }
         }else {
          toast("connection_notify2".tr());
        }
      }
      else{
        getImage();
      }
    }
  }

  Future exist() async {
    db
        .collection('users')
        .where("mobile", isEqualTo: mobile)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        setState(() {
          this.status=true;
        });
      });
    });
  }

  Future getImage() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      this._image = img;
    });
  }

  void toast(String text) {
    Fluttertoast.showToast(
        msg: "$text",
        toastLength: Toast.LENGTH_LONG,
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
    return Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 25.0),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: AvatarGlow(
                                    startDelay: Duration(milliseconds: 1000),
                                    glowColor: Colors.black,
                                    endRadius: 90.0,
                                    duration: Duration(milliseconds: 2000),
                                    repeat: true,
                                    showTwoGlows: true,
                                    repeatPauseDuration:
                                        Duration(milliseconds: 100),
                                    child: Material(
                                        elevation: 8.0,
                                        shape: CircleBorder(),
                                        child: CircleAvatar(
                                          radius: 70,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 70.0,
                                            backgroundImage: (_image != null)
                                                ? FileImage(_image)
                                                : NetworkImage(
                                                    "https://i7.pngguru.com/preview/136/22/549/user-profile-computer-icons-girl-customer-avatar.jpg",
                                                  ),
                                          ),
                                        )
                                        //child: Image.asset('assets/images/flutter.png',height: 60,),
                                        //shape: BoxShape.circle
                                        ),
                                    shape: BoxShape.circle,
                                    animate: true,
                                    curve: Curves.fastOutSlowIn,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 115.0, left: 130.0),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt,
                                      size: 25.0,
                                    ),
                                    onPressed: () {
                                      getImage();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'register'.tr(),
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.orange, fontSize: 25),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: Column(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 0, top: 0),
                        child: TextFormField(
                          controller: nameCtrl,
                          decoration: new InputDecoration(
                            labelText: 'name'.tr(),
                            fillColor: Colors.white,
                            icon: Icon(Icons.person),
                            border: UnderlineInputBorder(),
                            //fillColor: Colors.green
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'signup_notify1'.tr();
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.text,
                          style: new TextStyle(
                            fontFamily: "Poppins",
                          ),
                          onChanged: (value) {
                            setState(() {
                              this.name = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 0, top: 0),
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
                          onChanged: (value) {
                            setState(() {
                              this.mobile = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 0, top: 0),
                        child: TextFormField(
                          controller: emailCtrl,
                          decoration: new InputDecoration(
                            labelText: 'email'.tr(),
                            fillColor: Colors.white,
                            icon: Icon(Icons.email),
                            border: UnderlineInputBorder(),
                            //fillColor: Colors.green
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'signup_notify2'.tr();
                            } else if (!regex.hasMatch(value)) {
                              return 'signup_notify3'.tr();
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                          style: new TextStyle(
                            fontFamily: "Poppins",
                          ),
                          onChanged: (value) {
                            setState(() {
                              this.email = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, bottom: 0, top: 0),
                        child: TextFormField(
                          controller: passCtrl,
                          obscureText: true,
                          decoration: new InputDecoration(
                            labelText: 'pass'.tr(),
                            fillColor: Colors.white,
                            icon: Icon(Icons.lock),
                            border: UnderlineInputBorder(),
                            //fillColor: Colors.green
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'signin_notify2'.tr();
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.text,
                          style: new TextStyle(
                            fontFamily: "Poppins",
                          ),
                          onChanged: (value) {
                            setState(() {
                              this.password = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 15, top: 10),
                        child: Center(
                            child: InkWell(
                          onTap: () {
                            Route route =
                                MaterialPageRoute(builder: (context) => Log());
                            Navigator.push(context, route);
                          },
                          child: Text("demo2").tr(),
                        )),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // InkWell(
                        //   onTap: getImage,
                        //   child:
                        //   roundedRectButton("Get Photo", signInGradients, false),
                        // ),
                        InkWell(
                          onTap: _submit,
                          child: roundedRectButton(
                              "register".tr(), signUpGradients, false),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

Widget roundedRectButton(
    String title, List<Color> gradient, bool isEndIconVisible) {
  return Builder(builder: (BuildContext mContext) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Stack(
        alignment: Alignment(1.0, 0.0),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(mContext).size.width / 2.8,
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
                    fontSize: 18,
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
