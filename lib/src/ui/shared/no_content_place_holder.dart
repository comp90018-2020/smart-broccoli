import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoContentPlaceholder extends StatelessWidget {
  const NoContentPlaceholder({Key key, this.parentWidget, this.text})
      : super(key: key);

  final Object parentWidget;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DecoratedBox(
        decoration: new BoxDecoration(
            color: Color(0xFF125E12), borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "🤔",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 100,
                  ),
                ),
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
