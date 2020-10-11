import 'package:easy_localization/easy_localization.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/pages/cash.dart';
import 'package:wallet/pages/chart.dart';
import 'package:wallet/pages/onboarding.dart';
import 'package:wallet/pages/profileUpdate.dart';
import 'package:wallet/pages/updateCash.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:flutter/services.dart';

int index;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name, mobile, imageUrl;
  double _amount = 0.0, _cashIn = 0.0, _cashOut = 0.0;
  int tabIndex = 0, fy, ly;
  List list;
  SharedPreferences sp;
  final db = Firestore.instance;
  bool isChecked = false;
  var _bottomNavIndex = 0;
  DateTime firstDate, lastDate, fd, ld;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    range();
    getUser();
    dashboard();
  }

  @override
  void dispose() {
    super.dispose();
  }

  range() {
    DateTime now = DateTime.now();
    setState(() {
      this.firstDate = now.subtract(Duration(days: now.day - 1));
      this.lastDate = now;
      this.fd = firstDate;
      this.ld = lastDate;
      this.fy = DateTime.now().year;
      this.ly = DateTime.now().year + 1;
    });
  }

  Future<void> getUser() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      this.name = sp.getString('name');
      this.mobile = sp.getString('mobile');
      this.imageUrl = sp.getString('imgurl');
    });
  }

  Future<void> dashboard() async {
    if (await ConnectionVerify.connectionStatus()) {
      this._cashIn = 0.0;
      this._cashOut = 0.0;
      this._amount = 0.0;
      db
          .collection('post')
          .where('cashtype', isEqualTo: 'IN')
          .where('mobile', isEqualTo: mobile)
          .where('date', isGreaterThanOrEqualTo: fd.toString())
          .where('date', isLessThanOrEqualTo: ld.toString())
          .snapshots()
          .listen((snapshot) {
        this._cashIn = 0.0;
        snapshot.documents.forEach((doc) {
          setState(() {
            this._cashIn += double.parse(doc.data['amount']);
          });
        });
        db
            .collection('post')
            .where('cashtype', isEqualTo: 'OUT')
            .where('mobile', isEqualTo: mobile)
            .where('date', isGreaterThanOrEqualTo: fd.toString())
            .where('date', isLessThanOrEqualTo: ld.toString())
            .snapshots()
            .listen((snapshot) {
          this._cashOut = 0.0;
          snapshot.documents.forEach((doc) {
            setState(() {
              this._cashOut += double.parse(doc.data['amount']);
            });
          });
          setState(() {
            this._amount = _cashIn - _cashOut;
          });
        });
        _amount != 0.0
            ? print("amount not zero")
            : this._amount = _cashIn - _cashOut;
      });
    } else {
      toast("connection_notify2".tr());
      dashboard();
    }
  }

  void toast(String text) {
    Fluttertoast.showToast(
        msg: "$text",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.pink,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          ConfirmAlertBox(
              context: context,
              title: 'warning'.tr(),
              infoMessage: 'exit'.tr(),
              onPressedYes: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              });
        },
        child: Scaffold(
          backgroundColor: Colors.white12,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _bottomNavIndex,
            onTap: (index) async {
              setState(() {
                this._bottomNavIndex = index;
              });
              switch (index) {
                case 0:
                  Route route =
                      MaterialPageRoute(builder: (context) => CashIn());
                  Navigator.push(context, route);
                  break;
                case 1:
                  final List<DateTime> picked =
                      await DateRagePicker.showDatePicker(
                          context: context,
                          initialFirstDate: fd,
                          //add(new Duration(days: DateTime.now().day)),
                          initialLastDate: ld,
                          //(new DateTime.now()).add(new Duration(days: 7)),
                          firstDate: new DateTime(fy),
                          lastDate: new DateTime(ly));
                  if (picked != null && picked.length == 2) {
                    setState(() {
                      this.fd = picked.first;
                      this.ld = picked.last;
                    });
                    dashboard();
                  }
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Chart()),
                  );
                  break;
                case 3:
                  ConfirmAlertBox(
                      context: context,
                      title: 'warning'.tr(),
                      infoMessage: 'logme'.tr(),
                      onPressedYes: () {
                        try {
                          sp.clear();
                          Route route = MaterialPageRoute(
                              builder: (context) => Onboarding());
                          Navigator.pushReplacement(context, route);
                        } catch (e) {
                          print(e);
                        }
                      });
                  break;
                case 4:
                  ConfirmAlertBox(
                      context: context,
                      title: 'warning'.tr(),
                      infoMessage: 'exit'.tr(),
                      onPressedYes: () {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      });
                  break;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet, color: Colors.black87),
                backgroundColor: Colors.white10,
                title: Text('io'.tr(), style: TextStyle(color: Colors.black)),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today, color: Colors.black87),
                backgroundColor: Colors.white10,
                title: Text('date'.tr(), style: TextStyle(color: Colors.black)),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart, color: Colors.black87),
                backgroundColor: Colors.white10,
                title:
                    Text('chart'.tr(), style: TextStyle(color: Colors.black)),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.block, color: Colors.black87),
                backgroundColor: Colors.white10,
                title:
                    Text('logout'.tr(), style: TextStyle(color: Colors.black)),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.close, color: Colors.black87),
                backgroundColor: Colors.white10,
                title:
                    Text('close'.tr(), style: TextStyle(color: Colors.black)),
              )
            ],
          ),
          body: Column(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 5.7,
                  color: Colors.green,
                  child: Column(children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Avater(imageUrl),
                            UserInfo(name, mobile),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isChecked = !isChecked;
                                  if (context.locale
                                      .toString()
                                      .contains('en_US')) {
                                    context.locale = Locale('bn', 'BD');
                                  } else {
                                    context.locale = Locale('en', 'US');
                                  }
                                });
                              },
                              child: Text(
                                'ln'.tr(),
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            IconButton(
                              onPressed: () {
                                Route route = MaterialPageRoute(
                                    builder: (context) => ProfileUpdate());
                                Navigator.push(context, route);
                              },
                              icon: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        )
                      ],
                    ),
                  ])),
              walletTop(_amount, _cashIn, _cashOut, isChecked, context),
              walletTab(tabIndex),
              walletPost(tabIndex, list),
            ],
          ),
          // floatingActionButton: FabCircularMenu(
          //     fabColor: Colors.black12,
          //     ringColor: Colors.pink,
          //     ringWidth: 60,
          //     ringDiameter: 300,
          //     fabElevation: 0.0,
          //     children: <Widget>[
          //       IconButton(
          //           icon: Icon(
          //             Icons.settings_power,
          //             color: Colors.white,
          //           ),
          //           onPressed: () {
          //             SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          //           }),
          //       IconButton(
          //           icon: Icon(
          //             Icons.settings_backup_restore,
          //             color: Colors.white,
          //           ),
          //           onPressed: () {
          //             try {
          //               sp.clear();
          //               Navigator.pop(context);
          //             } catch (e) {
          //               print(e);
          //             }
          //           }),
          //       IconButton(
          //           icon: Icon(
          //             Icons.insert_chart,
          //             color: Colors.white,
          //           ),
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(builder: (context) => Chart()),
          //             );
          //           }),
          //       IconButton(
          //         onPressed: () {
          //           Route route =
          //               MaterialPageRoute(builder: (context) => ProfileUpdate());
          //           Navigator.push(context, route);
          //         },
          //         icon: Icon(
          //           Icons.person,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ])
        ));
  }

  Widget walletTab(tabIndex) => DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            TabBar(
              indicatorColor: Colors.green,
              onTap: (index) {
                setState(() {
                  this.tabIndex = index;
                });
              },
              tabs: <Widget>[
                Tab(
                  child: Text(
                    'statement',
                    style: TextStyle(color: Colors.black),
                  ).tr(),
                ),
                Tab(
                  child: Text(
                    'cashin'.tr(),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    'cashout'.tr(),
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ],
        ),
      );

  Widget walletPost(tabIndex, key) => Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 2.0,
                  child: (tabIndex != 0)
                      ? tabIndex != 2
                          ? StreamBuilder(
                              stream: Firestore.instance
                                  .collection('post')
                                  .where("cashtype", isEqualTo: 'IN')
                                  .where("mobile", isEqualTo: "$mobile")
                                  .where('date',
                                      isGreaterThanOrEqualTo: fd.toString())
                                  .where('date',
                                      isLessThanOrEqualTo: ld.toString())
                                  .orderBy('date', descending: true)
                                  //.orderBy("postingdate", descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return Center(
                                    child: Text("data".tr()),
                                  );
                                } else {
                                  return ListView.builder(
                                      itemCount:
                                          snapshot.data.documents.length != null
                                              ? snapshot.data.documents.length
                                              : 0,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        DocumentSnapshot data =
                                            snapshot.data.documents[index];
                                        return data['mobile'] != mobile
                                            ? null
                                            : post(data, context);
                                      });
                                }
                              },
                            )
                          : StreamBuilder(
                              stream: Firestore.instance
                                  .collection('post')
                                  .where('cashtype', isEqualTo: 'OUT')
                                  .where("mobile", isEqualTo: "$mobile")
                                  .where('date',
                                      isGreaterThanOrEqualTo: fd.toString())
                                  .where('date',
                                      isLessThanOrEqualTo: ld.toString())
                                  .orderBy('date', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return Center(
                                    child: Text("data".tr()),
                                  );
                                } else {
                                  return ListView.builder(
                                      itemCount:
                                          snapshot.data.documents.length != null
                                              ? snapshot.data.documents.length
                                              : 0,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        DocumentSnapshot data =
                                            snapshot.data.documents[index];
                                        return data['mobile'] != mobile
                                            ? null
                                            : post(data, context);
                                      });
                                }
                              },
                            )
                      : StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance
                              .collection('post')
                              .where("mobile", isEqualTo: "$mobile")
                              .where('date',
                                  isGreaterThanOrEqualTo: fd.toString())
                              .where('date', isLessThanOrEqualTo: ld.toString())
                              .orderBy('date', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Center(
                                child: Text("data").tr(),
                              );
                            } else {
                              return ListView.builder(
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    DocumentSnapshot data =
                                        snapshot.data.documents[index];
                                    return data['mobile'] != mobile
                                        ? null
                                        : post(data, context);
                                  });
                            }
                          }))),
        ],
      );
}

