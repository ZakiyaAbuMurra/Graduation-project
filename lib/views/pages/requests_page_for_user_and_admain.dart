import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/User/coupons_problem_page.dart';
import 'package:recyclear/User/fault_in_bin_page.dart';
import 'package:recyclear/User/report_incorrect_bin_location_page.dart';
import 'package:recyclear/User/request_bin_page.dart';
import 'package:recyclear/User/submit_feedback_page.dart';
import 'package:recyclear/services/auth_service.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:recyclear/views/widgets/contact_type_box.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  String? userType;

  @override
  void initState() {
    super.initState();
    _getUserType();
  }

  Future<void> _getUserType() async {
    User? currentUser = await AuthServicesImpl().currentUser();
    if (currentUser != null) {
      String? type = await AuthServicesImpl().getUserType(currentUser.uid);
      setState(() {
        userType = type;
      });
    }
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
                    text: 'Have a bin',
                    buttonLabel: 'Own a bin now!',
                    buttonColor: AppColors.primary,
                    onTap: () {
                      if (userType == 'user') {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RequestBinPage(),
                        ));
                      } else {
                        // Navigate to a different page or show a message for non-admin users
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.feedback_outlined,
                    text: 'Submit feedback',
                    buttonLabel: 'Send it now!',
                    buttonColor: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SubmitFeedbackPage(),
                      ));
                    },
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
                    text: 'Fault in the bin',
                    buttonLabel: 'Report now!',
                    buttonColor: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const FaultInBinPage(),
                      ));
                    },
                  ),
                ),
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.location_off_outlined,
                    text: 'Incorrect bin location',
                    buttonLabel: 'Report now!',
                    buttonColor: AppColors.primary,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ReportIncorrectBinPage(),
                      ));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ContactTypeBox(
              icon: Icons.local_offer_outlined,
              text: 'Coupons problem',
              buttonLabel: 'Report now!',
              buttonColor: AppColors.primary,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CouponsProblemPage(),
                ));
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
