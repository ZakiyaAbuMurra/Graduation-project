import 'package:flutter/material.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/views/pages/login_page.dart';

class RequestsPageForGuest extends StatelessWidget {
  const RequestsPageForGuest({super.key});

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restricted Feature'),
          content:
              const Text('Please log in or sign up to access this feature.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Log In / Sign Up'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Contact Type',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.delete_outline,
                    userText: 'Have a bin',
                    userButtonLabel: 'Own a bin now!',
                    onTap: () => _showLoginPrompt(context),
                  ),
                ),
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.feedback_outlined,
                    userText: 'Submit feedback',
                    userButtonLabel: 'Send it now!',
                    onTap: () => _showLoginPrompt(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.report_outlined,
                    userText: 'Fault in the bin',
                    userButtonLabel: 'Report now!',
                    onTap: () => _showLoginPrompt(context),
                  ),
                ),
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.location_off_outlined,
                    userText: 'Incorrect bin location',
                    userButtonLabel: 'Report now!',
                    onTap: () => _showLoginPrompt(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.local_offer_outlined,
                    userText: 'Coupons problem',
                    userButtonLabel: 'Report now!',
                    onTap: () => _showLoginPrompt(context),
                  ),
                ),
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.calendar_month_outlined,
                    userText: 'Book to empty bin',
                    userButtonLabel: 'Book now!',
                    onTap: () => _showLoginPrompt(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ContactTypeBox extends StatelessWidget {
  final IconData icon;
  final String userText;
  final String userButtonLabel;
  final VoidCallback onTap;

  const ContactTypeBox({
    Key? key,
    required this.icon,
    required this.userText,
    required this.userButtonLabel,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxWidth = MediaQuery.of(context).size.width * 0.4;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: boxWidth,
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
                  userText,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onTap,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppColors.primary),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(AppColors.white),
                  alignment: Alignment.center,
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 47, 88, 69)
                            .withOpacity(0.5),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                child: Text(userButtonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
