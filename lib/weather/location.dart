import 'package:geolocator/geolocator.dart';

class Location
{
  double latitude, longitude;

  Future getCurrentLocation() async
  {
    try{
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      latitude = position.latitude;
      longitude = position.longitude;
      return [latitude, longitude];
    }
    catch(e){
      print(e);
    }
  }
}