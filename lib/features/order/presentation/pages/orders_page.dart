import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/order_viewmodel.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderViewModelProvider.notifier).loadOrders(type: 'buyer');
    });
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      ref.read(orderViewModelProvider.notifier).loadOrders(
            type: _tabController.index == 0 ? 'buyer' : 'seller',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderViewModelProvider);
    final isBuyerTab = _tabController.index == 0;

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
        title: const Text('Orders', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          tabs: const [
            Tab(text: 'My Purchases'),
            Tab(text: 'My Sales'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.orders.isEmpty
              ? _emptyState(isBuyerTab)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    final status = order.orderStatus.isNotEmpty ? order.orderStatus.toLowerCase() : 'pending';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        leading: order.productImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  order.productImage,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
                                ),
                              )
                            : _fallbackIcon(),
                        title: Text(
                          order.productTitle.isNotEmpty ? order.productTitle : 'Order ${order.id.substring(0, 6)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Qty: ${order.quantity}  •  Rs ${order.totalPrice.toStringAsFixed(0)}'),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _badge(status.toUpperCase(), _statusColor(status)),
                                _badge(order.paymentMethod.toUpperCase(), Colors.blueGrey),
                                _badge(order.paymentStatus.toUpperCase(), _paymentColor(order.paymentStatus)),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/orderDetail',
                          arguments: order.id,
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _emptyState(bool isBuyerTab) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 10),
            Text(isBuyerTab ? 'No purchases yet' : 'No sales yet'),
            const SizedBox(height: 6),
            Text(
              isBuyerTab ? 'Place an order from checkout to see it here.' : 'Your confirmed sales will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: 52,
      height: 52,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'accepted':
      case 'confirmed':
      case 'reserved':
      case 'handed_over':
        return Colors.blue;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _paymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
