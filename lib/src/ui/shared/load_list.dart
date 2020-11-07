import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:smart_broccoli/src/ui/shared/helper.dart';

/// Shares a future among tabs
List<Widget> futureTabs({
  @required Future<dynamic> future,
  @required List<Widget> children,
  List<Widget> headers,
  EdgeInsetsGeometry headerPadding,
  @required Widget loadingIndicator,
  @required Widget errorIndicator,
}) {
  return mapIndexed(children, ((index, child) {
    return SingleChildScrollView(
      child: Column(children: [
        if (headers != null)
          Padding(
            padding: headerPadding,
            child: headers[index],
          ),
        FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) return child;
            if (snapshot.hasError) return errorIndicator;
            log("Quiz page futures ${snapshot.toString()}");
            return loadingIndicator;
          },
        ),
      ]),
    );
  })).toList();
}
