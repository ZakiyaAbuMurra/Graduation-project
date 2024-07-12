import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclear/utils/app_colors.dart';
import 'package:intl/intl.dart';

class UserStore extends StatefulWidget {
  const UserStore({super.key});

  @override
  State<UserStore> createState() => _UserStoreState();
}

class _UserStoreState extends State<UserStore> {
  int _currentStep = 0;
  int _currentImageIndex = 0;
  bool _showDialog = false;
  List<Map<String, dynamic>> _coupons = [];
  int _userPoints = 0;

  final List<String> _imagePaths = [
    'assets/images/shein.png',
    'assets/images/grandStores.jpg',
    'assets/images/abdeen1.jpg',
    'assets/images/carmelGym.jpg'
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser('UserStore');
    _fetchUserData();
  }

  Future<void> _checkFirstTimeUser(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = user.email!;
      String uniqueKey = '$email-$key';
      bool isFirstTime = prefs.getBool(uniqueKey) ?? true;

      if (isFirstTime) {
        await prefs.setBool(uniqueKey, false);
        setState(() {
          _showDialog = true;
        });
      }
    }
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData['type'] == 'user') {
          setState(() {
            _userPoints = userData['points'] ?? 0;
          });
          _fetchCouponsFromFirestore();
        }
      }
    }
  }

  Future<void> _fetchCouponsFromFirestore() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('coupones').get();
      List<Map<String, dynamic>> fetchedCoupons = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      print('Fetched Coupons: $fetchedCoupons'); // Add this line for debugging

      setState(() {
        _coupons = fetchedCoupons;
      });

      _loadCouponStatuses();
    } catch (e) {
      print("Error fetching coupons: $e");
    }
  }

  Future<void> _loadCouponStatuses() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      for (var coupon in _coupons) {
        bool hasUsed = await _hasUserUsedCoupon(coupon['code'], userId);
        if (hasUsed) {
          setState(() {
            coupon['status'] = 'Used';
          });
        } else {
          setState(() {
            coupon['status'] = _userPoints >= (coupon['discount'] ?? 0)
                ? 'Available'
                : 'Not enough points';
          });
        }
      }
    }
  }

  Future<void> _saveCouponUsage(String code, String userId) async {
    await FirebaseFirestore.instance.collection('user_coupons').add({
      'userId': userId,
      'couponCode': code,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> _hasUserUsedCoupon(String code, String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('user_coupons')
        .where('userId', isEqualTo: userId)
        .where('couponCode', isEqualTo: code)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _saveCouponStatus(
      String code, String status, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String statusKey = '${email}_coupon_$code';
    String timestampKey = '${email}_timestamp_$code';

    await prefs.setString(statusKey, status);
    if (status == 'Available') {
      await prefs.setString(timestampKey, DateTime.now().toIso8601String());
    }
  }

  Future<void> _updateUserPoints(int pointsToDeduct) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userDocRef);

        if (userDoc.exists) {
          int currentPoints = userDoc.get('points');
          int updatedPoints = currentPoints - pointsToDeduct;

          transaction.update(userDocRef, {'points': updatedPoints});

          setState(() {
            _userPoints = updatedPoints;
          });
        }
      });
    }
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

  void _showCouponDialog(Map<String, dynamic> couponData) {
    if (_userPoints < couponData['discount']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough points to redeem this coupon.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/cart.png',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Are you sure you want to spend your points on this code?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        couponData['imageUrl'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          couponData['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            String userId = user.uid;
                            setState(() {
                              couponData['status'] = 'Used';
                            });
                            await _saveCouponStatus(
                                couponData['code'], 'Used', user.email!);
                            await _updateUserPoints(couponData['discount']);
                            await _saveCouponUsage(couponData['code'], userId);
                            Navigator.of(context).pop(); // Close the dialog
                            _showSuccessDialog(couponData['code']);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        child: const Text('Get it now'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String couponCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Coupon Confirmed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset('assets/images/jumpingGirl.png', height: 100),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Here is the code: $couponCode',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '\nYou can present this code to any store branch for this product.',
                textAlign: TextAlign.center,
              ),
              const Text(
                '\nDon\'t forget to take a screenshot to enjoy using it!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> couponData) {
    return GestureDetector(
      onTap: () {
        if (couponData['status'] != 'Used' &&
            couponData['status'] != 'Expired') {
          _showCouponDialog(couponData);
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 120, // Adjusted width
                height: 120, // Adjusted height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(couponData['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10), // Space between image and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      couponData['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Discount: ${couponData['discount']}'),
                    Text('Status: ${couponData['status']}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double imageHeight = mediaQuery.size.height * 0.3;
    final double imageWidth = mediaQuery.size.width;

    if (_showDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showIntroDialog();
        setState(() {
          _showDialog = false;
        });
      });
    }

    return Scaffold(
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
            child: ListView.builder(
              itemCount: _coupons.length,
              itemBuilder: (context, index) {
                return _buildCouponCard(_coupons[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsDisplay extends StatelessWidget {
  final int points;

  const _PointsDisplay({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$points',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
