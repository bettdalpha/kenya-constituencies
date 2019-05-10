import 'package:dragabble_marker/Helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class MaterialMap extends StatefulWidget {
  final ConstituencyViewModel model = ConstituencyViewModel();
  @override
  _MaterialMapState createState() => _MaterialMapState();
  
}

class _MaterialMapState extends State<MaterialMap> {
  static GlobalKey<AutoCompleteTextFieldState<Constituency>> key = GlobalKey();
  AutoCompleteTextField<Constituency> searchTextField;
  static MapController controller = MapController();
  bool loaded = false;
  _loadConstituencies() async {
    await widget.model.readConstituencies();
    print('Finished reading constituencies ${widget.model.constituencyList.length}');
  }

  @override
  void initState() {
    loaded = false;
    //controller = MapController();
    _loadConstituencies();
    setState(() {
      loaded = true;
    });
    super.initState();
  }

  FlutterMap _map = new FlutterMap(
  mapController: controller,
  options: MapOptions(
    center: LatLng(-1.26, 36.81),
  ),
  layers: <LayerOptions>[
    TileLayerOptions(
        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ['a', 'b', 'c'],
        cachedTiles: true,
        ),
  ],
);

  addToMap(List<LatLng> polygon,FlutterMap map){
    if(map.layers.length<1){
      setState(() {
        map.layers.add(PolygonLayerOptions(
          polygons: [
            new Polygon(
              points: polygon,
              borderColor: Theme.of(context).accentColor,
              borderStrokeWidth: 3,
              color: Colors.transparent
            )
          ]
        ));
        print('Polygon added ... ${map.layers.length}');
      });
      print(map.layers.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    searchTextField = AutoCompleteTextField<Constituency>(
      key: key,
      decoration: InputDecoration(
          hintText: 'Search a constituency',
          hintStyle: TextStyle(color: Colors.accents.last),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          fillColor: Colors.amberAccent,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          suffixIcon: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              child: Icon(Icons.search),
            ),
          )),
      itemBuilder: (context, item) {
        return Container(
          padding: EdgeInsets.only(top: 10,bottom: 5,left: 20,right: 20),
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: <Widget>[
              Text(item.name),
              Spacer(),
              Text(item.county,style: TextStyle(
              ),)
            ],
          ),
        );
      },
      suggestions: widget.model.constituencyList,
      itemFilter: (a, query) {
        return a.name.toLowerCase().startsWith(query.toLowerCase());
      },
      itemSorter: (a, b) {
        return a.name.compareTo(b.name);
      },
      clearOnSubmit: false,
      itemSubmitted: (consti) {
        var pol = Polygon(
          points: consti.polygon,
              borderColor: Theme.of(context).accentColor,
              borderStrokeWidth: 3,
              color: Colors.green.withOpacity(0.999)
        );
        setState(() {
              _map.layers.add(PolygonLayerOptions(polygons: [
                pol  
              ]));
              controller.move(consti.polygon[0],12);
            });
        controller.move(consti.polygon[0],10);
        //print();
      },
    );

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Stack(fit: StackFit.loose, children: <Widget>[
          Container(child: _map),
          Positioned(
            top: 30,
            child: Container(
              width: MediaQuery.of(context).size.width*.95,
              child: Material(
                child: searchTextField,
                key: GlobalKey(),  
                borderRadius: BorderRadius.circular(20),
                elevation: 10,
              ),
            ),
          ),
          loaded ? Positioned(
            top: MediaQuery.of(context).size.height/2,
            left: MediaQuery.of(context).size.width/2,
            child: Center(
              child: loaded ? null : CircularProgressIndicator(backgroundColor: Color.fromRGBO(2, 2, 250, 0.9),)
            ),
          ) : null,
        ])
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_searching),
        onPressed: () {
          print('Hello');
          //Helpers().readConstituencies();
            if(_map==null){
              print('map not initialised');
              return;
            }
        },
      ),
    );
  }
}
