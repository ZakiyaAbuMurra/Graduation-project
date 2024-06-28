import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCouponPage extends StatefulWidget {
  final DocumentSnapshot coupon;

  const EditCouponPage({super.key, required this.coupon});

  @override
  _EditCouponPageState createState() => _EditCouponPageState();
}

class _EditCouponPageState extends State<EditCouponPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _discountController;
  late TextEditingController _imageUrlController;

  late String initialCode;
  late String initialName;
  late String initialDiscount;
  late String initialImageUrl;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.coupon['code']);
    _nameController = TextEditingController(text: widget.coupon['name']);
    _discountController =
        TextEditingController(text: widget.coupon['discount'].toString());
    _imageUrlController =
        TextEditingController(text: widget.coupon['imageUrl']);

    initialCode = widget.coupon['code'];
    initialName = widget.coupon['name'];
    initialDiscount = widget.coupon['discount'].toString();
    initialImageUrl = widget.coupon['imageUrl'];
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _discountController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _codeController.text != initialCode ||
        _nameController.text != initialName ||
        _discountController.text != initialDiscount ||
        _imageUrlController.text != initialImageUrl;
  }

  Future<void> _editCoupon() async {
    if (_formKey.currentState!.validate()) {
      if (_hasChanges()) {
        try {
          await FirebaseFirestore.instance
              .collection('coupones')
              .doc(widget.coupon.id)
              .update({
            'code': _codeController.text,
            'name': _nameController.text,
            'discount': int.parse(_discountController.text),
            'imageUrl': _imageUrlController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coupon updated successfully')),
          );
          Navigator.of(context).pop(); // Navigate back to the previous screen
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update coupon: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes made')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Coupon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _discountController,
                decoration: InputDecoration(
                  labelText: 'Discount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a discount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _editCoupon,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
