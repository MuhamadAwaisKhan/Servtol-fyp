import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:servtol/util/AppColors.dart';

class CustomCardPaymentScreen extends StatefulWidget {
  final int amount;
  final String currency;
  final String serviceDescription;

  const CustomCardPaymentScreen({
    Key? key,
    required this.amount,
    required this.currency,
    required this.serviceDescription,
  }) : super(key: key);

  @override
  _CustomCardPaymentScreenState createState() =>
      _CustomCardPaymentScreenState();
}

class _CustomCardPaymentScreenState extends State<CustomCardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();

  final _cardNumberFormatter = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _expiryDateFormatter = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _csvFormatter = MaskTextInputFormatter(
    mask: '###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool isLoading = false;
  String paymentStatus = 'Pending';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  Future<void> processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        paymentStatus = 'Processing';
      });

      // Simulated payment process
      await Future.delayed(const Duration(seconds: 2));

      try {
        // Replace with actual payment logic
        final paymentSuccessful = (DateTime.now().second % 2 == 0); // Simulate random success or failure

        if (paymentSuccessful) {
          await FirebaseFirestore.instance.collection('card_payments').add({
            'card_number': _cardNumberController.text,
            'expiry_date': _expiryDateController.text,
            'cvv': _cvvController.text,
            'card_holder_name': _cardHolderNameController.text,
            'amount': widget.amount,
            'currency': widget.currency,
            'service_description': widget.serviceDescription,
            'payment_status': 'Success',
            'timestamp': FieldValue.serverTimestamp(),
          });

          setState(() {
            paymentStatus = 'Success';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            paymentStatus = 'Failed';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment failed. Please try again.')),
          );
        }
      } catch (e) {
        setState(() {
          paymentStatus = 'Failed';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Payment',
        style: TextStyle(fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
          color: AppColors.customButton,
        ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Info Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent.shade100, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Service Name and Total Amount Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.description,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Service: ${widget.serviceDescription}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              // const Icon(
                              //   Icons.attach_money,
                              //   size: 28,
                              //   color: Colors.white,
                              // ),
                              Text(
                                '\u20A8 ${(widget.amount / 100).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Extra Info (optional)
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Tap "Process Payment" to complete the transaction.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // Cardholder Name Field
                _buildTextField(
                  controller: _cardHolderNameController,
                  label: 'Cardholder Name',
                  hint: 'Full Name',
                  icon: Icons.person,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter cardholder name'
                      : null,
                ),

                const SizedBox(height: 20),

                // Card Number Field
                _buildTextField(
                  controller: _cardNumberController,
                  label: 'Card Number',
                  hint: 'xxxx xxxx xxxx xxxx',
                  icon: Icons.credit_card,
                  inputFormatters: [_cardNumberFormatter],
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter card number' : null,
                ),
                const SizedBox(height: 16),

                // Expiry Date Field
                _buildTextField(
                  controller: _expiryDateController,
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  icon: Icons.calendar_today,
                  inputFormatters: [_expiryDateFormatter],
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter expiry date' : null,
                ),
                const SizedBox(height: 16),

                // CVV Field
                _buildTextField(
                  controller: _cvvController,
                  label: 'CVV',
                  hint: 'xxx',
                  icon: Icons.lock,
                  inputFormatters: [_csvFormatter],
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter CVV' : null,
                ),
                // const SizedBox(height: 16),

                const SizedBox(height: 32),


                // Payment Status and Button
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Payment Status: $paymentStatus',
                        style: TextStyle(
                          color: _getPaymentStatusColor(paymentStatus),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            'Process Payment',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
      validator: validator,
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.grey;
      case 'Processing':
        return Colors.orange;
      case 'Success':
        return Colors.green;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
