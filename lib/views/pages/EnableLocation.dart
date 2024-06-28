
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:recyclear/services/location_controller.dart';
import 'package:recyclear/services/location_service.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/views/pages/login_page.dart';

class EnableLocation extends StatefulWidget {
  const EnableLocation({super.key});

  @override
  State<EnableLocation> createState() => _EnableLocationState();
}

class _EnableLocationState extends State<EnableLocation> {
  bool enabled = false;
  double longitude = -1.0;
  double latitude = -1.0;

  final LocationController locationController =
      Get.put<LocationController>(LocationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.75,
            width: MediaQuery.of(context).size.width,
            color: AppColors.bgColor,
            child: Image.asset(
              "assets/images/getLocation.png",
              fit: BoxFit.none,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.165,
              width: MediaQuery.of(context).size.width * 0.9,
              child: const Text(
                  "To improve your experience with our recycling app," +
                      " enable your location to recycle more efficiently and stay informed about local" +
                      " recycling opportunities. Your privacy is important to us, and your location data will only be used to improve your app experience.",
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.black,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.065,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    LocationServices.instance
                        .getUserLocation(controller: locationController);

                    //   await sharedPreferences.setLocationStatus(locationController.isAccessingLocation.value);
                    //  await sharedPreferences.setLatitude(locationController.userLocation.value!.latitude);
                    //  await sharedPreferences.setLongitude(locationController.userLocation.value!.longitude);

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const LoginPage()));
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
                Container(
                  child: IconButton(
                      onPressed: () {
                        LocationServices.instance
                            .getUserLocation(controller: locationController);

                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                      },
                      icon: Icon(
                        Icons.navigate_next,
                        size: MediaQuery.of(context).size.height * 0.05,
                        color: AppColors.primary,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
