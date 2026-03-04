import 'package:flutter/material.dart';

enum AppPaymentMethod { esewa, cod }

Future<AppPaymentMethod?> showPaymentMethodPicker(
  BuildContext context, {
  String title = 'Choose payment method',
}) {
  return showModalBottomSheet<AppPaymentMethod>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('eSewa'),
              subtitle: const Text('Pay securely online'),
              onTap: () => Navigator.of(context).pop(AppPaymentMethod.esewa),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Cash on Delivery (COD)'),
              subtitle: const Text('Pay when item is delivered/received'),
              onTap: () => Navigator.of(context).pop(AppPaymentMethod.cod),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
