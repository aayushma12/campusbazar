import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../payment/domain/entities/payment_entity.dart';
import '../../../payment/presentation/pages/payment_redirect_page.dart';
import '../../../payment/presentation/providers/payment_providers.dart';
import '../../../payment/presentation/providers/payment_state.dart';
import '../../../payment/presentation/widgets/payment_method_picker.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../../core/services/service_locator.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/cart_providers.dart';
import '../providers/cart_state.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _isCodCheckout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartNotifierProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CartState>(cartNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(cartNotifierProvider.notifier).clearMessages();
      }

      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: Colors.green),
        );
        ref.read(cartNotifierProvider.notifier).clearMessages();
      }
    });

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
        return;
      }

      if (next.infoMessage != null && next.infoMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.infoMessage!), backgroundColor: Colors.blueGrey),
        );
        ref.read(paymentNotifierProvider.notifier).clearMessages();
      }
    });

    final state = ref.watch(cartNotifierProvider);
    final paymentState = ref.watch(paymentNotifierProvider);

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
        title: const Text('Cart', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: state.items.isEmpty || state.status == CartStatus.clearing
                ? null
                : () => ref.read(cartNotifierProvider.notifier).clearCart(),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(cartNotifierProvider.notifier).loadCart(),
        child: _buildBody(state, paymentState),
      ),
    );
  }

  Widget _buildBody(CartState state, PaymentState paymentState) {
    if (state.status == CartStatus.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.shopping_cart_outlined, size: 82, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Center(
            child: Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 6),
          const Center(child: Text('Looks like you have not added any products yet.')),
          const SizedBox(height: 18),
          Center(
            child: FilledButton.tonal(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              child: const Text('Browse Products'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 6, bottom: 8),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return CartItemTile(
                item: item,
                isUpdating: state.isUpdating(item.productId),
                isPaying: paymentState.isCartFlowBusy || _isCodCheckout,
                onIncrement: () {
                  ref.read(cartNotifierProvider.notifier).updateQuantity(item.productId, item.quantity + 1);
                },
                onDecrement: item.quantity == 1
                    ? null
                    : () {
                        ref.read(cartNotifierProvider.notifier).updateQuantity(item.productId, item.quantity - 1);
                      },
                onRemove: () {
                  ref.read(cartNotifierProvider.notifier).removeItem(item.productId);
                },
                onPayNow: () async {
                  final method = await showPaymentMethodPicker(context);
                  if (!context.mounted || method == null) return;

                  final validation = await ref.read(cartNotifierProvider.notifier).validateSingleItemCheckout(item);
                  if (!context.mounted) return;
                  if (validation != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(validation), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  if (method == AppPaymentMethod.cod) {
                    await _placeSingleCodOrder(item);
                    return;
                  }

                  final payment = await ref.read(paymentNotifierProvider.notifier).initiateCartPayment([item]);
                  if (!context.mounted || payment == null) return;

                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PaymentRedirectPage(
                        args: PaymentRedirectPageArgs(
                          payment: payment,
                          flowType: PaymentFlowType.cartItem,
                          purchasedProductId: item.productId,
                        ),
                      ),
                    ),
                  );

                  if (!context.mounted) return;
                  ref.read(paymentNotifierProvider.notifier).resetFlow();
                },
              );
            },
          ),
        ),
        _summarySection(state, paymentState),
      ],
    );
  }

  Widget _summarySection(CartState state, PaymentState paymentState) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 15, color: Colors.black87)),
                Text(
                  'Rs ${state.summary.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${state.summary.totalItems} item(s) • ${state.summary.totalQuantity} quantity',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: paymentState.isCartFlowBusy || _isCodCheckout
                    ? null
                    : () async {
                  final method = await showPaymentMethodPicker(context);
                  if (!context.mounted || method == null) return;

                  final error = await ref.read(cartNotifierProvider.notifier).validateCheckout();
                  if (!mounted) return;

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  if (method == AppPaymentMethod.cod) {
                    await _placeFullCodOrder(state);
                    return;
                  }

                  final payment = await ref.read(paymentNotifierProvider.notifier).initiateCartPayment(state.items);
                  if (!mounted || payment == null) return;

                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PaymentRedirectPage(
                        args: PaymentRedirectPageArgs(
                          payment: payment,
                          flowType: PaymentFlowType.cart,
                        ),
                      ),
                    ),
                  );

                  if (!mounted) return;
                  ref.read(paymentNotifierProvider.notifier).resetFlow();
                },
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeSingleCodOrder(CartItem item) async {
    setState(() => _isCodCheckout = true);

    try {
      final orderRepo = sl<OrderRepository>();
      await orderRepo.createOrder(
        productId: item.productId,
        price: item.productPrice,
        quantity: item.quantity,
        paymentMethod: 'COD',
        paymentStatus: 'Pending',
        orderStatus: 'pending',
        sellerId: item.sellerId,
        acknowledgedCollegeRule: true,
      );

      await ref.read(cartNotifierProvider.notifier).removeItem(item.productId);
      await ref.read(cartNotifierProvider.notifier).loadCart();
      await ref.read(productsNotifierProvider.notifier).refresh();
      await ref.read(dashboardNotifierProvider.notifier).loadProducts();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('COD order placed successfully.'), backgroundColor: Colors.green),
      );
      Navigator.pushNamed(context, '/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isCodCheckout = false);
    }
  }

  Future<void> _placeFullCodOrder(CartState state) async {
    setState(() => _isCodCheckout = true);

    try {
      final orderRepo = sl<OrderRepository>();
      final createdOrders = await orderRepo.createBulkCodOrders(
        items: state.items
            .map(
              (item) => {
                'productId': item.productId,
                'quantity': item.quantity,
                'price': item.productPrice,
              },
            )
            .toList(),
      );

          await ref.read(cartNotifierProvider.notifier).clearCart();
      await ref.read(cartNotifierProvider.notifier).loadCart();
      await ref.read(productsNotifierProvider.notifier).refresh();
      await ref.read(dashboardNotifierProvider.notifier).loadProducts();

      if (!mounted) return;
      if (createdOrders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No COD orders could be placed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Placed ${createdOrders.length} COD order(s) successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamed(context, '/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isCodCheckout = false);
    }
  }
}
