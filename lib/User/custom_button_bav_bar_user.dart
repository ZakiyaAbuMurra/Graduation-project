import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/dash_board_page.dart';
import 'package:recyclear/Admin/pages/edit_profile.dart';
import 'package:recyclear/Admin/pages/store_page.dart';
import 'package:recyclear/User/about_us_page.dart';

import 'package:recyclear/User/dash_board_page.dart';
import 'package:recyclear/User/scan_qr_code_page.dart';
import 'package:recyclear/User/store_page.dart';

import 'package:recyclear/User/term_of_use_page.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/views/pages/requests_page_for_user_and_admain.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recyclear/views/pages/login_page.dart';

class CustomBottomNavbarUser extends StatefulWidget {
  const CustomBottomNavbarUser({super.key});

  @override
  State<CustomBottomNavbarUser> createState() => _CustomBottomNavbarUserState();
}

class _CustomBottomNavbarUserState extends State<CustomBottomNavbarUser> {
  int currentPageIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;

  List<Widget> pageList = [
    const UserDashBoard(),
    const UserStore(),
    QRCodeScannerView(),
    const RequestsPage(),
  ];

  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadUserData();
    }
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
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
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
          height: AppBar().preferredSize.height,
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
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: ListTile(
              title: Text(
                userName ?? 'Your Name',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                userEmail ?? 'email@example.com',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            title: Center(
              child: Image.asset(
                'assets/images/greenRecyclear.png',
                height: 80,
              ),
            ),
          ),
          const ListTile(
            title: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome to Recyclear App! Here you can track your recycling progress, and manage your recycling activities efficiently. Earn points for recycling and redeem coupons at your favorite stores!. Let’s make the world a greener place together!',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfile()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Use'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfUsePage()),
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
          icon: Icon(Icons.scanner_outlined),
          selectedIcon: Icon(Icons.scanner),
          label: 'Scanner',
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