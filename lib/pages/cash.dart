import 'package:awesome_button/awesome_button.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fradio/fradio.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:wallet/pages/home.dart';

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
  TextEditingController amountCtrl=new TextEditingController();
  String mobile = "01762981976", amount, cashType = 'IN', inType='Salary', outType='Food';
  DateTime dateTime;ProgressDialog pr;
  DateTime _selectedDate;
  int _selectedValueIn = 0, _selectedValueOut = 0;
  final postData = FirebaseDatabase.instance.reference().child('post');

  @override
  void initState() {
    _resetSelectedDate();
    super.initState();
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

  void submit() {
    if (_formKey.currentState.validate()) {
    pr.update(message: 'Please Wait');
    pr.show();
      postData.push().set({
        'mobile': mobile,
        'cashtype': cashType,
        'amount': amount,
        'date': _selectedDate.toString(),
        'purpose': cashType != 'OUT' ? this.inType : this.outType,
      }).then((_) async {
        pr.update(message: 'Done !!!');
        pr.hide();
      });
    }
  }

  void reset() {
    setState(() {
      amountCtrl.text = '';
      inType = 'Salary';
      outType = 'Food';
    });
  }

  void _resetSelectedDate() {
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: true);
    return WillPopScope(
        onWillPop: () {
          return Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
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
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Home()));
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
              16,
              Colors.pink,
              "Salary"),
          CashOut(
              Icon(
                Icons.card_travel,
                size: 70,
              ),
              17,
              Colors.pink,
              "Business"),
          CashOut(
              Icon(
                Icons.save_alt,
                size: 70,
              ),
              18,
              Colors.pink,
              'Savings'),
          CashOut(
              Icon(
                Icons.invert_colors,
                size: 70,
              ),
              19,
              Colors.pink,
              'Investment'),
          CashOut(
              Icon(
                Icons.supervisor_account,
                size: 70,
              ),
              20,
              Colors.pink,
              'Insurance'),
          CashOut(
              Icon(
                Icons.mail_outline,
                size: 70,
              ),
              21,
              Colors.pink,
              'Bonus'),
          CashOut(
              Icon(
                Icons.airline_seat_recline_extra,
                size: 70,
              ),
              22,
              Colors.pink,
              'Pension'),
          CashOut(
              Icon(
                Icons.local_activity,
                size: 70,
              ),
              23,
              Colors.pink,
              'Lottery'),
          CashOut(
              Icon(
                Icons.streetview,
                size: 70,
              ),
              24,
              Colors.pink,
              'Stipend'),
          CashOut(
              Icon(
                Icons.sentiment_very_satisfied,
                size: 70,
              ),
              25,
              Colors.pink,
              'Broker'),
          CashOut(
              Icon(
                Icons.transfer_within_a_station,
                size: 70,
              ),
              26,
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
              'Gifts'),
          CashIn(
              Icon(
                Icons.lightbulb_outline,
                size: 70,
              ),
              3,
              Colors.green,
              'Electricity'),
          CashIn(
              Icon(
                Icons.games,
                size: 70,
              ),
              4,
              Colors.green,
              'Gas'),
          CashIn(
              Icon(
                Icons.opacity,
                size: 70,
              ),
              5,
              Colors.green,
              'Water'),
          CashIn(
              Icon(
                Icons.signal_wifi_4_bar,
                size: 70,
              ),
              6,
              Colors.green,
              'Internet'),
          CashIn(
              Icon(
                Icons.local_drink,
                size: 70,
              ),
              7,
              Colors.green,
              'Loundry'),
          CashIn(
              Icon(
                Icons.local_bar,
                size: 70,
              ),
              8,
              Colors.green,
              'Entertainment'),
          CashIn(
              Icon(
                Icons.local_gas_station,
                size: 70,
              ),
              9,
              Colors.green,
              'Fuel'),
          CashIn(
              Icon(
                Icons.hotel,
                size: 70,
              ),
              10,
              Colors.green,
              'Medical'),
          CashIn(
              Icon(
                Icons.local_library,
                size: 70,
              ),
              11,
              Colors.green,
              'Education'),
          CashIn(
              Icon(
                Icons.directions_car,
                size: 70,
              ),
              12,
              Colors.green,
              'Transport'),
          CashIn(
              Icon(
                Icons.flight,
                size: 70,
              ),
              13,
              Colors.green,
              'Travel'),
          CashIn(
              Icon(
                Icons.local_atm,
                size: 70,
              ),
              14,
              Colors.green,
              'Tax'),
          CashIn(
              Icon(
                Icons.bubble_chart,
                size: 70,
              ),
              15,
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
            return 'Amount cant be Zero';
          } 
          else if (double.parse(val) > value && cashType == 'OUT') {
            return '$val not to greater than $value';
          } else {
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