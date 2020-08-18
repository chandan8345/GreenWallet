import 'package:awesome_button/awesome_button.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection_verify/connection_verify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fradio/fradio.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashIn extends StatefulWidget {
  double value;
  CashIn({this.value, Key key}) : super(key: key);
  @override
  _CashInState createState() => _CashInState(value);
}

class _CashInState extends State<CashIn> {
  _CashInState(this.value);
  double value;
  final _formKey = GlobalKey<FormState>();
  double _cashIn = 0.0, _cashOut = 0.0;
  TextEditingController amountCtrl = new TextEditingController();
  String mobile,
      amount,
      cashType = 'IN',
      inType = 'Salary',
      outType = 'Food';
  DateTime dateTime;
  ProgressDialog pr;
  DateTime _selectedDate;
  final db = Firestore.instance;SharedPreferences sp;
  int _selectedValueIn = 0, _selectedValueOut = 0;

  @override
  void initState() {
    getUser();
    _resetSelectedDate();
    dashboard();
    super.initState();
  }

    Future<void> getUser() async {
    sp = await SharedPreferences.getInstance();
    setState(() {
      this.mobile = sp.getString('mobile');
    });
  }

  void stateOut(value) {
    setState(() {
      this.outType = value;
    });
    print(outType);
  }

  void stateIn(value) {
    setState(() {
      this.inType = value;
    });
  }

  Future<void> submit() async {
    if (_formKey.currentState.validate()) {
      if (await ConnectionVerify.connectionStatus()) {
        pr.update(message: 'Please Wait');
        pr.show();
        await db.collection("post").add({
          'mobile': mobile,
          'cashtype': cashType,
          'amount': amount,
          'date': _selectedDate.toString(),
          'purpose': cashType != 'OUT' ? this.inType : this.outType,
          'postingdate':DateTime.now().toString()
        });
        pr.hide();
        toast("Saved Successfuly");
        reset();
      } else {
        toast("Network Connection Lost");
      }
    }
  }

