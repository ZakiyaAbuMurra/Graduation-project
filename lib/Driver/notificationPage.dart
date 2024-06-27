import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:recyclear/utils/app_colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isAppointment = false;
  bool isRequest = false;
  bool isAll = true;
  final CollectionReference notifications = FirebaseFirestore.instance.collection('notifications');

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.arrow_back_sharp,
        size: MediaQuery.of(context).size.width*0.065,
        color: AppColors.black,),
        title: const Align(
          alignment: Alignment.center,
          child:  Text("Notifications",style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.black
          ),),
        ),
        backgroundColor: AppColors.bgColor,
      ),
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.08,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Row(children: [
                      Padding(
                    padding:   EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02,
                    top: MediaQuery.of(context).size.height*0.02,
                    //right: MediaQuery.of(context).size.width*0.02 
                    ),
                    child: ElevatedButton(
                          onPressed: () {
                            if(mounted){
                              setState(() {
                                isAppointment = false;
                                isRequest = false;
                                isAll = true;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                           foregroundColor: isAll ? Colors.white : AppColors.primary, // Text color based on isAppointment
                           backgroundColor: isAll ? AppColors.primary : Colors.white, // Background color based on isAppointment
                            side: const BorderSide(color: AppColors.green, width: 2), // Border color and width
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18), // Border radius
                            ),
                            
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.035,
                            child: Text('Bins Status')),
                        ),
                  ),
                  Padding(
                    padding:   EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02,
                    top: MediaQuery.of(context).size.height*0.02,
                    //right: MediaQuery.of(context).size.width*0.02 
                    ),
                    child: ElevatedButton(
                          onPressed: () {
                            if(mounted){
                              setState(() {
                                isAppointment = true;
                                isRequest = false;
                                isAll = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                           foregroundColor: isAppointment ? Colors.white : AppColors.primary, // Text color based on isAppointment
                           backgroundColor: isAppointment ? AppColors.primary : Colors.white, // Background color based on isAppointment
                            side: const BorderSide(color: AppColors.green, width: 2), // Border color and width
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18), // Border radius
                            ),
                            
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.035,
                            child: Text('Appointments')),
                        ),
                  ),
                
                      Padding(
                    padding:   EdgeInsets.only(left: MediaQuery.of(context).size.width*0.02,
                    top: MediaQuery.of(context).size.height*0.02,
                    right: MediaQuery.of(context).size.width*0.02 
                    ),
                    child: ElevatedButton(
                          onPressed: () {
                            if(mounted){
                              setState(() {
                                isAppointment = false;
                                isRequest = true;
                                isAll = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                           foregroundColor: isRequest ? Colors.white : AppColors.primary, // Text color based on isAppointment
                           backgroundColor: isRequest ? AppColors.primary : Colors.white, // Background color based on isAppointment
                            side: const BorderSide(color: AppColors.green, width: 2), // Border color and width
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18), // Border radius
                            ),
                            
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.035,
                            child: Text('Requests')),
                        ),
                  ),
                ],),
              ],
            ),
          ),

          binStatus(),

        ],),),
    );
  }

Widget binStatus(){
  return  Padding(
    padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02),
    child: Container(
      height: MediaQuery.of(context).size.height*0.13,
      width: MediaQuery.of(context).size.width*0.87,
       
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 231, 231, 231),
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.3),
            blurRadius: 3,
          )
        ]
      ),
      child: const Column(children: [


      ],),

    
    ),
  );
}
}