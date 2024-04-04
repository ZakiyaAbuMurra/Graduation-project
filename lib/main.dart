import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/firebase_options.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:recyclear/services/notification_service.dart';
import 'package:recyclear/views/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bin Monitor',
      home: HomeScreen(),
    );
  }

//I commented on this because it was asking me to do the login each time I rebuilt the app  // @override
  // Widget build(BuildContext context) {
  //   return BlocProvider(
  //       create: (context) => AuthCubit(),
  //       child: MaterialApp(
  //         title: 'App',
  //         theme: AppTheme.lightTheme,
  //         initialRoute: AppRoutes.homeLogin,
  //         onGenerateRoute: AppRouter.onGenerateRoute,
  //       ));
  // }
}
