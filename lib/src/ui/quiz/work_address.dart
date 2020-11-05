import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:dropdown_search/dropdown_search.dart';

///Address selection page
class MapSetting extends StatelessWidget {
  const MapSetting({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _title = "Work place";
    return Scaffold(
      appBar: AppBar(
          title: Text(
            _title,
          ),
          centerTitle: true),
      body: Container(
        child: Center(
          child: DropdownSearch<String>(
              mode: Mode.MENU,
              // showSearchBox: true,
              showSelectedItem: true,
              showClearButton: true,
              items: ["Brazil", "Italia (Disabled)", "Tunisia", 'Canada'],
              label: "Input address",
              hint: "Work address",
              popupItemDisabled: (String s) => s.startsWith('I'),
              onChanged: print,
              selectedItem: "Brazil"),
          // child: FlutterMap(
          //   options: new MapOptions(
          //     center: new LatLng(51.5, -0.09),
          //     zoom: 13.0,
          //   ),
          //   layers: [
          //     new TileLayerOptions(
          //         urlTemplate:
          //             "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          //         subdomains: ['a', 'b', 'c']),
          //     new MarkerLayerOptions(
          //       markers: [
          //         new Marker(
          //           width: 80.0,
          //           height: 80.0,
          //           point: new LatLng(51.5, -0.09),
          //           builder: (ctx) => new Container(
          //             child: new FlutterLogo(),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
