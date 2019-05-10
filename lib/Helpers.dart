import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:dragabble_marker/point.dart';
import 'package:latlong/latlong.dart';


class Helpers {
  var client = http.Client();

  dynamic getBanks(String url,FlutterMap map,BuildContext context) async {
    Response feed =
        await client.get(url, headers: {"accept": "application/json"});
    print('Received feedback');
    var undecoded = feed.body;
    // for(var i=0;i<undecoded.length;i++){
    //   print(undecoded[i]);
    // }
    
    var decod = json.decode(undecoded);
    //printJSON(decod);
    List banks = readBanksFromJSON(decod);
    addMarkersToMap(banks, map, context);
    return decod;
  }

  List<Bank> readBanksFromJSON(dynamic data) {
    var features = data['features'];
    if (features.length == 0) {
      return null;
    }
    List<Bank> banks = [];

    for (var i = 0; i < features.length; i++) {
      String name = features[i]['properties']['name'];
      double lat = features[i]['geometry']['coordinates'][1];
      double lon = features[i]['geometry']['coordinates'][0];
      print("$name\t[$lat,$lon]");
      Bank temp = Bank(name, lat, lon);
      banks.add(temp);
    }
    return banks;
  }

  printBanks(List<Bank> banks, @optionalTypeArgs int offset) {
    int len;
    if (offset != null) {
      len = banks.length;
    } else {
      len = offset;
    }
    for (var i = 0; i < len; i++) {
      print(banks[i]);
    }
  }

  addMarkersToMap(List<Bank> banks, FlutterMap map, BuildContext context) {
    print('inside add markers');
    List<Marker> bankMarkers = [];
    for(var i =0;i<banks.length;i++){
      Marker temp = createBankMarker(banks[i]);
      bankMarkers.add(temp);
    }
    MarkerLayerOptions options = MarkerLayerOptions(markers: bankMarkers);
    map.layers.add(options);
    if(map.layers.length>1){
      print('Markers added');
    }
    //print('Markers added');
  }
  Marker createBankMarker(Bank bank){
    return Marker(
      point: LatLng(bank.lat, bank.lon),
      builder: (context){
        return GestureDetector(
          onTap: () => Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Bank Name: ${bank.name}"),
            duration: Duration(milliseconds: 500),
          )), //todo,
          child: Image.asset('assets/bank.png')
        );
      },
    );
  }
  void removeMarkers(FlutterMap map){
    if(map.layers.length<=1){
      print('Cannot remove basemap');
      return;
    }
    else{
      map.layers.removeLast();
    }
  }
  Future readConstituencies() async {
    List<Constituency> constituencies = <Constituency>[];
    var parsedJson = await readJson();

    try{
    for(int i=0;i<parsedJson.length;i++){
        if(parsedJson[i]['properties']['name']==null){
          continue;
        }
        constituencies.add(Constituency.fromJson(parsedJson[i]));
        print('$i:' + parsedJson[i]['properties']['name']);
    }
    }catch(e){
      print(e);
      print('erros handling json');
    }
    print(constituencies);
    return constituencies;
  }
  Future<List> readJson() async {
    var jsonString = await rootBundle.loadString('assets/constituencies.json');
    var jsString = json.decode(jsonString);
    var parsedJson = jsString['features'] as List;
    return parsedJson;
  }


}

class Constituency {
  List<LatLng> polygon;
  String name;
  String county;

  Constituency({this.name,this.county});

  factory Constituency.fromJson(Map<String,dynamic> parsed){
    return Constituency(
      name: parsed['properties']['name'] as String,
      county: parsed['properties']['county_name'],
    )..polygon = polyLatLngFromJson(parsed['geometry']['coordinates'][0]);
  }

  @override
  String toString() {
    return '${this.name}';
  }
  static List<LatLng> polyLatLngFromJson(List<dynamic> geom){
    List<LatLng> polygon = List();
    var lat,lng;

    for(int a=0;a<geom.length;a++){
      lng = geom[a][0];
      lat = geom[a][1];

      //print('lat: $lat,lng: $lng');

      polygon.add(LatLng(lat,lng));
    }
    return polygon;
  }
}

class ConstituencyViewModel {
   final List<Constituency> constituencyList = new List();

  ConstituencyViewModel(){
    readConstituencies();
  }

  Future readConstituenciesAsJSON() async{
    var jsonString = await rootBundle.loadString('assets/constituencies.json');
    var jsString = json.decode(jsonString);
    var parsedJson = jsString['features'] as List;
    return parsedJson;
  }

   Future readConstituencies() async {
    var jsonString = await rootBundle.loadString('assets/constituencies.json');
    var jsString = json.decode(jsonString);
    var parsedJson = jsString['features'] as List;
    var name ='';
    var o=0;
    try{
    for(int i=0;i<parsedJson.length;i++){
        name = parsedJson[i]['properties']['name'] as String;
         Map<String,dynamic> geom = parsedJson[i]['geometry'];
        var points = polyLatLngFromJson(geom['coordinates'][0]);
        
        if(name==null || points==null){
          o++;
          String cause = points==null ? 'Points' : (name==null ? "Name" : 'undefined');
          print('skipped adding $o...cause : $cause');
          continue;
        }
        var consti = Constituency.fromJson(parsedJson[i]);
        constituencyList.contains(consti) ? print('List already containts ${consti.name}'): constituencyList.add(consti);
        
        //final polygon= new Polygon(points: points);
        print(points);
    }
    }catch(e){
      print(e);
      print('erros handling json');
    }
    
    //print(constituencyList);
    return constituencyList;
  }
   List<LatLng> polyLatLngFromJson(List<dynamic> geom){
    List<LatLng> polygon = List();
    var lat,lng;

    for(int a=0;a<geom.length;a++){
      lng = geom[a][0];
      lat = geom[a][1];

      //print('lat: $lat,lng: $lng');

      polygon.add(LatLng(lat,lng));
    }
    return polygon;
  }
}
