import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/cubits/auth_cubit/auth_cubit.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/utils/route/app_routes.dart';
import 'package:recyclear/views/widgets/main_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isVisible = true;
  bool isLogin = true;
  String? adminId;
  String? userName;
  String? userEmail;
  String? userPhotoUrl;

  String extractNameFromEmail(String email) {
    if (email.isEmpty) return 'Admin';
    String namePart = email.split('@')[0];
    return namePart[0].toUpperCase() + namePart.substring(1);
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Password: ${_passwordController.text}');
      await BlocProvider.of<AuthCubit>(context).signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      // Store the admin's ID if the user is an admin
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch the user's data to determine their type
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userType = userDoc.data()?['type'] as String?;
          if (userType == 'admin') {
            adminId = user.uid;
          }
        }
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Ensure adminId is initialized
      if (adminId == null) {
        debugPrint('Admin ID is not initialized');
        return;
      }

      debugPrint('Attempting to fetch data for Admin ID: $adminId');

      // Fetch admin data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('admin_info')
          .doc(adminId)
          .get();

      debugPrint('UserDoc exists: ${userDoc.exists}');

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        setState(() {
          userName = userData['displayName'] as String?;
          userEmail = userData['email'] as String?;
          userPhotoUrl = userData['photoURL'] as String?;
          // adminId is already set, no need to fetch again
        });

        // Logging to check values
        debugPrint('User Name: $userName');
        debugPrint('User Email: $userEmail');
        debugPrint('User Photo URL: $userPhotoUrl');
      } else {
        debugPrint('No user data found for Admin ID: $adminId');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  String? validatePassword(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    if (regExp.hasMatch(value)) {
      return null;
    } else {
      return 'Password must contain at least 8 characters, including uppercase, lowercase, number, and special character';
    }
  }

  String? validateEmail(String value) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(pattern);
    if (regExp.hasMatch(value)) {
      return null;
    } else {
      return 'Please enter a valid email';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: const Icon(Icons.email_outlined),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => validateEmail(value!),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_sharp),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                    icon: Icon(
                      _isVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 1.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: _isVisible,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
          ),
          if (isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showResetPasswordDialog();
                },
                child: const Text('Forgot Password?'),
              ),
            ),
          const SizedBox(height: 10),
          BlocConsumer<AuthCubit, AuthState>(
            bloc: cubit,
            listenWhen: (previous, current) =>
                current is AuthSuccess || current is AuthFailure,
            listener: (context, state) async {
              if (state is AuthSuccess) {
                if (state.userType == 'admin') {
                  // Get the current user
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Extract name from email
                    String userName = extractNameFromEmail(user.email ?? '');

                    // Store admin information in 'admin_info' collection
                    await FirebaseFirestore.instance
                        .collection('admin_info')
                        .doc(adminId)
                        .set({
                      'adminId': adminId, // Use the stored adminId
                      'email': user.email,
                      'displayName': userName,
                      'photoURL': user.photoURL,
                      'lastSignIn': FieldValue.serverTimestamp(),
                      // Uncomment the following line if you must store the password (not recommended)
                      // 'password': _passwordController.text,
                    }, SetOptions(merge: true));
                  }
                }
                navigateBasedOnUserType(state.userType!, context);
              } else if (state is AuthFailure) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: Text(state.message),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    });
              }
            },
            buildWhen: (previous, current) =>
                current is AuthLoading ||
                current is AuthFailure ||
                current is AuthSuccess ||
                current is AuthInitial,
            builder: (context, state) {
              if (state is AuthLoading) {
                return const MainButton(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: MainButton(
                  onPressed: login,
                  title: isLogin ? 'Login' : 'Register',
                ),
              );
            },
          ),
          const SizedBox(height: 7),
          if (!kIsWeb)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: MainButton(
                  child: Text(isLogin ? 'Sign Up' : 'Sign In'),
                  bgColor: AppColors.primary.withOpacity(0.4),
                  onPressed: () {
                    if (isLogin) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.register,
                      );
                    } else {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    }
                  },
                ),
              ),
            ),
          if (!kIsWeb) const SizedBox(height: 16),
          if (!kIsWeb)
            const Row(
              children: <Widget>[
                Expanded(
                  child: Divider(
                    thickness: 1,
                    endIndent: 10,
                  ),
                ),
                Text(
                  'or  continue as ',
                  style: TextStyle(
                    color: AppColors.black,
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    indent: 10,
                  ),
                ),
              ],
            ),
          if (!kIsWeb)
            const SizedBox(height: 12), // Spacing between the buttons

          if (!kIsWeb)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: MainButton(
                  child: Text('Guest'),
                  bgColor: Colors.grey.withOpacity(0.4),
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.guestHome);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void navigateBasedOnUserType(String userType, BuildContext context) {
    String routeName;
    switch (userType) {
      case 'driver':
        routeName = AppRoutes.bottomNavBardriver;
        break;
      case 'admin':
        routeName = AppRoutes.bottomNavbar;
        break;
      case 'user':
        routeName = AppRoutes.bottomNavBarUser;
        break;
      default:
        routeName = AppRoutes.adminHome;
        break;
    }
    Navigator.pushReplacementNamed(context, routeName);
  }

  void _showResetPasswordDialog() {
    final TextEditingController _resetEmailController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: const Text(
            'Reset Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address below to receive a password reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final email = _resetEmailController.text.trim();
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please enter your email address."),
                              backgroundColor: Colors.red),
                        );
                        return;
                      }
                      await _auth.sendPasswordResetEmail(email: email);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Password reset email sent!"),
                            backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Text('Send Reset Link',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        );
      },
    );
  }
}
