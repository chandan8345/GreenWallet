import 'package:easy_localization/easy_localization.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/pages/cash.dart';
import 'package:wallet/pages/chart.dart';
import 'package:wallet/pages/updateCash.dart';

int index;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name, mobile, imageUrl;
  double _amount = 0.0, _cashIn = 0.0, _cashOut = 0.0;
  int tabIndex = 0;
  List list;
  SharedPreferences sp;
  final db = Firestore.instance;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    getUser();
    dashboard();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getUser() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      this.name = sp.getString('name');
      this.mobile = sp.getString('mobile');
      this.imageUrl = sp.getString('imgurl');
    });
  }

  void dashboard() async {
    if (await ConnectionVerify.connectionStatus()) {
      db
          .collection('post')
          .where('cashtype', isEqualTo: 'IN')
          .where('mobile', isEqualTo: mobile)
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
      });
    } else {
      toast("Network Connection Lost");
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
    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 5.8,
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
                          // CustomSwitchButton(
                          //   backgroundColor: Colors.white,
                          //   unCheckedColor: Colors.pink,
                          //   animationDuration: Duration(milliseconds: 100),
                          //   buttonHeight: 25,
                          //   checkedColor: Colors.green,
                          //   checked: isChecked,
                          // ),
                          SizedBox(
                            width: 25,
                          )
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
        floatingActionButton: FabCircularMenu(
            fabColor: Colors.black12,
            ringColor: Colors.pink,
            ringWidth: 60,
            ringDiameter: 300,
            fabElevation: 0.0,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.settings_power,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  }),
              IconButton(
                  icon: Icon(
                    Icons.settings_backup_restore,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    try{
                    sp.clear();
                    Navigator.pop(context);
                    }catch(e){
                      print(e);
                    }
                  }),
              IconButton(
                  icon: Icon(
                    Icons.insert_chart,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Chart()),
                    );
                  }),
              IconButton(
                  icon: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CashIn(
                                value: _amount,
                              )),
                    );
                  }),
            ]));
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
                  height: MediaQuery.of(context).size.height / 1.8,
                  child: (tabIndex != 0)
                      ? tabIndex != 2
                          ? StreamBuilder(
                              stream: Firestore.instance
                                  .collection('post')
                                  .where("cashtype", isEqualTo: 'IN')
                                  .where("mobile", isEqualTo: mobile)
                                  .orderBy("postingdate", descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.data == null){
                                  return Center(
                                    child:Text("Data Not Found"),
                                  );}else{
                                return ListView.builder(
                                    itemCount:
                                        snapshot.data.documents.length != null
                                            ? snapshot.data.documents.length
                                            : 0,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      DocumentSnapshot data =
                                          snapshot.data.documents[index];
                                      return post(data, context);
                                    });}
                              },
                            )
                          : StreamBuilder(
                              stream: Firestore.instance
                                  .collection('post')
                                  .where('cashtype', isEqualTo: 'OUT')
                                  .where("mobile", isEqualTo: mobile)
                                  .orderBy("postingdate", descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.data == null){
                                  return Center(
                                    child: Text("Data Not Found"),
                                  );}else{
                                    return ListView.builder(
                                    itemCount:
                                        snapshot.data.documents.length != null
                                            ? snapshot.data.documents.length
                                            : 0,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      DocumentSnapshot data =
                                          snapshot.data.documents[index];
                                      return post(data, context);
                                    });
                                  }
                              },
                            )
                      : StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance
                              .collection('post')
                              .where("mobile", isEqualTo: mobile)
                              .orderBy("postingdate", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data == null){
                              return Center(
                                child:Text("Data Not Found"),
                              );}else{
                                return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  DocumentSnapshot data =
                                      snapshot.data.documents[index];
                                  return post(data, context);
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
            Navigator.push(
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
                  msg: "Remove Successfuly",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.pink,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "Network Conncetion Lost",
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
                      ? CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: Image.asset(
                            'images/save.jpg',
                            height: 50,
                            fit: BoxFit.fill,
                          ),
                          radius: 25.0,
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: Image.asset(
                            'images/minus.jpg',
                            height: 50,
                            fit: BoxFit.fill,
                          ),
                          radius: 25.0,
                        ),
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
                              values['amount'] + '\৳',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.pink),
                            )
                          : Text(
                              values['amount'] + '\৳',
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
              '+ $cashIn৳',
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
              '- $cashOut৳',
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
            '$amount৳',
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
