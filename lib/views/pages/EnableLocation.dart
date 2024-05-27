// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:recyclear/Admin/pages/map_page.dart';
// import 'package:recyclear/utils/app_colors.dart';
// import 'package:recyclear/views/widgets/main_button.dart';

// class EnableLocation extends StatefulWidget {
//   const EnableLocation({super.key});

//   @override
//   State<EnableLocation> createState() => _EnableLocationState();
// }

// class _EnableLocationState extends State<EnableLocation> {
//   bool scanning = false;
//   String address = '';
//   double locLongitude = 0 ;
//   double locLlatitude = 0;
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       body:  Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//            const Text('Get the current user location'),
//             Container(
//               height: MediaQuery.of(context).size.height*0.05,
//                width: MediaQuery.of(context).size.width *0.5,
//               color: AppColors.primary,
//               child: MainButton(
//                 onPressed: (){
//                   checkPermission();
//                    Navigator.push(
                  
          
//                     context,
//                     MaterialPageRoute(builder: (context) => MapSample(latitude: locLlatitude, longitude: locLongitude))
                    
//                   );
//                 },
//                 child: const Text('Get User Location', style:TextStyle(
//                   color: AppColors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold
//                 )),
//               ),
//             )
//           ],
//         )

//       ),
//     );
//   }

//   Future <void>  allowpermission(Permission permission, BuildContext context) async{
//     final status = await permission.request();
//     if(status.isGranted){
//       ScaffoldMessenger.of(context).showSnackBar(
//        const  SnackBar(
//         content:  Text("Permission is generated"))
//         );
//     }else{
//       ScaffoldMessenger.of(context).showSnackBar(
//        const  SnackBar(
//         content:  Text("Permission is Not generated"))
//         );

//     }

//   }

//   checkPermission() async{
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     print(serviceEnabled);

//     if(!serviceEnabled){
//       await Geolocator.openLocationSettings();
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     print(permission);

//     if(permission == LocationPermission.denied){
       
//        permission = await Geolocator.requestPermission();

//        if(permission == LocationPermission.denied){
//         Fluttertoast.showToast(msg: 'Request Denied !');
//         return;
//        }

//     }

//     if (permission == LocationPermission.deniedForever){
//        Fluttertoast.showToast(msg: 'Request Denied Forever!');
//         return;

//     }

//     geoLocation();
//   }

//   geoLocation() async{
//     setState(() {
//       scanning  = true;
//     });

//     try{
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
//       print(position.latitude);
//       locLlatitude = position.latitude;
//       print("\n");
//       print(position.longitude);
//       locLongitude = position.longitude;

//       List <Placemark> result = await placemarkFromCoordinates(position.latitude, position.longitude);

//       if(result.isNotEmpty){
//         address = '${result[0].name}, ${result[0].locality} ${result[0].administrativeArea}';
//         print(address);
        
//       }

//     }catch(e){
//       Fluttertoast.showToast(msg: '${e.toString()}');
//     }

//     setState(() {
//       scanning =false;
//     });

//   }
   
// }