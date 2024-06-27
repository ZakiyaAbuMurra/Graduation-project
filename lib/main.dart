import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/cubits/auth_cubit/auth_cubit.dart';
import 'package:recyclear/firebase_options.dart';
import 'package:recyclear/sharedPreferences.dart';
import 'package:recyclear/utils/app_theme.dart';
import 'package:recyclear/utils/route/app_router.dart';
import 'package:recyclear/utils/route/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await sharedPreferences.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe) {
      return AppRoutes.bottomNavbar; // Replace with the appropriate home route
    } else {
      return AppRoutes.notification;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: FutureBuilder<String>(
        future: _getInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator while waiting
          } else if (snapshot.hasError) {
            return MaterialApp(
              title: 'App',
              theme: AppTheme.lightTheme,
              home: Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              ),
            );
          } else {
            final initialRoute = snapshot.data!;
            return MaterialApp(
              title: 'App',
              theme: AppTheme.lightTheme,
              initialRoute: initialRoute,
              onGenerateRoute: AppRouter.onGenerateRoute,
            );
          }
        },
      ),
    );
  }
}
