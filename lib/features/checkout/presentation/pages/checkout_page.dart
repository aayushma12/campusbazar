import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/domain/entities/product_entity.dart';
import '../../presentation/state/checkout_state.dart';
import '../view_model/checkout_viewmodel.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final Product product;

  const CheckoutPage({super.key, required this.product});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutViewModelProvider);
    final notifier = ref.read(checkoutViewModelProvider.notifier);

    final total = widget.product.price * state.quantity;

    ref.listen<CheckoutState>(checkoutViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }

      if (next.successMessage != null && next.successMessage!.isNotEmpty &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productSummary(),
            const SizedBox(height: 14),
            _quantitySelector(state, notifier),
            const SizedBox(height: 14),
            _paymentMethodSelector(state, notifier),
            const SizedBox(height: 14),
            _collegeRuleNotice(state, notifier),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                title: const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: Text('Rs ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.isBusy
                    ? null
                    : () async {
                        final result = await notifier.placeOrder(widget.product);
                        if (!context.mounted || result == null) return;

                        await Navigator.pushNamed(context, '/orders');
                      },
                icon: state.isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(
                  state.paymentMethod == CheckoutPaymentMethod.esewa
                      ? 'Pay & Place Order'
                      : 'Place Order (COD)',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productSummary() {
    final firstImage = widget.product.images.isNotEmpty ? widget.product.images.first : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 82,
                height: 82,
                child: firstImage.isNotEmpty
                    ? Image.network(firstImage, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Price: Rs ${widget.product.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 2),
                  Text('Condition: ${widget.product.condition}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantitySelector(CheckoutState state, CheckoutViewModel notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Expanded(
              child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            OutlinedButton(
              onPressed: state.isBusy ? null : notifier.decreaseQuantity,
              child: const Icon(Icons.remove),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('${state.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            OutlinedButton(
              onPressed: state.isBusy ? null : notifier.increaseQuantity,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodSelector(CheckoutState state, CheckoutViewModel notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: RadioGroup<CheckoutPaymentMethod>(
          groupValue: state.paymentMethod,
          onChanged: (value) {
            if (state.isBusy) return;
            if (value != null) {
              notifier.setPaymentMethod(value);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const RadioListTile<CheckoutPaymentMethod>(
                value: CheckoutPaymentMethod.esewa,
                title: Text('eSewa'),
                subtitle: Text('Digital payment (simulated success flow)'),
              ),
              const RadioListTile<CheckoutPaymentMethod>(
                value: CheckoutPaymentMethod.cod,
                title: Text('Cash on Delivery'),
                subtitle: Text('Payment status will be Pending'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _collegeRuleNotice(CheckoutState state, CheckoutViewModel notifier) {
    return Card(
      color: Colors.green.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Community Delivery Rule', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Students must receive the product within the college community premises.'),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: state.acknowledgedCollegeRule,
              onChanged: state.isBusy ? null : (v) => notifier.setAcknowledgedCollegeRule(v ?? false),
              contentPadding: EdgeInsets.zero,
              title: const Text('I acknowledge this rule and agree to follow it.'),
            ),
          ],
        ),
      ),
    );
  }
}
