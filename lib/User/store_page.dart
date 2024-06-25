import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final List<String> _imagePaths = [
    'assets/images/shein.png',
    'assets/images/grandStores.jpg',
    'assets/images/abdeen1.jpg',
    'assets/images/carmelGym.jpg'
  ];

  final List<Map<String, dynamic>> _coupons = [
    {
      'name': 'Carmel GYM',
      'discount': 10,
      'status': 'Available',
      'imageUrl': 'assets/images/sGYM1.jpg',
      'code': 'Carmel123Recyclear',
      'timestamp': DateTime.now().toIso8601String()
    },
    {
      'name': 'SheGLAM',
      'discount': 20,
      'status': 'Available',
      'imageUrl': 'assets/images/sheglam.jpg',
      'code': 'SheGlam123Recyclear',
      'timestamp': DateTime.now().toIso8601String()
    },
    {
      'name': 'Abdeen Elite Home',
      'discount': 20,
      'status': 'Available',
      'imageUrl': 'assets/images/abdeen3.jpg',
      'code': 'Abdeen123Recyclear1',
      'timestamp': DateTime.now().toIso8601String()
    },
    {
      'name': 'SHEIN',
      'discount': 10,
      'status': 'Available',
      'imageUrl': 'assets/images/shein1.jpg',
      'code': 'SHEIN123Recyclear1',
      'timestamp': DateTime.now().toIso8601String()
    },
    {
      'name': 'Carmel GYM',
      'discount': 10,
      'status': 'Available',
      'imageUrl': 'assets/images/sGYM2.jpg',
      'code': 'Carmel123Recyclear2',
      'timestamp': DateTime.now().toIso8601String()
    },
    {
      'name': 'Abdeen Elite Home',
      'discount': 20,
      'status': 'Used',
      'imageUrl': 'assets/images/abdeen2.jpeg',
      'code': 'Abdeen123Recyclear2',
      'timestamp': DateTime.now().toIso8601String()
    },
    {
      'name': 'Grand Stores',
      'discount': 15,
      'status': 'Expired',
      'imageUrl': 'assets/images/Grandestore1.jpg',
      'code': 'Grand123Recyclear',
      'timestamp': DateTime.now().toIso8601String()
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
    _loadCouponStatuses();
  }

  Future<void> _checkFirstTimeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = user.email!;
      bool isFirstTime = prefs.getBool(email) ?? true;

      if (isFirstTime) {
        setState(() async {
          _showDialog = true;
          await prefs.setBool(email, false);
        });
      }
    }
  }

  Future<void> _loadCouponStatuses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = user.email!;
      for (var coupon in _coupons) {
        String statusKey = '${email}_coupon_${coupon['code']}';
        String timestampKey = '${email}_timestamp_${coupon['code']}';

        String? status = prefs.getString(statusKey);
        String? timestamp = prefs.getString(timestampKey);

        if (status != null && timestamp != null) {
          DateTime couponTime = DateTime.parse(timestamp);
          DateTime now = DateTime.now();
          if (now.difference(couponTime).inDays >= 7) {
            status = 'Expired';
            await _saveCouponStatus(coupon['code'], 'Expired', email);
          }
          setState(() {
            coupon['status'] = status;
          });
        }
      }
    }
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
                      Image.asset(
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
                            String email = user.email!;
                            setState(() {
                              couponData['status'] = 'Used';
                            });
                            await _saveCouponStatus(
                                couponData['code'], 'Used', email);
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
                    image: AssetImage(couponData['imageUrl']),
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
                    Text('Discount: ${couponData['discount']}%'),
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroDialog());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
