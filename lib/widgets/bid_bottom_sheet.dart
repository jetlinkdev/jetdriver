import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

/// Bid bottom sheet for submitting bids on orders
class BidBottomSheet {
  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    Order order,
  ) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BidBottomSheetContent(order: order),
    );
  }
}

class _BidBottomSheetContent extends StatefulWidget {
  final Order order;

  const _BidBottomSheetContent({required this.order});

  @override
  State<_BidBottomSheetContent> createState() => _BidBottomSheetContentState();
}

class _BidBottomSheetContentState extends State<_BidBottomSheetContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bidAmountController;
  late TextEditingController _etaController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bidAmountController = TextEditingController(
      text: widget.order.fare.toString(),
    );
    _etaController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _bidAmountController.dispose();
    _etaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Submit Bid',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Order summary
          _buildOrderSummary(currencyFormat),
          const SizedBox(height: 24),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Bid amount field
                _buildBidAmountField(currencyFormat),
                const SizedBox(height: 16),

                // ETA field
                _buildETAField(),
                const SizedBox(height: 24),

                // Submit button
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order #${widget.order.id}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.order.pickup,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.flag,
                size: 16,
                color: Color(0xFFFF4444),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.order.destination,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Base Fare: ${currencyFormat.format(widget.order.fare)}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidAmountField(NumberFormat currencyFormat) {
    return TextFormField(
      controller: _bidAmountController,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: 'Your Bid Price (IDR)',
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
        hintText: 'Enter your bid amount',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white38,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4CAF50),
          ),
        ),
        prefixText: 'Rp ',
        prefixStyle: const TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 16,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a bid amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildETAField() {
    return TextFormField(
      controller: _etaController,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: 'Estimated Arrival Time (minutes)',
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
        hintText: 'Enter minutes until arrival at pickup',
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white38,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4CAF50),
          ),
        ),
        suffixText: 'min',
        suffixStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter estimated time';
        }
        final minutes = int.tryParse(value);
        if (minutes == null || minutes <= 0) {
          return 'Please enter valid minutes';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit Bid',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bidPrice = double.parse(_bidAmountController.text);
    final etaMinutes = int.parse(_etaController.text);

    Navigator.pop(context, {
      'bidPrice': bidPrice,
      'etaMinutes': etaMinutes,
    });
  }
}
