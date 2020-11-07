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
        padding: EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.8,
        child: DecoratedBox(
          decoration: new BoxDecoration(
              color: Color(0xFF125E12),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 40, bottom: 20, right: 10, left: 10),
                child: Image(
                  width: 140,
                  height: 140,
                  image: AssetImage('assets/posing_broccoli.png'),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.only(bottom: 10, right: 20, left: 20),
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
        ));
  }
}
