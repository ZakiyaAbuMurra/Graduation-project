import 'package:flutter/material.dart';
import 'package:graduation_project/Admin/pages/dash_board_page.dart';
import 'package:graduation_project/Admin/pages/map_page.dart';
import 'package:graduation_project/Admin/pages/store_page.dart';
import 'package:graduation_project/Admin/pages/users_request_page.dart';
import 'package:graduation_project/utils/app_colors.dart';

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
      drawer: const Drawer(
        child: Center(
          child: Text('Inside the drawer!'),
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
      body: const <Widget>[
        MapPage(),
        DashBoard(),
        Store(),
        UsersRequest(),
      ][currentPageIndex],
    );
  }
}
