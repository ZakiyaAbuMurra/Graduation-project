


import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:recyclear/services/location_controller.dart';

class LocationServices{

  LocationServices.init();

  static LocationServices instance = LocationServices.init();

  

  Future<bool> checkPermission({required LocationController controller})async {
    bool isEnabled = false;
    LocationPermission permission;

    isEnabled  = await Geolocator.isLocationServiceEnabled();

    if(!isEnabled){
      controller.updateIsAccessingLocation(isEnabled);
      return false;

    }

    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied){

      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        controller.updateIsAccessingLocation(isEnabled);

        return false;
      }
      
    }

    if(permission == LocationPermission.deniedForever){
      controller.updateIsAccessingLocation(isEnabled);

      return false;
    }

    controller.updateIsAccessingLocation(true);


    return true;

  
  }

   Future <Position> getUserLocation({required LocationController controller})async{
      var isEnabled = await checkPermission(controller: controller);
     

      if(isEnabled){
        Position location = await Geolocator.getCurrentPosition();
        controller.updateUserLocation(location);
        return location;
    }  else{
      controller.errorString.value = "Location Permission not Generated";
      throw Exception("Location Permission not Generated");
    }  
  }
}
   


