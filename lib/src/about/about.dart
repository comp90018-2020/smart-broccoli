// About page, adapted from:
// https://github.com/YC/another_authenticator

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launch;
import 'package:package_info/package_info.dart' show PackageInfo;

import '../shared/page.dart';

/// Settings page.
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      title: 'About',
      hasDrawer: true,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // App Info
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // App image
                  Container(
                      height: 130,
                      width: 130,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: const DecoratedBox(
                          decoration: const BoxDecoration(
                              image: const DecorationImage(
                                  image:
                                      const AssetImage('assets/icon.png'))))),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // App name
                          FutureBuilder(
                            future: PackageInfo.fromPlatform(),
                            builder: (BuildContext context,
                                AsyncSnapshot<PackageInfo> snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data.appName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context).textTheme.headline5,
                                );
                              }
                              return Text('Loading');
                            },
                          ),
                          // Version of app
                          FutureBuilder(
                              future: PackageInfo.fromPlatform(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<PackageInfo> snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data.version);
                                }
                                return Text('Loading');
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List of options
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Source
                ListTile(
                    dense: true,
                    leading: const Icon(Icons.code),
                    title: Text('Source code'),
                    onTap: () {
                      launch('https://github.com/comp90018-2020/smart-broccoli',
                          forceWebView: true);
                    }),
                // Acknowledgements
                ListTile(
                    dense: true,
                    leading: const Icon(Icons.book),
                    title: Text('Acknowledgements & Licenses'),
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/about/acknowledgements');
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
