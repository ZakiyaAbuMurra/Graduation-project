import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclear/utils/app_colors.dart'; // Update this import to your AppColors path

class UserStore extends StatefulWidget {
  const UserStore({super.key});

  @override
  State<UserStore> createState() => _UserStoreState();
}

class _UserStoreState extends State<UserStore> {
  int _currentStep = 0;
  int _currentImageIndex = 0;

  final List<String> _imagePaths = [
    'assets/images/shein.png',
    'assets/images/grandStores.jpg',
    'assets/images/abdeen1.jpg',
    'assets/images/carmelGym.jpg'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroDialog());
  }

  void _showIntroDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        _currentStep == 0
                            ? 'assets/images/map.png'
                            : 'assets/images/undraw_Gift_re_qr17.png',
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_currentStep == 0)
                      const Text(
                        'Welcome to RecyClear Store',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _currentStep == 0
                          ? 'In this section, you will be able to spend the coins you won from participation in the recycling process.'
                          : 'You will have the opportunity to use a voucher with certain discounts with our partners of various categories. \n \n After finishing your shopping process, you will be able to use the discount code, which will be available for 48 hours.',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: _currentStep == 0
                              ? AppColors.primary
                              : AppColors.grey,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: _currentStep == 1
                              ? AppColors.primary
                              : AppColors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_currentStep == 1)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep = 0;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              backgroundColor: AppColors.white,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            child: const Text('Back'),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentStep == 0) {
                              setState(() {
                                _currentStep = 1;
                              });
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: Text(
                            _currentStep == 0 ? 'Next' : 'Got it',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendCoupon(String email, String couponCode) async {
    // Implement email sending functionality here
    // Show success message after sending the email
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/success_image.png', height: 100),
              const SizedBox(height: 16),
              const Text(
                  'Discount sent to your email! \n Don\'t forget to check it before the time runs out!'),
            ],
          ),
        );
      },
    );
  }

  void _showCouponDialog(String couponCode) {
    TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _sendCoupon(emailController.text, couponCode);
                  Navigator.of(context).pop(); // Close the email input dialog
                },
                child: const Text('Send Discount'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> couponData) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: Image.network(couponData['imageUrl'], fit: BoxFit.cover),
        title: Text(couponData['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discount: ${couponData['discount']}%'),
            Text('Status: ${couponData['status']}'),
          ],
        ),
        onTap: () => _showCouponDialog(couponData['code']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double imageHeight = mediaQuery.size.height * 0.3;
    final double imageWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
      ),
      body: Column(
        children: [
          Column(
            children: [
              CarouselSlider(
                items: _imagePaths.map((path) {
                  return Container(
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Image.asset(
                          path,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _imagePaths.map((url) {
                  int index = _imagePaths.indexOf(url);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? AppColors.primary
                          : AppColors.grey,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('coupons').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching coupons'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No coupons available'));
                }

                final coupons = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                return ListView.builder(
                  itemCount: coupons.length,
                  itemBuilder: (context, index) {
                    return _buildCouponCard(coupons[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
