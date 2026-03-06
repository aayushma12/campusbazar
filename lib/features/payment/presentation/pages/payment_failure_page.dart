import 'package:flutter/material.dart';

import '../../domain/entities/payment_entity.dart';

class PaymentFailurePage extends StatelessWidget {
  final PaymentFlowType flowType;
  final String message;

  const PaymentFailurePage({
    super.key,
    required this.flowType,
    required this.message,
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
        title: const Text('Payment Failed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cancel, size: 72, color: Colors.red),
            const SizedBox(height: 10),
            const Text(
              'Payment could not be completed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: Colors.black87)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Payment'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (flowType == PaymentFlowType.cart) {
                    Navigator.pushNamedAndRemoveUntil(context, '/cart', (route) => false);
                  } else if (flowType == PaymentFlowType.cartItem) {
                    Navigator.pushNamedAndRemoveUntil(context, '/cart', (route) => false);
                  } else if (flowType == PaymentFlowType.booking) {
                    Navigator.pushNamedAndRemoveUntil(context, '/bookings', (route) => false);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, '/products', (route) => false);
                  }
                },
                icon: const Icon(Icons.arrow_back),
                label: Text(
                  flowType == PaymentFlowType.cart || flowType == PaymentFlowType.cartItem
                      ? 'Back to Cart'
                      : flowType == PaymentFlowType.booking
                          ? 'Back to Bookings'
                          : 'Back to Products',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
