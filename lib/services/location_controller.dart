
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationController extends GetxController{
  final RxBool isAccessingLocation = RxBool(false);
  final RxString errorString = RxString("");
  final Rx<Position?> userLocation = Rx<Position?>(null);

  void updateIsAccessingLocation(bool b){
    isAccessingLocation.value = b;
  }

  void updateUserLocation(Position position){

    userLocation.value = position;

  }
}