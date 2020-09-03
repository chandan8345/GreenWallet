import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/pages/home.dart';
import 'package:wallet/pages/membership.dart';
import 'package:easy_localization/easy_localization.dart';
import 'util.dart';

class Onboarding extends StatefulWidget {
  Onboarding({Key key}) : super(key: key);
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int log = 1;
  SharedPreferences sp;
  String name;

  @override
  void initState() {
    super.initState();
  }

  void go() async {
    sp = await SharedPreferences.getInstance();
    name = sp.getString('name');
    name == null ? memberShip() : homE();
    print(name);
  }

  homE() {
    Route route = MaterialPageRoute(builder: (context) => Home());
    Navigator.push(context, route);
  }

  memberShip() {
    Route route = MaterialPageRoute(builder: (context) => Membership());
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Image.asset('images/save.jpg'),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Text(
                      'appname'.tr(),
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "details".tr(),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'opensans'),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Row(
                children: <Widget>[
                  log != 0 ? welcome(context) : SizedBox(),
                ],
              )),
              Expanded(
                flex: 1,
                child: Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget welcome(context) => RaisedButton(
        onPressed: () {
          go();
        },
        textColor: Colors.white,
        padding: const EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          height: 60,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                CustomColors.GreenLight,
                CustomColors.GreenDark,
              ],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            boxShadow: [
              BoxShadow(
                color: CustomColors.GreenShadow,
                blurRadius: 15.0,
                spreadRadius: 7.0,
                offset: Offset(0.0, 0.0),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Center(
            child: Text(
              'lets'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
}
