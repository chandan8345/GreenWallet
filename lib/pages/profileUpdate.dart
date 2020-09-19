import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileUpdate extends StatefulWidget {
  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  bool hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameCtrl = new TextEditingController();
  TextEditingController newPassCtrl = new TextEditingController();
  TextEditingController oldPassCtrl = new TextEditingController();
  TextEditingController emailCtrl = new TextEditingController();
  TextEditingController mobileCtrl = new TextEditingController();
  TextEditingController passCtrl = new TextEditingController();
  static Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  String name,
      email,
      mobile,
      imageurl,
      password,
      oldpassword,
      newpassword,
      user;
  ProgressDialog pr;
  SharedPreferences sp;
  File image;
  RegExp regex = new RegExp(pattern);
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final db = Firestore.instance;

  @override
  void initState() {
    super.initState();
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    _welcome();
  }

  void toast(String text) {
    Fluttertoast.showToast(
        msg: text,
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      pr.update(message: "update".tr());
      pr.show();
      if (await ConnectionVerify.connectionStatus()) {
        if (image != null) {
          StorageReference ref =
              storageReference.child("images/").child("$mobile");
          StorageUploadTask task = ref.putFile(image);
          var img = await (await task.onComplete).ref.getDownloadURL();
          if (newPassCtrl.text.length > 0) {
            db.collection("users").document(user).updateData({
              'name': nameCtrl.text,
              'email': emailCtrl.text,
              'password': newPassCtrl.text,
              'image': img
            }).then((_) {
              pr.hide();
              this.password = newPassCtrl.text;
              setSharedPreferenceImage(
                  nameCtrl.text, emailCtrl.text, newPassCtrl.text, img);
              newPassCtrl.clear();
              oldPassCtrl.clear();
              toast("done".tr());
            });
          } else {
            db.collection("users").document(user).updateData({
              'name': nameCtrl.text,
              'email': emailCtrl.text,
              'image': img
            }).then((_) {
              pr.hide();
              setSharedPreferenceImage(
                  nameCtrl.text, emailCtrl.text, password, img);
              oldPassCtrl.clear();
              newPassCtrl.clear();
              toast("done".tr());
            });
          }
        } else {
          if (newPassCtrl.text.length > 0) {
            db.collection("users").document(user).updateData({
              'name': nameCtrl.text,
              'email': emailCtrl.text,
              'password': newPassCtrl.text,
            }).then((_) {
              pr.hide();
              this.password = newPassCtrl.text;
              setSharedPreference(nameCtrl.text, emailCtrl.text, newPassCtrl.text);
              oldPassCtrl.clear();
              newPassCtrl.clear();
              toast("done".tr());
            });
          } else {
            db.collection("users").document(user).updateData({
              'name': nameCtrl.text,
              'email': emailCtrl.text,
            }).then((_) {
              pr.hide();
              setSharedPreference(nameCtrl.text, emailCtrl.text, password);
              oldPassCtrl.clear();
              newPassCtrl.clear();
              toast("done".tr());
            });
          }
        }
      } else {
        toast("connection_notify2".tr());
      }
    }
  }

  Future getImage() async {
    var img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.image = img;
    });
  }

  Future setSharedPreferenceImage(name, email, password, image) async {
    sp = await SharedPreferences.getInstance();
    sp.setString('name', name);
    sp.setString('password', password);
    sp.setString('email', email);
    sp.setString('imgurl', image);
    print('sucess store');
  }

  Future setSharedPreference(name, email, password) async {
    sp = await SharedPreferences.getInstance();
    sp.setString('name', name);
    sp.setString('password', password);
    sp.setString('email', email);
    print('sucess store');
  }

  _welcome() async {
    sp = await SharedPreferences.getInstance();
    String pass = sp.getString('password');
    String name = sp.getString('name');
    String image = sp.getString('imgurl');
    String mobile = sp.getString('mobile');
    String email = sp.getString('email');
    String userid = sp.getString('userid');
    setState(() {
      nameCtrl.text = name;
      mobileCtrl.text = mobile;
      emailCtrl.text = email;
      this.imageurl = image;
      this.name = name;
      this.user = userid;
      this.password = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: _formKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: image != null
                    ? FileImage(image)
                    : new NetworkImage(imageurl),
                fit: BoxFit.cover)),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(),
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 24),
                  child: ListView(
                    children: <Widget>[
                      Text(
                        'welcome'.tr() + name,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'tap_image'.tr(),
                            style: TextStyle(
                                color: Colors.black54,
                                fontStyle: FontStyle.italic),
                          ),
                          InkWell(
                            child: Icon(Icons.camera_alt, color: Colors.pink),
                            onTap: () {
                              getImage();
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 0, right: 0, bottom: 0, top: 0),
                        child: TextFormField(
                          controller: nameCtrl,
                          decoration: new InputDecoration(
                            labelText: 'name'.tr(),
                            fillColor: Colors.white,
                            icon: Icon(
                              Icons.person,
                              color: Colors.black,
                            ),
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
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       left: 0, right: 0, bottom: 0, top: 0),
                      //   child: TextFormField(
                      //     controller: studentidCtrl,
                      //     decoration: new InputDecoration(
                      //       labelText: 'Student/Staff ID',
                      //       fillColor: Colors.white,
                      //       prefixText: '',
                      //       icon: Icon(
                      //         Icons.account_balance_wallet,
                      //         color: Colors.black,
                      //       ),
                      //       border: UnderlineInputBorder(),
                      //       //fillColor: Colors.green
                      //     ),
                      //     // validator: (value) {
                      //     //   if (value.isEmpty) {
                      //     //     return 'Please enter staff id';
                      //     //   }else {
                      //     //     return null;
                      //     //   }
                      //     // },
                      //     keyboardType: TextInputType.phone,
                      //     style: new TextStyle(
                      //       fontFamily: "Poppins",
                      //     ),
                      //     onChanged: (value) {
                      //       setState(() {

                      //       });
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       left: 0, right: 0, bottom: 0, top: 0),
                      //   child: TextFormField(
                      //     controller: mobileCtrl,
                      //     decoration: new InputDecoration(
                      //       labelText: 'Mobile No',
                      //       fillColor: Colors.white,
                      //       prefixText: '+88 ',
                      //       icon: Icon(
                      //         Icons.phone,
                      //         color: Colors.black,
                      //       ),
                      //       border: UnderlineInputBorder(),
                      //       //fillColor: Colors.green
                      //     ),
                      //     validator: (value) {
                      //       if (value.isNotEmpty && value.length != 11) {
                      //         return 'Mobile no must be 11 Digits';
                      //       } else {
                      //         return null;
                      //       }
                      //     },
                      //     keyboardType: TextInputType.phone,
                      //     style: new TextStyle(
                      //       fontFamily: "Poppins",
                      //     ),
                      //     onChanged: (value) {
                      //       setState(() {
                      //         this.mobile = value;
                      //       });
                      //     },
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 0, right: 0, bottom: 0, top: 0),
                        child: TextFormField(
                          controller: emailCtrl,
                          decoration: new InputDecoration(
                            labelText: 'email'.tr(),
                            fillColor: Colors.white,
                            icon: Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            border: UnderlineInputBorder(),
                            //fillColor: Colors.green
                          ),
                          validator: (value) {
                            if (value.isNotEmpty && !regex.hasMatch(value)) {
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
                            left: 0, right: 0, bottom: 0, top: 0),
                        child: TextFormField(
                          controller: oldPassCtrl,
                          obscureText: true,
                          decoration: new InputDecoration(
                            labelText: 'oldpass'.tr(),
                            fillColor: Colors.white,
                            icon: Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            border: UnderlineInputBorder(),
                            //fillColor: Colors.green
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'pass_notify1'.tr();
                            } else if (value != password) {
                              return 'pass_notify2'.tr();
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
                              this.oldpassword = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 0, right: 0, bottom: 0, top: 0),
                        child: TextFormField(
                          controller: newPassCtrl,
                          obscureText: true,
                          decoration: new InputDecoration(
                            labelText: 'newpass'.tr(),
                            fillColor: Colors.white,
                            icon: Icon(
                              Icons.security,
                              color: Colors.black,
                            ),
                            border: UnderlineInputBorder(),
                            //fillColor: Colors.green
                          ),
                          // validator: (value) {
                          //   if (value != password) {
                          //     return 'Please enter secure code';
                          //   }else {
                          //     return null;
                          //   }
                          // },
                          keyboardType: TextInputType.text,
                          style: new TextStyle(
                            fontFamily: "Poppins",
                          ),
                          onChanged: (value) {
                            setState(() {
                              this.newpassword = value;
                            });
                          },
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(left: 5,right: 0, bottom:10, top: 0),
                      //   child:DropdownButtonFormField(
                      //     decoration: new InputDecoration(
                      //       labelText: 'Department',
                      //       fillColor: Colors.white,
                      //       isDense: true,
                      //       icon: Icon(Icons.import_contacts,color: Colors.black,),
                      //       border: UnderlineInputBorder(),
                      //       //fillColor: Colors.green
                      //     ),
                      //     value: (department != null)?department:null,
                      //     items: (departments != null)?departments.map((array){
                      //       return DropdownMenuItem(
                      //         value: array['name'].toString(),
                      //         child: Text(array['name']),
                      //       );
                      //     }).toList():null,
                      //     onChanged: (value){
                      //       setState((){
                      //         this.department=value;
                      //       });
                      //       _setDepartment(department);
                      //     },
                      //     validator: (value) {
                      //       if (value.isEmpty) {
                      //         return 'Please enter your department';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 0),
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
                                  "up".tr(), signUpGradients, false),
                            ),
                          ],
                        ),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     border: Border.all(color: Colors.black87,width: 1),
                      //     borderRadius: BorderRadius.circular(7)
                      //   ),
                      //   child: CustomButton(
                      //     text: 'Update',
                      //     bgColor: Colors.white.withOpacity(0),
                      //     textColor: Colors.black,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({this.bgColor, this.text, this.textColor});

  final Color bgColor;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(7),
            child: InkWell(
              borderRadius: BorderRadius.circular(7),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  '$text',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 15),
                ),
              ),
            ),
          ),
        )
      ],
    );
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
