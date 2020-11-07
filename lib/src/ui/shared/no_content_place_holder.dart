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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 40, bottom: 20, right: 10, left: 10),
              child: Text(
                "🤔",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 100,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
