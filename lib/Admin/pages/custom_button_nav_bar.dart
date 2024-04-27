import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/dash_board_page.dart';
import 'package:recyclear/Admin/pages/map_page.dart';
import 'package:recyclear/Admin/pages/store_page.dart';
import 'package:recyclear/Admin/pages/users_request_page.dart';
import 'package:recyclear/utils/app_colors.dart';

class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({Key? key}) : super(key: key);

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  int currentPageIndex = 0;

  List<Widget> pageList = [
      MapSample(),
        DashBoard(),
        Store(),
        UsersRequest(),

  ];

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
        title: const Text('RecyClear App'),
      ),
      drawer: MediaQuery.of(context).size.width >= 800 ? buildDrawer() : null,
      bottomNavigationBar: MediaQuery.of(context).size.width < 800
          ? buildBottomNavigationBar()
          : null,
      body: pageList[currentPageIndex],
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Map'),
            onTap: () => selectPage(0),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('DashBoard'),
            onTap: () => selectPage(1),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Store'),
            onTap: () => selectPage(2),
          ),
          ListTile(
            leading: const Icon(Icons.announcement),
            title: const Text('Users Request'),
            onTap: () => selectPage(3),
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
