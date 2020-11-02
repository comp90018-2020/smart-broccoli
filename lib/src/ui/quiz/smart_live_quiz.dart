import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/data.dart';
import 'package:smart_broccoli/src/models.dart';
import 'package:smart_broccoli/src/ui/shared/quiz_container.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';
import 'quiz_pin_box.dart';
import 'package:weekday_selector/weekday_selector.dart';

/// Smart quiz page
class SmartQuiz extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SmartQuizState();
}

class _SmartQuizState extends State<SmartQuiz> {
  final values = List.filled(7, true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: "Smart Live Quiz",
      hasDrawer: true,
      secondaryBackgroundColour: true,
      child: ListView(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 5),
          child: Text("General Setting",
              style: TextStyle(color: Colors.white), textAlign: TextAlign.left),
        ),
        minWin(),
        Divider(height: 0.4, color: Colors.grey),
        maxNotifications(),
        Divider(height: 0.2, color: Colors.grey),
        weekday(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 5),
          child: Text("Days of week",
              style: TextStyle(color: Colors.white), textAlign: TextAlign.left),
        ),
        Container(height: 150, child: picker())
      ]),
    );
  }

  Widget minWin() => new Container(
        padding: const EdgeInsets.all(0),
        color: Colors.white,
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            width: 300,
            child: new Text(
              "Minimum window between notifications",
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 0),
            width: 60,
            child: Text(
              'number',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            width: 30,
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 20,
            ),
          )
        ]),
      );

  Widget maxNotifications() => new Container(
        padding: const EdgeInsets.all(0),
        color: Colors.white,
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            width: 300,
            child: new Text(
              "Max number of notifications per day",
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 0),
            width: 60,
            child: Text(
              'number',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16.0,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            width: 30,
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 20,
            ),
          )
        ]),
      );

  Widget picker() => CupertinoPicker(
          itemExtent: 30,
          // diameterRatio: 50.0,
          useMagnifier: true,
          magnification: 1.1,
          backgroundColor: Colors.white,
          onSelectedItemChanged: (int index) {
            print(index);
          },
          children: <Widget>[
            Text(
              "5 mins",
              textAlign: TextAlign.justify,
            ),
            Text("10 mins"),
            Text("30 mins"),
            Text("1 h"),
            Text("2 h"),
            Text("3 h"),
            Text("1 day"),
          ]);

  Widget weekday() => WeekdaySelector(
        selectedColor: Colors.black,
        selectedFillColor: Colors.black,
        onChanged: (int day) {
          setState(() {
            final index = day % 7;
            values[index] = !values[index];
          });
        },
        values: values,
      );
}
