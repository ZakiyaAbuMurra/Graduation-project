import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/cubits/auth_cubit/auth_cubit.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/utils/route/app_routes.dart';
import 'package:recyclear/views/widgets/main_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  bool _rememberMe = false;

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Password: ${_passwordController.text}');
      await BlocProvider.of<AuthCubit>(context).signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
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
                    offset: const Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: const Icon(Icons.email_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0), // Reduces height
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
                    offset: const Offset(0, 2), // Changes position of shadow
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
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 1.0), // Adjust the height as needed
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none, // Hides the default border
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                  filled: true,
                  fillColor: Colors
                      .white, // The background color to show the shadow effectively
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showResetPasswordDialog(); // This will open the password reset dialog
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          const SizedBox(height: 10),
          BlocConsumer<AuthCubit, AuthState>(
            bloc: cubit,
            listenWhen: (previous, current) =>
                current is AuthSuccess || current is AuthFailure,
            listener: (context, state) {
              if (state is AuthSuccess) {
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
          const SizedBox(height: 16),
          const Row(
            children: <Widget>[
              Expanded(
                child: Divider(
                  thickness: 1,
                  endIndent: 10,
                ),
              ),
              Text(
                'or connect with',
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
          const SizedBox(height: 12), // Spacing between the buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    width: 100,
                    child: ElevatedButton.icon(
                      icon: Image.asset('assets/images/google.png',
                          height:
                              24.0), // Use an appropriate height for your logo
                      // Icon for Google
                      label: const Text('Google'),
                      onPressed: () {
                        // Google sign-in logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white, // Button background color
                        foregroundColor: Colors.black, // Text and icon color
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          // Make the button rectangular with rounded corners
                          borderRadius: BorderRadius.circular(
                              0), // Set the border radius to 0 for rectangular
                        ), // Removes shadow
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Spacing between the buttons
                Expanded(
                  child: SizedBox(
                    width: 10,
                    child: ElevatedButton.icon(
                      icon: const FaIcon(
                          FontAwesomeIcons.apple), // Icon for Apple
                      label: const Text('Apple'),
                      onPressed: () {
                        // Apple sign-in logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.white, // Button background color
                        foregroundColor: Colors.black, // Text and icon color
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          // Make the button rectangular with rounded corners
                          borderRadius: BorderRadius.circular(
                              0), // Set the border radius to 0 for rectangular
                        ), // Removes shadow
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: MainButton(
                child: Text('Continue as Guest'),
                bgColor: Colors.grey.withOpacity(0.4),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.guestHome);
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
        routeName = AppRoutes.bottomNavBardriver; // Update these constants as needed
        break;
      case 'admin':
        routeName = AppRoutes
            .bottomNavbar; // Make sure this route is defined in AppRouter
        break;
      case 'user':
        routeName = AppRoutes
            .bottomNavBarUser; // Make sure this route is defined in AppRouter
        break;
      default:
        routeName =
            AppRoutes.adminHome; // Make sure this route is defined in AppRouter
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
                    backgroundColor: AppColors
                        .primary, // Use the primary color from your AppColors
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
                      Navigator.of(context)
                          .pop(); // Close the dialog on success
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Password reset email sent!"),
                            backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      Navigator.of(context).pop(); // Close the dialog on error
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
                    backgroundColor: AppColors
                        .primary, // Use the primary color from your AppColors
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
