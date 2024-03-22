import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Admin/pages/custom_button_nav_bar.dart';
import 'package:graduation_project/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:graduation_project/utils/app_theme.dart';

//void main() => runApp(const CustomBottomNavbar());

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecyClear App',
      theme: AppTheme.lightTheme,
      home: CustomBottomNavbar(),
    );
  }
}

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Sensor Data'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   // Define the variables to store sensor data
//   String _date = '';
//   String _time = '';
//   double _fillLevel = 0;
//   double _humidity = 0;
//   double _temperature = 0;

//   // Reference to the Firebase Realtime Database
//   final _databaseRef = FirebaseDatabase.instance.ref();

//   @override
//   void initState() {
//     super.initState();
//     _activateListeners();
//   }

//   void _activateListeners() {
//     // Listening to the humidityTemp node changes
//     _databaseRef.child('sensors/data').onValue.listen((event) {
//       final data = Map<String, dynamic>.from(event.snapshot.value as Map);
//       setState(() {
//         _fillLevel = double.tryParse(data['fill-level'].toString()) ?? 0;
//         _humidity = double.tryParse(data['humidity'].toString()) ?? 0;
//         _temperature = double.tryParse(data['temperature'].toString()) ?? 0;
//         _date = data['date'] ?? '';
//         _time = data['time'] ?? '';
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Fill Level: $_fillLevel',
//               textAlign: TextAlign.center,
//             ),
//             Text(
//               'Humidity: $_humidity%',
//               textAlign: TextAlign.center,
//             ),
//             Text(
//               'Temperature: $_temperature°C',
//               textAlign: TextAlign.center,
//             ),
//             Text(
//               'Date: $_date\nTime: $_time',
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
