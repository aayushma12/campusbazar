import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payment_entity.dart';
import '../providers/payment_providers.dart';
import '../providers/payment_state.dart';

class PaymentHistoryPage extends ConsumerStatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  ConsumerState<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends ConsumerState<PaymentHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentNotifierProvider.notifier).fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (!mounted) return;
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

    final state = ref.watch(paymentNotifierProvider);

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
        title: const Text('Payment History'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(paymentNotifierProvider.notifier).fetchHistory(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(PaymentState state) {
    if (state.status == PaymentStateStatus.initiating && state.history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.history.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey)),
          SizedBox(height: 10),
          Center(child: Text('No transaction history yet')),
        ],
      );
    }

    return ListView.builder(
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final p = state.history[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text('Order: ${p.orderId.isEmpty ? '-': p.orderId}'),
            subtitle: Text(
              '${p.createdAt.toLocal()}\nTxn: ${p.transactionId}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${p.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _statusBadge(p.status),
              ],
            ),
            onTap: () => _showReceipt(context, p),
          ),
        );
      },
    );
  }

  Widget _statusBadge(PaymentStatus status) {
    final (label, color) = switch (status) {
      PaymentStatus.success => ('SUCCESS', Colors.green),
      PaymentStatus.failed => ('FAILED', Colors.red),
      PaymentStatus.pending => ('PENDING', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showReceipt(BuildContext context, Payment payment) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Transaction ID: ${payment.transactionId}'),
              Text('Order ID: ${payment.orderId.isEmpty ? '-' : payment.orderId}'),
              Text('Amount: \$${payment.amount.toStringAsFixed(2)}'),
              Text('Status: ${payment.status.name.toUpperCase()}'),
              Text('Date: ${payment.createdAt.toLocal()}'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
