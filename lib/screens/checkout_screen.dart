import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'order_confirmation_screen.dart';
import '../providers/orders_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _deliveryOption = 'Delivery';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ...cart.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.quantity}x ${item.menuItem.name}'),
                                Text('₹${item.totalPrice.toStringAsFixed(2)}'),
                              ],
                            ),
                          )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Delivery options
              const Text(
                'Delivery Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RadioListTile<String>(
                title: const Text('Delivery'),
                value: 'Delivery',
                groupValue: _deliveryOption,
                onChanged: (value) {
                  setState(() {
                    _deliveryOption = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Pickup'),
                value: 'Pickup',
                groupValue: _deliveryOption,
                onChanged: (value) {
                  setState(() {
                    _deliveryOption = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Customer details
              const Text(
                'Customer Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              if (_deliveryOption == 'Delivery')
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_deliveryOption == 'Delivery' &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter your delivery address';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 30),

              // Place order button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _placeOrder(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('PLACE ORDER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    void _placeOrder(BuildContext context) {
    setState(() {
        _isProcessing = true;
    });

    // Simulate order processing delay
    Future.delayed(const Duration(seconds: 2), () {
        final cart = Provider.of<CartProvider>(context, listen: false);
        final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
        
        // Add order to history
        ordersProvider.addOrder(
        cartItems: cart.items,
        totalAmount: cart.totalAmount,
        customerName: _nameController.text,
        customerPhone: _phoneController.text,
        deliveryOption: _deliveryOption,
        deliveryAddress: _deliveryOption == 'Delivery' ? _addressController.text : '',
        );
        
        // Navigate to confirmation screen
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
            customerName: _nameController.text,
            deliveryOption: _deliveryOption,
            totalAmount: cart.totalAmount,
            ),
        ),
        );
        
        // Clear the cart after order is placed
        cart.clear();
    });
    }
}