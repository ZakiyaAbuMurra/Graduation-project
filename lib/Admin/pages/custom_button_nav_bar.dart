import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/add_bin.dart';
import 'package:recyclear/Admin/pages/create_driver_account.dart';
import 'package:recyclear/Admin/pages/dash_board_page.dart';
import 'package:recyclear/Admin/pages/edit_profile.dart';
import 'package:recyclear/Admin/pages/map_page.dart';
import 'package:recyclear/Admin/pages/view_store_page.dart';
import 'package:recyclear/services/auth_service.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/services/notification_service.dart';
import 'package:recyclear/views/pages/login_page.dart';
import 'package:recyclear/views/pages/notification_page.dart';
import 'package:recyclear/views/pages/requests_page_for_user_and_admain.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({Key? key}) : super(key: key);

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  int currentPageIndex = 0;

  User? user =
      FirebaseAuth.instance.currentUser; // Get the currently signed-in user

  final AuthServices authServices =
      AuthServicesImpl(); // Instantiate AuthServicesImpl

  List<Widget> pageList = [
    const MapSample(), //TODO :  After fixed the map , replace the correct one
    DashboardPage(),
    const ViewStore(),
    const RequestsPage(),
  ];

  String? userName;
  String? userEmail;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    //initApp();
    if (user != null) {
      _loadUserData();
    }
  }

  void initApp(String area) async {
    // Initialize notification service
    await NotificationService().initializeNotification();
    debugPrint('Before the start Monitoring Bin');
    // Start monitoring bin heights
    FirestoreService.instance.monitorBinHeightAndNotify(area);
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
      userPhotoUrl = userData['photoUrl'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = MediaQuery.of(context).size.width <
        800; // Adjust the width as per your design

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(
                    FirebaseFirestore.instance
                        .collection('notifications')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
        title: Image.asset(
          'assets/images/greenRecyclear.png',
          // fit: BoxFit.cover,
          height:
              AppBar().preferredSize.height, // Match the height of the AppBar
        ),
      ),
      drawer: buildDrawer(isMobile),
      bottomNavigationBar: isMobile
          ? buildBottomNavigationBar()
          : null, // Bottom navigation bar for mobile only
      body: pageList[currentPageIndex],
    );
  }

  Widget buildDrawer(bool isMobile) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Center(
            child: UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ??
                  'Your Name'), // Replace with data fetched from Firestore
              accountEmail: Text(user?.email ??
                  'email@example.com'), // Replace with data fetched from Firestore
              currentAccountPicture: (userPhotoUrl != null)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(userPhotoUrl!),
                    )
                  : CircleAvatar(
                      child: Text(
                        userName != null ? userName![0] : 'U',
                        style: TextStyle(fontSize: 40.0),
                      ),
                    ),
            ),
          ),
          if (!isMobile) ...buildDrawerItems(), // Add drawer items for web
          if (isMobile) ...[
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create Truck Driver account '),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateDriverAccount()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.recycling_rounded),
              title: const Text('Add Bin'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddBin()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfile()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                // await authServices.signOut(); // Sign out the user
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // Navigate to login page
                );
              },
            ),
          ],
          if (!isMobile) ...[
            // Add Profile and Logout for web at the bottom
            Divider(),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                // Navigate to profile page
              },
            ),

            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () {
                // Handle user logout
              },
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> buildDrawerItems() {
    return [
      ListTile(
        leading: const Icon(Icons.map),
        title: const Text('Map'),
        onTap: () => selectPage(0),
      ),
      ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Dashboard'),
        onTap: () => selectPage(1),
      ),
      ListTile(
        leading: const Icon(Icons.store),
        title: const Text('Store'),
        onTap: () => selectPage(2),
      ),
      ListTile(
        leading: const Icon(Icons.announcement),
        title: const Text('Requests'),
        onTap: () => selectPage(3),
      ),
      // Add any other ListTile widgets for other drawer items
    ];
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
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Map',
        ),
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

  void selectPage(int index) {
    setState(() {
      currentPageIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }
}
