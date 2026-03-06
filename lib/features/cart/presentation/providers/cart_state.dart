import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';

enum CartStatus {
  initial,
  loading,
  loaded,
  updating,
  clearing,
  error,
}

class CartState {
  final CartStatus status;
  final List<CartItem> items;
  final CartSummary summary;
  final Set<String> updatingProductIds;
  final String? errorMessage;
  final String? successMessage;
  final bool unauthorized;

  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.summary = const CartSummary.empty(),
    this.updatingProductIds = const {},
    this.errorMessage,
    this.successMessage,
    this.unauthorized = false,
  });

  bool get isEmpty => items.isEmpty;
  bool isUpdating(String productId) => updatingProductIds.contains(productId);

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    CartSummary? summary,
    Set<String>? updatingProductIds,
    String? errorMessage,
    String? successMessage,
    bool? unauthorized,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      updatingProductIds: updatingProductIds ?? this.updatingProductIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      unauthorized: unauthorized ?? this.unauthorized,
    );
  }
}
