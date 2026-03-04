import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/payment_entity.dart';

class PaymentSuccessPage extends StatelessWidget {
  final Payment payment;
  final PaymentFlowType flowType;

  const PaymentSuccessPage({
    super.key,
    required this.payment,
    required this.flowType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
            }
          },
        ),
        title: const Text('Payment Success'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, size: 72, color: Colors.green),
            const SizedBox(height: 10),
            const Text(
              'Payment completed successfully',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            _tile('Transaction ID', payment.transactionId),
            _tile('Order ID', payment.orderId.isEmpty ? '-' : payment.orderId),
            _tile('Amount', '\$${payment.amount.toStringAsFixed(2)}'),
            _tile('Method', payment.paymentMethod),
            _tile('Status', payment.status.name.toUpperCase()),
            const SizedBox(height: 8),
            if (flowType == PaymentFlowType.cart)
              const Text(
                'Your cart has been cleared after successful payment.',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            if (flowType == PaymentFlowType.cartItem)
              const Text(
                'Purchased cart item has been removed from your cart.',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            if (flowType == PaymentFlowType.booking)
              const Text(
                'Booking payment completed. You can review it in your bookings.',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: payment.transactionId));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction ID copied')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy ID'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      if (flowType == PaymentFlowType.booking) {
                        Navigator.pushNamedAndRemoveUntil(context, '/bookings', (route) => false);
                        return;
                      }

                      if (flowType == PaymentFlowType.cart || flowType == PaymentFlowType.cartItem) {
                        Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
                        return;
                      }

                      Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: Text(flowType == PaymentFlowType.booking ? 'Go to Bookings' : 'Go to Orders'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
