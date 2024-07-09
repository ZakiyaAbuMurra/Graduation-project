import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/custom_button_nav_bar.dart';
import 'package:recyclear/Driver/custom_button_nav_bar_driver.dart';
import 'package:recyclear/Driver/driver_home.dart';
import 'package:recyclear/Driver/driverRequest.dart';
import 'package:recyclear/Guest/guest_home.dart';
import 'package:recyclear/User/custom_button_bav_bar_user.dart';
import 'package:recyclear/utils/route/app_routes.dart';
import 'package:recyclear/views/pages/login_page.dart';
import 'package:recyclear/views/pages/register_page.dart';
import 'package:recyclear/views/pages/requests_page_for_user_and_admain.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homeLogin:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRoutes.guestHome:
        return MaterialPageRoute(
            builder: (_) => GuestBottomNavbar(), settings: settings);

      case AppRoutes.bottomNavbar:
        return MaterialPageRoute(
          builder: (_) => const CustomBottomNavbar(),
          settings: settings,
        );
      case AppRoutes.bottomNavBarUser:
        return MaterialPageRoute(
          builder: (_) => const CustomBottomNavbarUser(),
          settings: settings,
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case AppRoutes.driverHome:
        return MaterialPageRoute(
          builder: (_) => const driverHome(),
          settings: settings,
        );
      case AppRoutes.bottomNavBardriver:
        return MaterialPageRoute(
          builder: (_) => const DriverBottomNavbarUser(),
          settings: settings,
        );

      case AppRoutes.userHome:
        return MaterialPageRoute(
          builder: (_) => const RequestsPage(),
          settings: settings,
        );

        case AppRoutes.driverRequests:
        return MaterialPageRoute(
          builder: (_) => const DriverRequests(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Error Page hmmmmmm!'),
            ),
          ),
        );
    }
  }
}
