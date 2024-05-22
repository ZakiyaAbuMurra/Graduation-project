import 'package:flutter/material.dart';
import 'package:recyclear/utils/app_colors.dart';

class ContactTypeBox extends StatelessWidget {
  final IconData icon;
  final String? userType;
  final String userText;
  final String adminText;
  final String userButtonLabel;
  final String adminButtonLabel;
  final Widget userPage;
  final Widget adminPage;

  const ContactTypeBox({
    Key? key,
    required this.icon,
    required this.userType,
    required this.userText,
    required this.adminText,
    required this.userButtonLabel,
    required this.adminButtonLabel,
    required this.userPage,
    required this.adminPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = userType == 'admin' ? adminText : userText;
    final buttonLabel = userType == 'admin' ? adminButtonLabel : userButtonLabel;
    final page = userType == 'admin' ? adminPage : userPage;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => page,
        ));
      },
      child: SizedBox(
        width: 150,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: AppColors.primary, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey.withOpacity(0.9),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(color: AppColors.primary, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Icon(icon, size: 30, color: AppColors.white),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => page,
                  ));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColors.primary),
                  foregroundColor: MaterialStateProperty.all<Color>(AppColors.white),
                  alignment: Alignment.center,
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 47, 88, 69).withOpacity(0.5),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
