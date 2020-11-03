import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/src/base.dart';

class TimerWidget extends StatefulWidget {
  final int initTime;
  final TextStyle style;

  TimerWidget({this.initTime, this.style});

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer _timer;
  int _millisecondsRemaining;

  void reset(dynamic milliseconds) {
    _millisecondsRemaining = milliseconds;
    if (_timer == null)
      _timer = Timer.periodic(
        const Duration(milliseconds: 100),
        (Timer timer) {
          if (mounted)
            setState(() {
              if (_millisecondsRemaining < 1)
                timer.cancel();
              else
                _millisecondsRemaining -= 100;
            });
        },
      );
  }

  @override
  void initState() {
    super.initState();
    reset(widget.initTime);
    PubSub().subscribe(PubSubTopic.TIMER, reset);
  }

  @override
  void dispose() {
    PubSub().unsubscribe(PubSubTopic.TIMER, reset);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        '${_millisecondsRemaining == null ? '***' : _millisecondsRemaining ~/ 1000}',
        style: widget.style);
  }
}
