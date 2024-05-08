import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/dash_board_page.dart';
import 'package:recyclear/Admin/pages/edit_profile.dart';
import 'package:recyclear/Admin/pages/map_page.dart';
import 'package:recyclear/Admin/pages/store_page.dart';
import 'package:recyclear/User/users_request_page.dart';
import 'package:recyclear/utils/app_colors.dart';

class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({super.key});

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar>
    with WidgetsBindingObserver {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      debugPrint('App is paused');
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('App is resumed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            // Custom Drawer Header with Decorated Box
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green, // Change color as needed
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recyclear',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Add a ListTile for your new page
            ListTile(
              leading: const Icon(Icons.person_2_rounded),
              title: const Text('Profile'), // Title of the drawer item
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                // Navigate to the new page
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      const EditProfile(), // Your new page widget
                ));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'RecyClear App',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: size.width >= 800
          ? null
          : NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.map),
                  icon: Icon(Icons.map_outlined),
                  label: 'Map',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.dashboard),
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'DashBoard',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.store),
                  icon: Icon(Icons.store_outlined),
                  label: 'Store',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.announcement),
                  icon: Icon(Icons.announcement_outlined),
                  label: 'Users Request',
                ),
              ],
            ),
      body: <Widget>[
        const MapSample(),
        const DashBoard(),
        const Store(),
        const UsersRequest(),
      ][currentPageIndex],
    );
  }
}
