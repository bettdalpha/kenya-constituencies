
// class Amenity {
  
//   AmenityType type;

//   Amenity({
//     @required this.name,
//     @required double x,
//     @required double y
//   }){
//     this.location =LatLng(x,y);
//   }
// }

enum AmenityType {
  bank,hospital,hotel,restaurant,mechanicShop
}

class Bank {
  double lat,lon;
  String name;
  var type =AmenityType.bank;

  Bank(String name,double x,double y){
    this.lat = x;
    this.lon = y;
    this.name =name;
  }
  Bank.fromJson(dynamic feature){
      this.name = feature['properties']['name'];
      //this.location =LatLng(
      this.lat = feature['geometry']['coordinates'][1];
      this.lon = feature['geometry']['coordinates'][0];

  }
  @override
  String toString() {
    return "Name: ${this.name}\nCoords: [${this.lat},${this.lon}]";
  } 
}