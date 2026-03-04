import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../booking/domain/entities/booking_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../providers/payment_providers.dart';
import '../providers/payment_state.dart';
import '../widgets/payment_method_picker.dart';
import 'payment_redirect_page.dart';

class BookingPaymentPage extends ConsumerWidget {
  final BookingEntity booking;

  const BookingPaymentPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(paymentNotifierProvider.notifier).clearMessages();
      }
    });

    final paymentState = ref.watch(paymentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/bookings', (route) => false);
            }
          },
        ),
        title: const Text('Booking Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.subject,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Session: ${booking.sessionType}'),
            Text('Hours: ${booking.hours}'),
            Text('Rate/Hour: \$${booking.ratePerHour.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            Text(
              'Total: \$${booking.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: paymentState.isBusy
                    ? null
                    : () async {
                        final method = await showPaymentMethodPicker(context);
                        if (!context.mounted || method == null) return;

                        if (method == AppPaymentMethod.cod) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking marked for cash payment at session time.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushNamedAndRemoveUntil(context, '/bookings', (route) => false);
                          return;
                        }

                        final payment = await ref
                            .read(paymentNotifierProvider.notifier)
                            .initiateBookingPayment(booking.id, booking.totalAmount);
                        if (payment == null || !context.mounted) return;

                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PaymentRedirectPage(
                              args: PaymentRedirectPageArgs(
                                payment: payment,
                                flowType: PaymentFlowType.booking,
                                bookingId: booking.id,
                              ),
                            ),
                          ),
                        );
                      },
                icon: paymentState.isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.payment),
                label: const Text('Pay Now (eSewa / COD)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
