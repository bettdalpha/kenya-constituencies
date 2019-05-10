import 'package:dragabble_marker/Helpers.dart';
import 'package:dragabble_marker/MaterialMap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MaterialMap(),
      theme: ThemeData.dark(),
    );
  }
}

class DragMarker extends StatefulWidget {
  @override
  _DragMarkerState createState() => _DragMarkerState();
}

class _DragMarkerState extends State<DragMarker> {
  String url =
      "http://localhost:8080/geoserver/wfs?service=wfs&version=2.0.0&request=GetFeature&typeName=nairobi:nearest_banks&outputFormat=application/json&viewParams=limit:100;lat:-1.305;long:36.8138";

  Position position;
  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      final Geolocator locator = Geolocator();
      position = await locator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } on PlatformException {
      print('Cannot get position');
      position = null;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchBarWidget(),
        toolbarOpacity: 0.6,
        actions: <Widget>[
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.remove),
            ),
            onTap: () {
              setState(() {
                Helpers().removeMarkers(map);
              });
              print('Markers removed');
            },
          ),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.location_searching),
            ),
            onTap: () {
              PermissionHandler()
                  .requestPermissions([PermissionGroup.locationWhenInUse]);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
            child: Column(children: [
              Flexible(
                child: map,
              )
            ])),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            PermissionHandler()
                .requestPermissions([PermissionGroup.locationWhenInUse]);
            // Helpers().getUserLocation();
            setState(() {
              Helpers().getBanks(url, map, context);
            });
          },
          child: Icon(Icons.location_searching)),
    );
  }
}

FlutterMap map = new FlutterMap(
  options: MapOptions(
    center: LatLng(-1.26, 36.81),
  ),
  layers: <LayerOptions>[
    TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
  ],
);

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: '[Service] around me'),
      onSubmitted: (String s) {
        //detokenize and ML
      },
    );
  }
}

class MainMapState extends State<MainMap> {
  @override
  Widget build(BuildContext context) {
    //var bounds = LatLngBounds(LatLng(_latitude, _longitude),LatLng(_latitude, _longitude))
    //_controller.fitBounds(bounds);
    return Flexible(
      child: FlutterMap(
        options: MapOptions(center: widget.center),
        layers: <LayerOptions>[
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          //additional layers
        ],
      ),
    );
  }
}

class MainMap extends StatefulWidget {
  final LatLng center;
  final int zoom;

  MainMap(this.center, this.zoom);

  @override
  State<StatefulWidget> createState() => MainMapState();
}
