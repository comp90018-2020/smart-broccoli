// Acknowledgements page, adapted from:
// https://github.com/YC/another_authenticator

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart'
    show Divider, ListTile, MaterialPageRoute;
import 'package:url_launcher/url_launcher.dart';

import 'package:smart_broccoli/src/ui/shared/page.dart';

/// Acknowledgements page for used libraries and code
class AcknowledgementsPage extends StatelessWidget {
  static const _license_dir = 'assets/licenses';
  static const _libs = [
    {'title': 'Broccoli Logo by Yaling Deng'},
    {'title': 'Broccoli Icon', 'url': 'https://charatoon.com/?dl=3049'},
    {
      'title': 'Logo font: Patrick Hand SC',
      'url':
          'https://raw.githubusercontent.com/m4rc1e/PatrickHandSC/master/OFL.txt'
    },
    {
      'title': 'indexed_stack by cirnok',
      'url': 'https://gist.github.com/cirnok/e1b70f5d841e47c9d85ccdf6ae866984'
    },
    {'title': 'flutter/flutter', 'path': '$_license_dir/flutter'},
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
    },
    {
      'title': 'leisim/auto_size_text',
      'url':
          'https://raw.githubusercontent.com/leisim/auto_size_text/master/LICENSE'
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
            onTap: () async {
              if (_libs[index]['url'] != null)
                launch(_libs[index]['url'], forceWebView: true);
              if (_libs[index]['path'] != null) {
                var text = await rootBundle.loadString(_libs[index]['path']);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        FullScreenLicense(_libs[index]['title'], text)));
              }
            },
            title: Text(_libs[index]['title']),
          );
        },
      ),
    );
  }
}

/// Full screen license widget
class FullScreenLicense extends StatelessWidget {
  /// The name
  final String title;

  /// License
  final String license;

  FullScreenLicense(this.title, this.license);

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: this.title,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(this.license),
        ),
      ),
    );
  }
}
