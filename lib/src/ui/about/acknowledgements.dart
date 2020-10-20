// Acknowledgements page, adapted from:
// https://github.com/YC/another_authenticator

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Divider, ListTile;
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

/// Acknowledgements page for used libraries and code
class AcknowledgementsPage extends StatelessWidget {
  static const _libs = [
    {'title': 'Broccoli Logo by Yaling Deng'},
    {
      'title': 'indexed_stack by cirnok',
      'url': 'https://gist.github.com/cirnok/e1b70f5d841e47c9d85ccdf6ae866984'
    },
    {
      'title': 'Flutter',
      'url': 'https://raw.githubusercontent.com/flutter/flutter/master/LICENSE'
    },
    {
      'title': 'flutter/plugins',
      'url': 'https://raw.githubusercontent.com/flutter/plugins/master/LICENSE'
    },
    {
      'title': 'dart-lang/http',
      'url': 'https://raw.githubusercontent.com/dart-lang/http/master/LICENSE'
    },
    {
      'title': 'rrousselGit/provider',
      'url':
          'https://raw.githubusercontent.com/rrousselGit/provider/master/LICENSE',
    },
    {
      'title': 'fredeil/email-validator.dart',
      'url':
          'https://raw.githubusercontent.com/fredeil/email-validator.dart/master/LICENSE'
    },
    {
      'title': 'lukepighetti/fluro',
      'url':
          'https://raw.githubusercontent.com/lukepighetti/fluro/master/LICENSE'
    },
    {
      'title': 'MarcinusX/NumberPicker',
      'url':
          'https://raw.githubusercontent.com/MarcinusX/NumberPicker/master/LICENSE'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'Acknowledgements',
      child: ListView.separated(
        itemCount: _libs.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 0),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              if (_libs[index]['url'] != null)
                launch(_libs[index]['url'], forceWebView: true);
            },
            title: Text(_libs[index]['title']),
          );
        },
      ),
    );
  }
}
