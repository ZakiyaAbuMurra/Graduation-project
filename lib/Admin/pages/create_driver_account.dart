import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recyclear/cubits/auth_cubit/auth_cubit.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/utils/route/app_routes.dart';
import 'package:recyclear/views/widgets/main_button.dart';

class CreateDriverAccount extends StatelessWidget {
  const CreateDriverAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Goes back to the previous screen
                      },
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment
                            .center, // Centers the image within the container
                        child: Image.asset(
                          'assets/images/greenRecyclear.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  'Create Driver Account ',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please, register!',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppColors.black.withOpacity(0.5),
                      ),
                ),
                const SizedBox(height: 16),
                const RegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  final _areaController = TextEditingController();
  final _truckNumberController = TextEditingController();

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
        'driver',
        _areaController.text,
        _truckNumberController.text,

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
              contentPadding: const EdgeInsets.symmetric(
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
                    ? Icons.visibility_outlined
                    : Icons.visibility_off),
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
              contentPadding: const EdgeInsets.symmetric(
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
          Text(
            'Driving Area',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          CustomDropdown(controller: _areaController),
          const SizedBox(height: 8),
          Text(
            'Truck number',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _truckNumberController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.drive_eta_outlined, // Example icon
                color: Colors.grey, // Icon color
              ),
              hintText: 'Enter the truck number ',
              contentPadding: const EdgeInsets.symmetric(

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
                Navigator.pushNamed(context, AppRoutes.bottomNavbar);
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

const governorates = [
  {'value': 'Jerusalem', 'label': 'Jerusalem'},
  {'value': 'Gaza', 'label': 'Gaza'},
  {'value': 'Hebron', 'label': 'Hebron'},
  {'value': 'Jenin', 'label': 'Jenin'},
  {'value': 'Tulkarem', 'label': 'Tulkarem'},
  {'value': 'Nablus', 'label': 'Nablus'},
  {'value': 'Ramallah and Al-Bireh', 'label': 'Ramallah and Al-Bireh'},
  {'value': 'Bethlehem', 'label': 'Bethlehem'},
  {'value': 'Qalqilya', 'label': 'Qalqilya'},
  {'value': 'Salfit', 'label': 'Salfit'},
  {'value': 'Jericho and Al Aghwar', 'label': 'Jericho and Al Aghwar'},
  {'value': 'Rafah', 'label': 'Rafah'},
  {'value': 'Khan Yunis', 'label': 'Khan Yunis'},
  {'value': 'Deir al-Balah', 'label': 'Deir al-Balah'},
  {'value': 'North Gaza', 'label': 'North Gaza'},
];

class CustomDropdown extends StatefulWidget {
  final TextEditingController controller;

  const CustomDropdown({Key? key, required this.controller}) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    setState(() {
      _isDropdownOpen = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: Container(
              height: 150.0, // Limit the height to show only three items
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: governorates.map((area) {
                  return ListTile(
                    title: Text(area['label'] as String),
                    onTap: () {
                      widget.controller.text = area['value'] as String;
                      _closeDropdown();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.home_work_outlined,
            color: Colors.grey,
          ),
          hintText: 'Select the area',
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          fillColor: Colors.grey[200],
          filled: true,
          suffixIcon: IconButton(
            icon: Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onPressed: _toggleDropdown,
          ),
        ),
        readOnly: true,
        onTap: _toggleDropdown,
      ),
    );
  }
}
