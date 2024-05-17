import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/dash_board_page.dart';
import 'package:recyclear/Admin/pages/edit_profile.dart';
import 'package:recyclear/Admin/pages/store_page.dart';
import 'package:recyclear/views/pages/requests_page_for_user_and_admain.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/services/notification_service.dart';
import 'package:recyclear/views/pages/login_page.dart';

class CustomBottomNavbarUser extends StatefulWidget {
  const CustomBottomNavbarUser({super.key});

  @override
  State<CustomBottomNavbarUser> createState() => _CustomBottomNavbarUserState();
}

class _CustomBottomNavbarUserState extends State<CustomBottomNavbarUser> {
  int currentPageIndex = 0;
  User? user =
      FirebaseAuth.instance.currentUser; // Get the currently signed-in user

  List<Widget> pageList = [
    //const MapSample(),
    const DashBoard(),
    const Store(),
    const RequestsPage(),
  ];

  String? userName;
  String? userEmail;
  String? PhotoUrl;

  @override
  void initState() {
    super.initState();
    initApp();
    if (user != null) {
      _loadUserData();
    }
  }

  void initApp() async {
    // Initialize notification service
    await NotificationService().initializeNotification();
    debugPrint('Before the start Monitoring Bin');
    // Start monitoring bin heights
    FirestoreService.instance.monitorBinHeightAndNotify();
    debugPrint('After the start Monitoring Bin');
  }

  Future<void> _loadUserData() async {
    // Use the FirestoreService to get the user's data
    final userData = await FirestoreService.instance.getDocument(
      path: 'users/${user!.uid}', // Adjust the path to your users collection
      builder: (data, documentID) => data,
    );

    setState(() {
      userName = userData['name'] as String?;
      userEmail = userData['email'] as String?;
      PhotoUrl = userData['photoUrl'] as String?;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const LoginPage()), // Navigate to login page
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
        title: Image.asset(
          'assets/images/greenRecyclear.png',
          height:
              AppBar().preferredSize.height, // Match the height of the AppBar
        ),
      ),
      drawer: buildDrawer(),
      bottomNavigationBar: buildBottomNavigationBar(),
      body: pageList[currentPageIndex],
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName ??
                'Your Name'), // Replace with data fetched from Firestore
            accountEmail: Text(userEmail ??
                'email@example.com'), // Replace with data fetched from Firestore
            currentAccountPicture: (PhotoUrl != null)
                ? CircleAvatar(
                    backgroundImage: NetworkImage(PhotoUrl!),
                  )
                : CircleAvatar(
                    child: Text(
                      userName != null ? userName![0] : 'U',
                      style: const TextStyle(fontSize: 40.0),
                    ),
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to profile page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfile()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  NavigationBar buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: currentPageIndex,
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.store_outlined),
          selectedIcon: Icon(Icons.store),
          label: 'Store',
        ),
        NavigationDestination(
          icon: Icon(Icons.announcement_outlined),
          selectedIcon: Icon(Icons.announcement),
          label: 'Requests',
        ),
      ],
    );
  }
}
