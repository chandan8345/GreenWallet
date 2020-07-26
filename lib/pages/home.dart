import 'package:avatar_glow/avatar_glow.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/pages/cash.dart';

int index;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String name, mobile, imageUrl;
  double amount = 0.0, cashIn = 0.0, cashOut = 0.0;
  int tabIndex = 0;
  Map<dynamic, dynamic> statement, cashin, cashout;
  List list;
  SharedPreferences sp;
  final postData = FirebaseDatabase.instance.reference().child('post');

  @override
  void initState() {
    getUser();
    getData();
    super.initState();
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
      this.imageUrl = sp.getString('image');
    });
  }

  void getData() {
    postData.once().then((DataSnapshot data) {
      setState(() {
        this.statement = data.value;
      });
    });
    var cashinQuery = postData.orderByChild('cashtype').equalTo("IN");
    cashinQuery.once().then((DataSnapshot data) {
      setState(() {
        this.cashin = data.value;
      });
      cashin != null
          ? cashin.forEach((key, value) {
              setState(() {
                this.cashIn += double.parse(cashin[key]['amount']);
              });
            })
          : this.cashIn = 0.0;
    });
    var cashOutQuery = postData.orderByChild('cashtype').equalTo("OUT");
    cashOutQuery.once().then((DataSnapshot data) {
      setState(() {
        this.cashout = data.value;
      });
      cashout != null
          ? cashout.forEach((key, value) {
              setState(() {
                this.cashOut += double.parse(cashout[key]['amount']);
              });
            })
          : this.cashOut = 0.0;
      setState(() {
        double a = cashOut != 0.0 || cashIn != 0.0 ? cashIn - cashOut : cashIn;
        this.amount = a;
      });
    });
  }

  void getUpdate() {
    postData.once().then((DataSnapshot data) {
      setState(() {
        this.statement = data.value;
      });
    });
    var cashinQuery = postData.orderByChild('cashtype').equalTo("IN");
    cashinQuery.once().then((DataSnapshot data) {
      setState(() {
        this.cashin = data.value;
      });
    });
    var cashOutQuery = postData.orderByChild('cashtype').equalTo("OUT");
    cashOutQuery.once().then((DataSnapshot data) {
      setState(() {
        this.cashout = data.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: <Widget>[
            walletTop(name, mobile, imageUrl, amount, cashIn, cashOut,context),
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
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CashIn(
                                value: amount,
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
                getUpdate();
              },
              tabs: <Widget>[
                Tab(
                  child: Text(
                    'STATEMENTS',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    'CASH IN',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    'CASH OUT',
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
                          ? ListView.builder(
                              itemCount: cashin != null ? cashin.length : 0,
                              itemBuilder: (BuildContext ctxt, int index) {
                                key = cashin.keys.elementAt(index);
                                return post(cashin, key);
                              })
                          : ListView.builder(
                              itemCount: cashout != null ? cashout.length : 0,
                              itemBuilder: (BuildContext ctxt, int index) {
                                key = cashout.keys.elementAt(index);
                                return post(cashout, key);
                              })
                      : ListView.builder(
                          itemCount: statement != null ? statement.length : 0,
                          itemBuilder: (BuildContext ctxt, int index) {
                            key = statement.keys.elementAt(index);
                            return post(statement, key);
                          }))),
        ],
      );
}

Widget post(values, key) => Card(
      elevation: 1,
      child: InkWell(
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
                  values[key]['cashtype'] != 'OUT'
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
                        values[key]['purpose'].toString(),
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        Jiffy(values[key]['date']).yMMMMd,
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
                      values[key]['cashtype'] != 'IN'
                          ? Text(
                              values[key]['amount'] + '\৳',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.pink),
                            )
                          : Text(
                              values[key]['amount'] + '\৳',
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
Widget walletTop(name, mobile, imageUrl, amount, cashIn, cashOut,context) => Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2.6,
      color: Colors.green,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              avater(imageUrl),
              UserInfo(name, mobile),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Balance(amount),
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
              'CASH IN',
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
              'CASH OUT',
              style: TextStyle(fontSize: 10, color: Colors.white60),
            ),
          ],
        )),
      ],
    );
  }
}

class Balance extends StatelessWidget {
  double amount;
  Balance(this.amount);
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
            'B A L A N C E',
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

Widget avater(imageUrl) => AvatarGlow(
      endRadius: 60.0,
      duration: Duration(milliseconds: 2000),
      repeat: true,
      showTwoGlows: true,
      repeatPauseDuration: Duration(milliseconds: 100),
      child: Material(
        elevation: 8.0,
        shape: CircleBorder(),
        child: CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: imageUrl != null
              ? Image.network(imageUrl)
              : Image.network(
                  'https://cdn4.iconfinder.com/data/icons/avatars-21/512/avatar-circle-human-female-black-7-512.png',
                  height: 55,
                  fit: BoxFit.fill,
                ),
          radius: 25.0,
        ),
      ),
    );
