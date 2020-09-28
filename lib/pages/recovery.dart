import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class Forgot extends StatefulWidget {
  Forgot({Key key}) : super(key: key);
  @override
  _ForgotState createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController mobileCtrl = new TextEditingController();
  TextEditingController emailCtrl = new TextEditingController();
  static Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  String mobile, email, message, body, cr;
  ProgressDialog pr;
  final db = Firestore.instance;

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (await ConnectionVerify.connectionStatus()) {
        pr.update(message: "progress_wait".tr());
        pr.show();
        db
            .collection('users')
            .where('mobile', isEqualTo: mobile)
            .snapshots()
            .listen((data) async {
          if (data.documents.length > 0) {
            String devUser="chandan8345@gmail.com";
            String devPass="Gbb-1234";
            final smtpServer=gmail(devUser,devPass);
            String name = data.documents[0]['name'];
            String to = data.documents[0]['email'];
            String pass = data.documents[0]['password'];
            final message = Message()
              ..from = Address(devUser)
              ..recipients.add(to)
              ..subject = 'Green Wallet (Password Recovery)'
              ..text =
                  'This is the plain text.\nThis is line 2 of the text part.'
              ..html = "Hi $name Congrats! Now you can access your account. This is your password : $pass <br></br><b>GREEN WALLET AUTHORITY</b>";

            try {
              final sendReport = await send(message, smtpServer);
              print('Message sent: ' + sendReport.toString());
            } on MailerException catch (e) {
              print('Message not sent.');
              for (var p in e.problems) {
                print('Problem: ${p.code}: ${p.msg}');
              }
            }
            pr.hide();
            toast("check_mail".tr());
          }
        });
      } else {
        toast("connection_notify2".tr());
      }
    }
  }

  void toast(String text) {
    Fluttertoast.showToast(
        msg: text,
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  @override
  Widget build(BuildContext context) {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ListView(children: <Widget>[
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.9),
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
                          'recover'.tr(),
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.orange, fontSize: 25),
                        ),
                        Column(children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 20, top: 20),
                            child: TextFormField(
                              controller: mobileCtrl,
                              //obscureText: true,
                              decoration: new InputDecoration(
                                labelText: 'reg_mobile'.tr(),
                                fillColor: Colors.white,
                                //prefixText: ' ',
                                icon: Icon(Icons.lock),
                                border: UnderlineInputBorder(),
                              ),
                              //fillColor: Colors.green
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'reg_mobile_empty'.tr();
                                }
                                return null;
                              },
                              style: new TextStyle(
                                fontFamily: "Poppins",
                              ),
                              onSaved: (String val) {
                                this.mobile = val;
                              },
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Center(
                        child: InkWell(
                      onTap: () {},
                      child: Text(
                        "mail".tr(),
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    )),
                  ),
                  Center(
                    child: InkWell(
                      onTap: _submit,
                      child: roundedRectButton(
                          "send_email".tr(), signInGradients, false),
                    ),
                  )
                ],
              )
            ],
          ),
        ]),
      ),
    );
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
