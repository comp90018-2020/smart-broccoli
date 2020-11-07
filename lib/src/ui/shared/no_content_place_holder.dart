import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoContentPlaceholder extends StatelessWidget {
  const NoContentPlaceholder({Key key, this.text}) : super(key: key);

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
                child: Image(
                  width: 140,
                  height: 140,
                  image: AssetImage('assets/posing_broccoli.png'),
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
