import 'package:flutter/material.dart';
import 'package:wallet/pages/log.dart';
import 'package:wallet/pages/register.dart';
import 'util.dart';

class Membership extends StatefulWidget {
  Membership({Key key}) : super(key: key);

  _MembershipState createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  int log=0;var user;

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.1,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 8,
                child: Image.asset('images/save.jpg'),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Text(
                      'G R E E N  W A L L E T',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.green),
                    ),
                    SizedBox(height: 5),
                    // Text(
                    //   'Counseling Management System',
                    //   style: TextStyle(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.w400,
                    //       color: Colors.green),
                    // ),
                    SizedBox(height: 15),
                    Text(
                      "Virtual Wallet is Checking & Savings together. A high interest savings, a short-term savings, and checking account, paired with our digital money",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'thoma'),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    log == 0? login():SizedBox(),
                    log == 0? width():SizedBox(),
                    log == 0? register():SizedBox(),
                    ///if (log != 0) Welcome(),
                ],
                )
              ),

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
  Widget login()=>RaisedButton(
    onPressed: () {
      Route route=MaterialPageRoute(builder: (context) => Log());
      Navigator.pushReplacement(context, route);
    },
    textColor: Colors.white,
    padding: const EdgeInsets.all(0.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Container(
      width: MediaQuery.of(context).size.width / 2.3,
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
        child: const Text(
          'Login',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    ),
  );
  
  Widget register()=>RaisedButton(
    onPressed: () {
      Route route=MaterialPageRoute(builder: (context) => Register());
      Navigator.pushReplacement(context, route);
    },
    textColor: Colors.white,
    padding: const EdgeInsets.all(0.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Container(
      width: MediaQuery.of(context).size.width / 2.3,
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.pinkAccent,
            Colors.pink,
//                              CustomColors.GreenLight,
//                              CustomColors.GreenDark,
          ],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColors.PurpleShadow,
            blurRadius: 15.0,
            spreadRadius: 7.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Center(
        child: const Text(
          'Register',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    ),
  );
  
  Widget width()=>SizedBox(
    width: 10,
  );
}