import 'package:flutter/material.dart';
import 'package:recyclear/User/coupons_problem_page.dart';
import 'package:recyclear/User/fault_in_bin_page.dart';
import 'package:recyclear/User/report_incorrect_bin_location_page.dart';
import 'package:recyclear/User/request_bin_page.dart';
import 'package:recyclear/User/submit_feedback_page.dart';
import 'package:recyclear/utils/app_colors.dart';

class UsersRequest extends StatelessWidget {
  const UsersRequest({super.key});

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
                  child: _buildContactTypeBox(
                    icon: Icons.delete_outline,
                    text: 'Have a bin',
                    buttonLabel: 'Own a bin now!',
                    buttonColor: AppColors.primary,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const RequestBinPage(),
                      ));
                    },
                  ),
                ),
                Expanded(
                  child: _buildContactTypeBox(
                    icon: Icons.feedback_outlined,
                    text: 'Submit feedback',
                    buttonLabel: 'Send it now!',
                    buttonColor: AppColors.primary,
                    onPressed: () {
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
                  child: _buildContactTypeBox(
                    icon: Icons.report_outlined,
                    text: 'Fault in the bin',
                    buttonLabel: 'Report now!',
                    buttonColor: AppColors.primary,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const FaultInBinPage(),
                      ));
                    },
                  ),
                ),
                Expanded(
                  child: _buildContactTypeBox(
                    icon: Icons.location_off_outlined,
                    text: 'Incorrect bin location',
                    buttonLabel: 'Report now!',
                    buttonColor: AppColors.primary,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ReportIncorrectBinPage(),
                      ));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildContactTypeBox(
              icon: Icons.local_offer_outlined,
              text: 'Coupons problem',
              buttonLabel: 'Report now!',
              buttonColor: AppColors.primary,
              onPressed: () {
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

  Widget _buildContactTypeBox({
    required IconData icon,
    required String text,
    required String buttonLabel,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
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
                //backgroundColor: Colors.grey[200],
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
              onPressed: onPressed,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
                foregroundColor:
                    MaterialStateProperty.all<Color>(AppColors.white),
                alignment: Alignment.center,
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(
                        color: const Color.fromARGB(255, 47, 88, 69)
                            .withOpacity(0.5),
                        width: 2.0),
                  ),
                ),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
