import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiffy/jiffy.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class Chart extends StatefulWidget {
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  bool toggle = false;
  SharedPreferences sp;
  String mobile;
  Map<String, double> dataMap1 = Map();
  Map<String, double> dataMap2 = Map();
  Map<String, double> dataMap3 = Map();
  List<Color> colorList = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.blueGrey,
    Colors.lightBlue,
    Colors.lime,
    Colors.teal,
    Colors.purple,
    Colors.indigo,
    Colors.orange
  ];
  final db = Firestore.instance;
  dynamic a;
  DateTime firstDate, lastDate, fd, ld;
  int fy, ly;

  @override
  void initState() {
    super.initState();
    getUser();
    range();
    all();
  }

  void all() {
    dataMap1.putIfAbsent("IN | OUT", () => 0);
    dashboard();
    dataMap2.putIfAbsent("CASH IN", () => 0);
    incoming("Salary");
    incoming("Business");
    incoming("Savings");
    incoming("Loan");
    incoming("Investment");
    incoming("Insurance");
    incoming("Bonus");
    incoming("Pension");
    incoming("Lottery");
    incoming("Stipend");
    incoming("Broker");
    incoming("Others");
    dataMap3.putIfAbsent("CASH OUT", () => 0);
    out("Food");
    out("Shopping");
    out("House Rent");
    out("Talk Time");
    out("Gifts");
    out("Electricity");
    out("Gas");
    out("Water");
    out("Internet");
    out("Loundry");
    out("Installment");
    out("Entertainment");
    out("Fuel");
    out("Medical");
    out("Education");
    out("Transport");
    out("Travel");
    out("Tax");
    out("Others");
  }

  Future<void> getUser() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      this.mobile = sp.getString('mobile');
    });
  }

  range() {
    DateTime now = DateTime.now();
    setState(() {
      this.firstDate = DateTime.parse("2020-01-01 01:01:01");
      this.lastDate = now;
      this.fd = firstDate;
      this.ld = lastDate;
      this.fy = DateTime.now().year;
      this.ly = DateTime.now().year + 1;
    });
  }

  void dashboard() async {
    double cashin, cashout, balance;
    if (await ConnectionVerify.connectionStatus()) {
      db
          .collection('post')
          .where('cashtype', isEqualTo: 'IN')
          .where('mobile', isEqualTo: mobile)
          .where('date', isGreaterThanOrEqualTo: fd.toString())
          .where('date', isLessThanOrEqualTo: ld.toString())
          .snapshots()
          .listen((snapshot) {
        cashin = 0.0;
        snapshot.documents.forEach((doc) {
          setState(() {
            cashin += double.parse(doc.data['amount']);
          });
        });
        dataMap1.putIfAbsent("Cash In", () => cashin > 0 ? cashin / 1000 : 0);
        db
            .collection('post')
            .where('cashtype', isEqualTo: 'OUT')
            .where('mobile', isEqualTo: mobile)
            .where('date', isGreaterThanOrEqualTo: fd.toString())
            .where('date', isLessThanOrEqualTo: ld.toString())
            .snapshots()
            .listen((snapshot) {
          cashout = 0.0;
          snapshot.documents.forEach((doc) {
            setState(() {
              cashout += double.parse(doc.data['amount']);
            });
          });
          dataMap1.putIfAbsent(
              "Cash Out", () => cashout > 0 ? cashout / 1000 : 0);
          setState(() {
            balance = cashin - cashout;
          });
          dataMap1.putIfAbsent(
              "Balance", () => balance > 0 ? balance / 1000 : 0);
        });
      });
    }
  }

  void incoming(purpose) async {
    double i;
    if (await ConnectionVerify.connectionStatus()) {
      db
          .collection('post')
          .where('purpose', isEqualTo: purpose)
          .where('mobile', isEqualTo: mobile)
          .where('date', isGreaterThanOrEqualTo: fd.toString())
          .where('date', isLessThanOrEqualTo: ld.toString())
          .snapshots()
          .listen((snapshot) {
        i = 0.0;
        snapshot.documents.forEach((doc) {
          setState(() {
            i += double.parse(doc.data['amount']);
          });
          dataMap2.putIfAbsent(purpose, () => i > 0 ? i / 1000 : 0);
        });
      });
    }
  }

  void out(purpose) async {
    double i;
    if (await ConnectionVerify.connectionStatus()) {
      db
          .collection('post')
          .where('purpose', isEqualTo: purpose)
          .where('mobile', isEqualTo: mobile)
          .where('date', isGreaterThanOrEqualTo: fd.toString())
          .where('date', isLessThanOrEqualTo: ld.toString())
          .snapshots()
          .listen((snapshot) {
        i = 0.0;
        snapshot.documents.forEach((doc) {
          setState(() {
            i += double.parse(doc.data['amount']);
          });
          dataMap3.putIfAbsent(purpose, () => i > 0 ? i / 1000 : 0);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chart'.tr()),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              final List<DateTime> picked = await DateRagePicker.showDatePicker(
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
                all();
              }
            },
          )
        ],
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          PieChart(
            dataMap: dataMap1,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32.0,
            chartRadius: MediaQuery.of(context).size.width / 2.7,
            showChartValuesInPercentage: true,
            showChartValues: true,
            showChartValuesOutside: true,
            chartValueBackgroundColor: Colors.grey[200],
            colorList: colorList,
            showLegends: true,
            legendPosition: LegendPosition.right,
            decimalPlaces: 1,
            showChartValueLabel: true,
            initialAngle: 0,
            chartValueStyle: defaultChartValueStyle.copyWith(
              color: Colors.blueGrey[900].withOpacity(0.9),
            ),
            chartType: ChartType.disc,
          ),
          SizedBox(
            height: 50,
          ),
          PieChart(
            dataMap: dataMap2,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32.0,
            chartRadius: MediaQuery.of(context).size.width / 2.5,
            showChartValuesInPercentage: true,
            showChartValues: true,
            showChartValuesOutside: false,
            chartValueBackgroundColor: Colors.grey[200],
            colorList: colorList,
            showLegends: true,
            legendPosition: LegendPosition.right,
            decimalPlaces: 2,
            showChartValueLabel: true,
            initialAngle: 0,
            chartValueStyle: defaultChartValueStyle.copyWith(
              color: Colors.blueGrey[900].withOpacity(0.9),
            ),
            chartType: ChartType.ring,
          ),
          SizedBox(
            height: 50,
          ),
          PieChart(
            dataMap: dataMap3,
            animationDuration: Duration(milliseconds: 800),
            chartLegendSpacing: 32.0,
            chartRadius: MediaQuery.of(context).size.width / 2.5,
            showChartValuesInPercentage: true,
            showChartValues: true,
            showChartValuesOutside: false,
            chartValueBackgroundColor: Colors.grey[200],
            colorList: colorList,
            showLegends: true,
            legendPosition: LegendPosition.right,
            decimalPlaces: 1,
            showChartValueLabel: true,
            initialAngle: 0,
            chartValueStyle: defaultChartValueStyle.copyWith(
              color: Colors.blueGrey[900].withOpacity(0.9),
            ),
            chartType: ChartType.ring,
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.only(left:20,right:20),
            child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(Jiffy(fd).yMMMMd),
              Text("|"),
              Text(Jiffy(ld).yMMMMd),
            ],
          )
          )
        ],
      ),
    );
  }
}