  void dashboard() async {
    if (await ConnectionVerify.connectionStatus()) {
      db
          .collection('post')
          .where('cashtype', isEqualTo: 'IN')
          .where('mobile', isEqualTo: mobile)
          .snapshots()
          .listen((snapshot) {
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
          snapshot.documents.forEach((doc) {
            setState(() {
              this._cashOut += double.parse(doc.data['amount']);
            });
          });
          setState(() {
            this.value = _cashIn - _cashOut;
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

  void reset() {
    setState(() {
      amountCtrl.text = '';
      inType = 'Salary';
      cashType = 'IN';
      outType = 'Food';
      _resetSelectedDate();
    });
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true);
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text('CASH IN-OUT'),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  reset();
                },
                icon: Icon(Icons.replay),
              )
            ],
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: ListView(
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      money(),
                      SizedBox(
                        height: 25,
                      ),
                      cashtype(),
                      SizedBox(
                        height: 15,
                      ),
                      cashType != "OUT" ? cashRadio1() : cashRadio2(),
                      SizedBox(
                        height: 15,
                      ),
                      calender(),
                      SizedBox(height: 40),
                      SubmitBtn()
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget SubmitBtn() => AwesomeButton(
        blurRadius: 5.0,
        splashColor: Color.fromRGBO(255, 255, 255, .4),
        borderRadius: BorderRadius.circular(0.0),
        height: 60.0,
        width: double.infinity,
        onTap: () => submit(),
        color: Colors.green,
        child: Text(
          "Save",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      );

  Widget cashRadio1() => Container(
      padding: EdgeInsets.only(top: 15, right: 0),
      height: 110.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          CashOut(
              Icon(
                Icons.account_balance_wallet,
                size: 70,
              ),
              18,
              Colors.pink,
              "Salary"),
          CashOut(
              Icon(
                Icons.card_travel,
                size: 70,
              ),
              19,
              Colors.pink,
              "Business"),
          CashOut(
              Icon(
                Icons.save_alt,
                size: 70,
              ),
              20,
              Colors.pink,
              'Savings'),
          CashOut(
              Icon(
                Icons.monetization_on,
                size: 70,
              ),
              21,
              Colors.pink,
              'Loan'),
          CashOut(
              Icon(
                Icons.invert_colors,
                size: 70,
              ),
              22,
              Colors.pink,
              'Investment'),
          CashOut(
              Icon(
                Icons.supervisor_account,
                size: 70,
              ),
              23,
              Colors.pink,
              'Insurance'),
          CashOut(
              Icon(
                Icons.mail_outline,
                size: 70,
              ),
              24,
              Colors.pink,
              'Bonus'),
          CashOut(
              Icon(
                Icons.airline_seat_recline_extra,
                size: 70,
              ),
              25,
              Colors.pink,
              'Pension'),
          CashOut(
              Icon(
                Icons.local_activity,
                size: 70,
              ),
              26,
              Colors.pink,
              'Lottery'),
          CashOut(
              Icon(
                Icons.streetview,
                size: 70,
              ),
              27,
              Colors.pink,
              'Stipend'),
          CashOut(
              Icon(
                Icons.sentiment_very_satisfied,
                size: 70,
              ),
              28,
              Colors.pink,
              'Broker'),
          CashOut(
              Icon(
                Icons.transfer_within_a_station,
                size: 70,
              ),
              29,
              Colors.pink,
              'Others'),
        ],
      ));

  Widget cashRadio2() => Container(
      padding: EdgeInsets.only(top: 15, right: 15),
      height: 110.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          CashIn(
              Icon(
                Icons.fastfood,
                size: 70,
              ),
              0,
              Colors.green,
              'Food'),
          CashIn(
              Icon(
                Icons.shopping_cart,
                size: 70,
              ),
              1,
              Colors.green,
              'Shopping'),
          CashIn(
              Icon(
                Icons.card_giftcard,
                size: 70,
              ),
              2,
              Colors.green,
              'Talk Time'),
          CashIn(
              Icon(
                Icons.card_giftcard,
                size: 70,
              ),
              3,
              Colors.green,
              'Gifts'),
          CashIn(
              Icon(
                Icons.lightbulb_outline,
                size: 70,
              ),
              4,
              Colors.green,
              'Electricity'),
          CashIn(
              Icon(
                Icons.games,
                size: 70,
              ),
              5,
              Colors.green,
              'Gas'),
          CashIn(
              Icon(
                Icons.opacity,
                size: 70,
              ),
              6,
              Colors.green,
              'Water'),
          CashIn(
              Icon(
                Icons.signal_wifi_4_bar,
                size: 70,
              ),
              7,
              Colors.green,
              'Internet'),
          CashIn(
              Icon(
                Icons.local_drink,
                size: 70,
              ),
            8,
              Colors.green,
              'Loundry'),
          CashIn(
              Icon(
                Icons.credit_card,
                size: 70,
              ),
              9,
              Colors.green,
              'Installment'),
          CashIn(
              Icon(
                Icons.local_bar,
                size: 70,
              ),
              10,
              Colors.green,
              'Entertainment'),
          CashIn(
              Icon(
                Icons.local_gas_station,
                size: 70,
              ),
              11,
              Colors.green,
              'Fuel'),
          CashIn(
              Icon(
                Icons.hotel,
                size: 70,
              ),
              12,
              Colors.green,
              'Medical'),
          CashIn(
              Icon(
                Icons.local_library,
                size: 70,
              ),
              13,
              Colors.green,
              'Education'),
          CashIn(
              Icon(
                Icons.directions_car,
                size: 70,
              ),
              14,
              Colors.green,
              'Transport'),
          CashIn(
              Icon(
                Icons.flight,
                size: 70,
              ),
              15,
              Colors.green,
              'Travel'),
          CashIn(
              Icon(
                Icons.local_atm,
                size: 70,
              ),
              16,
              Colors.green,
              'Tax'),
          CashIn(
              Icon(
                Icons.bubble_chart,
                size: 70,
              ),
              17,
              Colors.green,
              'Others'),
        ],
      ));

  Widget money() => TextFormField(
        controller: amountCtrl,
        decoration: new InputDecoration(
          labelText: 'Amount',
          fillColor: Colors.white,
          //icon: Icon(Icons.border_color),
          hintText: '',
          border: OutlineInputBorder(),
          //fillColor: Colors.green
        ),
        validator: (val) {
          if (val.isEmpty) {
            return cashType!="OUT"?'Money in amount cant be empty':'Money out amount cant be empty';
          } else if (double.parse(val) > value && cashType == 'OUT') {
            return cashType!="OUT"?'Money in':'Money out' +' amount $val greater than Balance $value';
          }else if(double.parse(val) == 0.0){
            return cashType!="OUT"?'Money in amount cant be empty':'Money out amout cant be Zero';
          }
           else {
            return null;
          }
        },
        keyboardType: TextInputType.number,
        style: new TextStyle(
          fontFamily: "Poppins",
        ),
        onSaved: (String val) {
          this.amount = val;
        },
        onChanged: (String val) {
          setState(() {
            this.amount = val;
          });
        },
      );

  Widget cashtype() => Row(
        children: <Widget>[
          FRadio(
            selectedColor: Colors.green,
            value: 'IN',
            groupValue: cashType,
            onChanged: (value) {
              setState(() {
                cashType = value;
              });
            },
          ),
          Text(' CASH IN'),
          SizedBox(
            width: 20,
          ),
          FRadio(
            selectedColor: Colors.pink,
            value: 'OUT',
            groupValue: cashType,
            onChanged: (value) {
              setState(() {
                cashType = value;
              });
            },
          ),
          Text(' CASH OUT'),
        ],
      );

  Widget calender() => CalendarTimeline(
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year, 1, 1),
      lastDate: DateTime.now(), //.add(Duration(days: 365)),
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
      leftMargin: 0,
      monthColor: Colors.green,
      dayColor: Colors.pink,
      dayNameColor: Color(0xFF333A47),
      activeDayColor: Colors.white,
      activeBackgroundDayColor: Colors.green[205],
      dotsColor: Color(0xFF333A47),
      selectableDayPredicate: (date) => date.day != 32,
      locale: 'en_US');

  Widget CashIn(icon, index, color, value) {
    return OutlineButton(
      onPressed: () {
        stateOut(value);
        setState(() {
          _selectedValueIn = index;
        });
      },
      borderSide: BorderSide(
          color: _selectedValueIn == index ? color : Colors.transparent,
          width: 2),
      child: Container(
          width: 90,
          height: 100,
          child: Center(
            child: Column(
              children: <Widget>[
                icon,
                Text(value,
                    style: TextStyle(
                      color: color,
                    ))
              ],
            ),
          )),
    );
  }

  Widget CashOut(icon, index, color, value) {
    return OutlineButton(
      onPressed: () {
        stateIn(value);
        setState(() {
          _selectedValueOut = index;
        });
      },
      borderSide: BorderSide(
          color: _selectedValueOut == index ? color : Colors.transparent,
          width: 2),
      child: Container(
          width: 90,
          height: 100,
          child: Center(
            child: Column(
              children: <Widget>[
                icon,
                Text(value,
                    style: TextStyle(
                      color: color,
                    ))
              ],
            ),
          )),
    );
  }
}
