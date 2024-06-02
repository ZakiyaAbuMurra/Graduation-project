/*
 this code sets up the initial state of the
 home screen for a Flutter application that
  monitors bin heights using Firestore and 
  notification services.
*/
import 'package:flutter/material.dart';
import 'package:recyclear/services/firestore_services.dart';
import 'package:recyclear/services/notification_service.dart';
import 'package:recyclear/views/widgets/add_bin_form.dart';

class AddBin extends StatefulWidget {
  @override
  _AddBinState createState() => _AddBinState();
}

class _AddBinState extends State<AddBin> {
  
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                          Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Goes back to the previous screen
                      },
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.75,
                      alignment: Alignment
                          .center, // Centers the image within the container
                    
                      // width: double.infinity,
                      child: Image.asset(
                        'assets/images/greenRecyclear.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:  EdgeInsets.only(
                    left: MediaQuery.of(context).size.width*0.05,
                    top:MediaQuery.of(context).size.height*0.02,
                    bottom: MediaQuery.of(context).size.height*0.02  ),
                  child: Text(
                    'Add Bin Page',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                  child: const AddBinForm(),
                ),
        ],)
        ,),),
    );
  }
}
