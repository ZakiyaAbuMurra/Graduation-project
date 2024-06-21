import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/cubits/auth_cubit/auth_cubit.dart';
import 'package:recyclear/utils/route/app_routes.dart';
import 'package:recyclear/views/widgets/main_button.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phototUrlController = TextEditingController();

  bool _isVisible = false;
  bool _isVisible_con = false;

  bool isLogin = true;

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Password: ${_passwordController.text}');
      await BlocProvider.of<AuthCubit>(context).signUpWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          _phoneController.text,
          _phototUrlController.text,
          'user',
          'No area',
          'No TRuck');
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
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<AuthCubit>(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UserName',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.person_2_outlined, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the name',
              filled: true, // Add a fill color
              fillColor: Colors.grey[200], // Light grey fill color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                borderSide: BorderSide.none, // No border
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0), // Padding inside the text field
            ),
            style: const TextStyle(
              fontSize: 16.0, // Slightly larger font size
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Email',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.email_outlined, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the Email',
              filled: true, // Add a fill color
              fillColor: Colors.grey[200], // Light grey fill color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                borderSide: BorderSide.none, // No border
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0), // Padding inside the text field
            ),
            style: const TextStyle(
              fontSize: 16.0, // Slightly larger font size
            ),
            validator: (value) => validateEmail(value!),
          ),
          const SizedBox(height: 8),
          Text(
            'Password',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isVisible,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the password',
              contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true, // Enable the fill color
              suffixIcon: IconButton(
                icon: Icon(
                  _isVisible
                      ? Icons.visibility
                      : Icons
                          .visibility_off_outlined, // Toggles the icon based on the password visibility
                ),
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password'; // Validation for empty field
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters'; // Validation for password length
              }
              return null; // Return null if the text is valid
            },
            style: const TextStyle(
                fontSize:
                    16), // Slightly larger font size for better readability
          ),
          const SizedBox(height: 8),
          Text(
            'Confirm Password',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Repeat password',
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isVisible_con = !_isVisible_con;
                  });
                },
                icon: Icon(_isVisible_con
                    ? Icons.visibility_off_outlined
                    : Icons.visibility),
              ),
            ),
            obscureText: _isVisible_con,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please confirm password';
              } else if (value != _passwordController.text) {
                // Check if passwords match
                return 'Passwords do not match';
              }
              return null; // Return null if the text is valid
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Phone number',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.phone, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter phone number',
              contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 12.0), // Padding inside the text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Rounded corners for the input field
              ),
              fillColor: Colors.grey[200], // A subtle fill color
              filled: true,
            ),
          ),
          const SizedBox(height: 15),
          BlocConsumer<AuthCubit, AuthState>(
            bloc: cubit,
            listenWhen: (previous, current) =>
                current is AuthSuccess || current is AuthFailure,
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pushNamed(context, AppRoutes.bottomNavBarUser);
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
              return MainButton(
                onPressed: register,
                title: 'Register',
              );
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              child:
                  Text(isLogin ? 'Already have an account? Login' : 'Register'),
              onPressed: () {
                if (isLogin) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.homeLogin,
                  );
                  // Assuming you're using named routes and '/register' is the route to your registration page.
                } else {
                  setState(() {
                    isLogin = !isLogin;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildTextFormField(
      TextEditingController controller, String label, String hintText,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            fillColor: Colors.grey[200],
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