Widget post(values, context) => Card(
      elevation: 1,
      child: InkWell(
          onDoubleTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateCash(id: values.documentID)),
            );
          },
          onLongPress: () async {
            if (await ConnectionVerify.connectionStatus()) {
              Firestore.instance
                  .collection("post")
                  .document(values.documentID)
                  .delete();
              Fluttertoast.showToast(
                  msg: "remove".tr(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.pink,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "connection_notify2".tr(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.pink,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
          child: Container(
              padding: EdgeInsets.only(bottom: 5),
              color: Colors.white70,
              width: double.infinity,
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  values['cashtype'] != 'OUT'
                      ? Lottie.asset('images/add.json', width: 50, height: 50)
                      // Image.asset(
                      //   'images/save.jpg',
                      //   height: 50,
                      //   fit: BoxFit.fill,
                      // ),
                      : Lottie.asset('images/minus.json',
                          width: 45, height: 45),
                  // CircleAvatar(
                  //     backgroundColor: Colors.grey[100],
                  //     child: Image.asset(
                  //       'images/minus.jpg',
                  //       height: 50,
                  //       fit: BoxFit.fill,
                  //     ),
                  //     radius: 25.0,
                  //   ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        values['purpose'].toString(),
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        Jiffy(values['date']).yMMMMd,
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      values['cashtype'] != 'IN'
                          ? Text(
                              values['amount'] + '\ ৳',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.pink),
                            )
                          : Text(
                              values['amount'] + '\ ৳',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.green),
                            ),
                    ],
                  )),
                  SizedBox(
                    width: 15,
                  )
                ],
              ))),
    );
