import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/utils/route/app_routes.dart'; // Ensure you have this file for AppColors.primary

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );

    Timer(Duration(seconds: 5), () {
       Navigator.pushNamed(
                        context,
                        AppRoutes.homeLogin,
                      );
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: 'Recyclear'.split('').map((letter) {
                if (letter == 'a') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ScaleTransition(
                      scale: _animation!,
                      child: Image.asset(
                        'assets/images/triangle.png',
                        height: 50,
                        width: 50,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
