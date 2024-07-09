import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recyclear/utils/app_colors.dart';

class DriverRequests extends StatefulWidget {
  const DriverRequests({super.key});

  @override
  State<DriverRequests> createState() => _DriverRequestsState();
}

class _DriverRequestsState extends State<DriverRequests> {
  final CollectionReference appointments = FirebaseFirestore.instance.collection('bin_empty_requests');

  Future<List<Map<String, dynamic>>> _getAppointments() async {
    QuerySnapshot snapshot = await appointments.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
  Future<void> _removeAppointment(String userId) async {
    QuerySnapshot snapshot = await appointments.where('user_id', isEqualTo: userId).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    setState(() {});  // Rebuild the widget to reflect the changes
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      backgroundColor: AppColors.bgColor,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          List<Map<String, dynamic>> appointments = snapshot.data!;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: List.generate(appointments.length, (index) {
                  var appointment = appointments[index];
                  return appointmentsWidget(
                    index,
                    appointment['bin location'] ?? 'Unknown location',
                    appointment['date'] ?? 'Unknown date',
                    appointment['time'] ?? 'Unknown time',
                    appointment['User email'] ?? '',
                    appointment['phone'] ?? 'Unknown phone',
                    appointment['user_id'],
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget appointmentsWidget(int index, String location, String date, String time, String email, String phone,String id) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.22,
        width: MediaQuery.of(context).size.width * 0.95,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 231, 231, 231),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.3),
              blurRadius: 3,
            )
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 10, right: 20),
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.22,
              width: 2,
              color: AppColors.primary,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 13),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.21,
                width: MediaQuery.of(context).size.width * 0.75,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 3.0, bottom: 5),
                        child: Text(
                          "Schedule bin emptying appointment.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: MediaQuery.of(context).size.height * 0.03,
                              color: AppColors.lineColors,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                location,
                                style: const TextStyle(
                                  color: AppColors.lineColors,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: MediaQuery.of(context).size.height * 0.03,
                              color: AppColors.lineColors,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                "$date | $time",
                                style: const TextStyle(
                                  color: AppColors.lineColors,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: MediaQuery.of(context).size.height * 0.03,
                              color: AppColors.lineColors,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                email.isEmpty ? "anonymous" : email,
                                style: const TextStyle(
                                  color: AppColors.lineColors,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: MediaQuery.of(context).size.height * 0.03,
                                  color: AppColors.lineColors,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    phone,
                                    style: const TextStyle(
                                      color: AppColors.lineColors,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: ()async {
                               await _removeAppointment(id);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.green, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.035,
                              child: const Text('Collect'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
