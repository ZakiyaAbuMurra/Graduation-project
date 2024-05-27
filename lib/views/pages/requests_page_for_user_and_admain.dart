import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/Admin/pages/view_feedback_page.dart';
import 'package:recyclear/User/coupons_problem_page.dart';
import 'package:recyclear/User/fault_in_bin_page.dart';
import 'package:recyclear/User/report_incorrect_bin_location_page.dart';
import 'package:recyclear/User/request_bin_page.dart';
import 'package:recyclear/User/submit_feedback_page.dart';
import 'package:recyclear/services/auth_service.dart';
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
                    userType: userType,
                    userText: 'Have a bin',
                    adminText: 'Manage bins',
                    userButtonLabel: 'Own a bin now!',
                    adminButtonLabel: 'Manage now!',
                    userPage: const RequestBinPage(),
                    adminPage: const RequestBinPage(),
                  ),
                ),
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.feedback_outlined,
                    userType: userType,
                    userText: 'Submit feedback',
                    adminText: 'View feedback',
                    userButtonLabel: 'Send it now!',
                    adminButtonLabel: 'View now!',
                    userPage: const SubmitFeedbackPage(),
                    adminPage:
                        ViewFeedbackPage(), // Replace with actual admin page
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
                    userType: userType,
                    userText: 'Fault in the bin',
                    adminText: 'Manage faults',
                    userButtonLabel: 'Report now!',
                    adminButtonLabel: 'Manage now!',
                    userPage: const FaultInBinPage(),
                    adminPage:
                        const FaultInBinPage(), // Replace with actual admin page
                  ),
                ),
                Expanded(
                  child: ContactTypeBox(
                    icon: Icons.location_off_outlined,
                    userType: userType,
                    userText: 'Incorrect bin location',
                    adminText: 'Manage locations',
                    userButtonLabel: 'Report now!',
                    adminButtonLabel: 'Manage now!',
                    userPage: const ReportIncorrectBinPage(),
                    adminPage:
                        const ReportIncorrectBinPage(), // Replace with actual admin page
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ContactTypeBox(
              icon: Icons.local_offer_outlined,
              userType: userType,
              userText: 'Coupons problem',
              adminText: 'Manage coupons',
              userButtonLabel: 'Report now!',
              adminButtonLabel: 'Manage now!',
              userPage: const CouponsProblemPage(),
              adminPage:
                  const CouponsProblemPage(), // Replace with actual admin page
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
