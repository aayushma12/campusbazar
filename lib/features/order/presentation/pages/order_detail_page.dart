import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/order_viewmodel.dart';
import '../state/order_state.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    final state = ref.watch(orderViewModelProvider);

    if (id == null) {
      return const Scaffold(body: Center(child: Text('No order selected')));
    }

    if (state.selectedOrder == null || state.selectedOrder!.id != id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(orderViewModelProvider.notifier).loadOrderDetail(id);
      });
    }

    final order = state.selectedOrder;
    final isLoading = state.isLoading || state.status == OrderStatusView.loading;
    final hasError = state.status == OrderStatusView.error;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
            }
          },
        ),
        title: const Text('Order Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage ?? 'Failed to load order details.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(orderViewModelProvider.notifier).loadOrderDetail(id),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : order == null
                  ? const Center(child: Text('No Order Found'))
                  : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${order.id}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (order.productTitle.isNotEmpty)
                    Text('Product: ${order.productTitle}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Status: ${order.status}'),
                  const SizedBox(height: 8),
                  Text('Quantity: ${order.quantity}'),
                  const SizedBox(height: 8),
                  Text('Unit Price: Rs ${order.price.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  Text('Total: Rs ${order.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Payment: ${order.paymentMethod} (${order.paymentStatus})'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final s in const ['accepted', 'rejected', 'handed_over', 'completed', 'cancelled'])
                        ActionChip(
                          label: Text(s),
                          onPressed: () {
                            ref.read(orderViewModelProvider.notifier).updateStatus(order.id, s);
                          },
                        ),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
