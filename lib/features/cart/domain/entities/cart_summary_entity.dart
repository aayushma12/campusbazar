import 'package:equatable/equatable.dart';

class CartSummary extends Equatable {
  final double subtotal;
  final int totalItems;
  final int totalQuantity;

  const CartSummary({
    required this.subtotal,
    required this.totalItems,
    required this.totalQuantity,
  });

  const CartSummary.empty()
      : subtotal = 0,
        totalItems = 0,
        totalQuantity = 0;

  @override
  List<Object?> get props => [subtotal, totalItems, totalQuantity];
}
