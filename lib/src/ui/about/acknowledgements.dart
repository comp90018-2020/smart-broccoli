// Acknowledgements page, adapted from:
// https://github.com/YC/another_authenticator

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart'
    show Divider, ListTile, MaterialPageRoute;
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_broccoli/src/ui/shared/page.dart';

const _license_dir = 'assets/licenses';
const _libs = [
  {'title': 'Broccoli Logo by Yaling Deng'},
  {'title': 'Broccoli Icon', 'url': 'https://charatoon.com/?dl=3049'},
  {'title': 'Logo font: Patrick Hand SC', 'path': '$_license_dir/patrick_hand'},
  {
    'title': 'indexed_stack by cirnok',
    'url': 'https://gist.github.com/cirnok/e1b70f5d841e47c9d85ccdf6ae866984'
  },
  {
    'title': 'google/material-design-icons',
    'path': '$_license_dir/material_design_icons'
  },

  {'title': 'flutter/flutter', 'path': '$_license_dir/flutter'},
  // License of packages: 'package_info', 'path_provider', 'sensors', 'shared_preferences', 'url_launcher'
  {'title': 'flutter/plugins', 'path': '$_license_dir/flutter_plugins'},
  {
    'title': 'flutter/plugins/image_picker',
    'path': '$_license_dir/image_picker'
  },
  {
    'title': 'ChangJoo-Park/flutter_foreground_plugin',
    'path': '$_license_dir/flutter_foreground_plugin'
  },
  {'title': 'brendan-duncan/image', 'path': '$_license_dir/image'},
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
  // License of packages: 'firebase_core', 'firebase_messaging'
  {'title': 'FirebaseExtended/flutterfire', 'path': '$_license_dir/firebase'},
  {'title': 'lukepighetti/fluro', 'path': '$_license_dir/fluro'},
  {
    'title': 'MaikuB/flutter_local_notifications',
    'path': '$_license_dir/flutter_local_notifications'
  },
  {
    'title': 'MustafaGamalAbbas/Flutter-settings',
    'path': '$_license_dir/flutter_settings'
  },
  {'title': 'dnfield/flutter_svg', 'path': '$_license_dir/flutter_svg'},
  {'title': 'Baseflow/flutter-geocoding', 'path': '$_license_dir/geocoding'},
  {'title': 'Baseflow/flutter-geolocator', 'path': '$_license_dir/geolocator'},
  {'title': 'dart-lang/http', 'path': '$_license_dir/http'},
  {'title': 'cph-cachet/flutter-plugins', 'path': '$_license_dir/light'},
  {'title': 'MarcinusX/NumberPicker', 'path': '$_license_dir/numberpicker'},
  {
    'title': 'Baseflow/flutter-permission-handler',
    'path': '$_license_dir/permission_handler'
  },
  {'title': 'rrousselGit/provider', 'path': '$_license_dir/provider'},
  {'title': 'google/quiver-dart', 'path': '$_license_dir/quiver'},
  {
    'title': 'Pixzelle/selection_picker',
    'path': '$_license_dir/selection_picker'
  },
  {
    'title': 'rikulo/socket.io-client-dart',
    'path': '$_license_dir/socket_io_client'
  },
  {'title': 'tekartik/sqflite', 'path': '$_license_dir/sqflite'},
  {
    'title': 'VTechJm/flutter_wifi_info_plugin',
    'path': '$_license_dir/wifi_info_plugin'
  },
  {
    'title': 'fluttercommunity/flutter_workmanager',
    'path': '$_license_dir/workmanager'
  },
  {'title': 'renggli/dart-xml', 'path': '$_license_dir/xml'},
];

/// Acknowledgements page for used libraries and code
class AcknowledgementsPage extends StatelessWidget {
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
                rootBundle.loadString(_libs[index]['path']).then((text) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          FullScreenLicense(_libs[index]['title'], text)));
                }).catchError((_) => {});
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