Widget walletTop(amount, cashIn, cashOut, isChecked, context) => Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 5,
      color: Colors.green,
      child: Column(
        children: <Widget>[
          balance(amount),
          SizedBox(
            height: 30,
          ),
          inOut(cashIn, cashOut),
        ],
      ),
    );

class inOut extends StatelessWidget {
  double cashIn, cashOut;
  inOut(this.cashIn, this.cashOut);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '+ $cashIn ৳',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Text(
              'cashin'.tr(),
              style: TextStyle(fontSize: 10, color: Colors.white60),
            ),
          ],
        )),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '- $cashOut ৳',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            Text(
              'cashout'.tr(),
              style: TextStyle(fontSize: 10, color: Colors.white60),
            ),
          ],
        )),
      ],
    );
  }
}

class balance extends StatelessWidget {
  double amount;
  balance(this.amount);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            '$amount ৳',
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
          Text(
            'balance'.tr(),
            style: TextStyle(fontSize: 10, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  String name;
  String mobile;
  UserInfo(this.name, this.mobile);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$name',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            '$mobile',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

Widget Avater(imageUrl) => AvatarGlow(
      endRadius: 60.0,
      duration: Duration(milliseconds: 2000),
      repeat: true,
      showTwoGlows: true,
      repeatPauseDuration: Duration(milliseconds: 100),
      child: Material(
        elevation: 8.0,
        shape: CircleBorder(),
        child: ClipOval(
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  'https://cdn4.iconfinder.com/data/icons/avatars-21/512/avatar-circle-human-female-black-7-512.png',
                  height: 60,
                  width: 60,
                  fit: BoxFit.fill,
                ),
        ),
      ),
    );

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
