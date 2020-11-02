import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smart_broccoli/src/base.dart';
import 'package:smart_broccoli/src/models/session_model.dart';

class TimerWidget extends StatefulWidget {
  final TextStyle style;

  TimerWidget({this.style});

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer _timer;
  int _millisecondsRemaining;

  void reset(dynamic milliseconds) {
    _millisecondsRemaining = milliseconds;
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (Timer timer) => setState(() {
        if (_millisecondsRemaining < 1)
          timer.cancel();
        else
          _millisecondsRemaining -= 100;
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<GameSessionModel>(context, listen: false)
        .pubSub
        .subscribe(PubSubTopic.TIMER, reset);
  }

  @override
  void dispose() {
    super.dispose();
    Provider.of<GameSessionModel>(context, listen: false)
        .pubSub
        .unsubscribe(PubSubTopic.TIMER, reset);
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        '${_millisecondsRemaining == null ? '***' : _millisecondsRemaining ~/ 1000}',
        style: widget.style);
  }
}
