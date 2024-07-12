import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:recyclear/Admin/pages/chat_page.dart';
import 'package:recyclear/cubits/chat_cubit/chat_cubit.dart';
import 'package:recyclear/models/bin_request.dart';
import 'package:recyclear/utils/app_colors.dart';

class ManageBinsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Requested Bins'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('bin_requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No bins found'));
          }

          var binRequests = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return BinRequest(
              address: data['address'] ?? 'No address',
              comments: data['comments'] ?? 'No comments',
              email: data['email'] ?? 'No email provided',
              phoneNumber: data['phoneNumber'] ?? 'No phone number provided',
              name: data['name'] ?? 'Anonymous',
              timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
            );
          }).toList();

          return ListView.builder(
            itemCount: binRequests.length,
            itemBuilder: (context, index) {
              final binRequest = binRequests[index];
              return BinRequestCard(binRequest: binRequest);
            },
          );
        },
      ),
    );
  }
}

class BinRequestCard extends StatefulWidget {
  final BinRequest binRequest;

  BinRequestCard({required this.binRequest});

  @override
  _BinRequestCardState createState() => _BinRequestCardState();
}

class _BinRequestCardState extends State<BinRequestCard> {
  bool isExpanded = false;

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.black, size: 30),
                const SizedBox(width: 10),
                Text(
                  widget.binRequest.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            infoRow(Icons.location_on, 'Address', widget.binRequest.address),
            const SizedBox(height: 5),
            infoRow(Icons.phone, 'Phone Number', widget.binRequest.phoneNumber),
            const SizedBox(height: 5),
            infoRow(
                Icons.access_time,
                'Timestamp',
                widget.binRequest.timestamp != null
                    ? DateFormat('yyyy-MM-dd – kk:mm')
                        .format(widget.binRequest.timestamp!)
                    : 'No timestamp'),
            const SizedBox(height: 5),
            if (isExpanded) ...[
              infoRow(Icons.comment, 'Comments', widget.binRequest.comments),
              const SizedBox(height: 5),
              infoRow(Icons.email, 'Email', widget.binRequest.email),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: toggleExpanded,
                  child: Text(
                    isExpanded ? 'Show Less' : 'Show More',
                    style: const TextStyle(fontSize: 14), // Reduced font size
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.lightBlack),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
