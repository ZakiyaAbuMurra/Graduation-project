import 'package:flutter/material.dart';
import 'package:recyclear/Guest/requests_page_for_guest.dart';
import 'package:recyclear/User/about_us_page.dart';
import 'package:recyclear/User/dash_board_page.dart';
import 'package:recyclear/User/scan_qr_code_page.dart';
import 'package:recyclear/User/store_page.dart';
import 'package:recyclear/User/term_of_use_page.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/views/pages/login_page.dart';

class GuestBottomNavbar extends StatefulWidget {
  const GuestBottomNavbar({super.key});

  @override
  State<GuestBottomNavbar> createState() => _GuestBottomNavbarState();
}

class _GuestBottomNavbarState extends State<GuestBottomNavbar> {
  int currentPageIndex = 0;

  List<Widget> pageList = [
    const UserDashBoard(),
    const UserStore(),
    QRCodeScannerView(), // Placeholder for Scanner page
    const RequestsPageForGuest(), // Using the same page but with restrictions
  ];

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restricted Feature'),
          content:
              const Text('Please log in or sign up to access this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Log In / Sign Up'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
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
      body: IndexedStack(
        index: currentPageIndex,
        children: pageList,
      ),
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
            child: const ListTile(
              title: Text(
                'Guest User',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                'Hello Guest',
                style: TextStyle(
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
                'Welcome to Recyclear App! As a guest, you can browse the app. Please log in to access all features.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
            title: const Text('Login / Sign Up'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  NavigationBar buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: currentPageIndex,
      onDestinationSelected: (int index) {
        if (index == 2) {
          // Scanner and Requests pages
          _showLoginPrompt(context);
        } else {
          setState(() {
            currentPageIndex = index;
          });
        }
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
