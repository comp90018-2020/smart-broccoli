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
    {'title': 'leisim/auto_size_text', 'path': '$_license_dir/auto_size_text'},
    {'title': 'dart-lang/collection', 'path': '$_license_dir/collection'},
    {
      'title': 'builttoroam/device_calendar',
      'path': '$_license_dir/device_calendar'
    },
    {
      'title': 'fredeil/email-validator.dart',
      'path': '$_license_dir/email_validator'
    },
    {
      'title': 'FirebaseExtended/flutterfire',
      'path': '$_license_dir/firebase_core'
    },
    {
      'title': 'FirebaseExtended/flutterfire',
      'path': '$_license_dir/firebase_messaging'
    },
    {'title': 'lukepighetti/fluro', 'path': '$_license_dir/fluro'},
    {
      'title': 'MaikuB/flutter_local_notifications',
      'path': '$_license_dir/flutter_local_notifications'
    },
    {
      'title': 'comp90018-2020/Flutter-settings',
      'path': '$_license_dir/flutter_settings'
    },
    {'title': 'dnfield/flutter_svg', 'path': '$_license_dir/flutter_svg'},
    {'title': 'Baseflow/flutter-geocoding', 'path': '$_license_dir/geocoding'},
    {
      'title': 'Baseflow/flutter-geolocator',
      'path': '$_license_dir/geolocator'
    },
    {'title': 'dart-lang/http', 'path': '$_license_dir/http'},
    {'title': 'flutter/plugins', 'path': '$_license_dir/image_picker'},
    {'title': 'cph-cachet/flutter-plugins', 'path': '$_license_dir/light'},
    {'title': 'MarcinusX/NumberPicker', 'path': '$_license_dir/numberpicker'},
    {'title': 'flutter/plugins', 'path': '$_license_dir/package_info'},
    {'title': 'flutter/plugins', 'path': '$_license_dir/path_provider'},
    {
      'title': 'Baseflow/flutter-permission-handler',
      'path': '$_license_dir/permission_handler'
    },
    {'title': 'rrousselGit/provider', 'path': '$_license_dir/provider'},
    {'title': 'google/quiver-dart', 'path': '$_license_dir/quiver'},
    {
      'title': 'comp90018-2020/selection_picker',
      'path': '$_license_dir/selection_picker'
    },
    {'title': 'flutter/plugins', 'path': '$_license_dir/sensors'},
    {'title': 'flutter/plugins', 'path': '$_license_dir/shared_preferences'},
    {
      'title': 'rikulo/socket.io-client-dart',
      'path': '$_license_dir/socket_io_client'
    },
    {'title': 'tekartik/sqflite', 'path': '$_license_dir/sqflite'},
    {'title': 'flutter/plugins', 'path': '$_license_dir/url_launcher'},
    {
      'title': 'VTechJm/flutter_wifi_info_plugin',
      'path': '$_license_dir/wifi_info_plugin'
    },
    {
      'title': 'fluttercommunity/flutter_workmanager',
      'path': '$_license_dir/workmanager'
    },
    {'title': 'renggli/dart-xml', 'path': '$_license_dir/xml'},
    {
      'title': 'flutter/plugins',
      'url': 'https://raw.githubusercontent.com/flutter/plugins/master/LICENSE'
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
