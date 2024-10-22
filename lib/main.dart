import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/cubits/auth_cubit/auth_cubit.dart';
import 'package:recyclear/firebase_options.dart';
import 'package:recyclear/splash.dart';
import 'package:recyclear/utils/app_theme.dart';
import 'package:recyclear/utils/route/app_router.dart';
import 'package:recyclear/utils/route/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'App',
        theme: AppTheme.lightTheme,
        initialRoute: '/', // Set your default initial route here
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => SplashScreen());
          }
          return AppRouter.onGenerateRoute(settings);
        },
      ),
    );
  }
}

