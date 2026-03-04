import '../../domain/entities/wishlist_item_entity.dart';

enum WishlistStatus {
  initial,
  loading,
  loaded,
  updating,
  error,
}

class WishlistState {
  final WishlistStatus status;
  final List<WishlistItem> items;
  final String? errorMessage;
  final bool unauthorized;
  final Set<String> updatingProductIds;

  const WishlistState({
    this.status = WishlistStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.unauthorized = false,
    this.updatingProductIds = const {},
  });

  bool isInWishlist(String productId) => items.any((e) => e.productId == productId);
  bool isUpdating(String productId) => updatingProductIds.contains(productId);

  WishlistState copyWith({
    WishlistStatus? status,
    List<WishlistItem>? items,
    String? errorMessage,
    bool? unauthorized,
    Set<String>? updatingProductIds,
    bool clearError = false,
  }) {
    return WishlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : errorMessage,
      unauthorized: unauthorized ?? this.unauthorized,
      updatingProductIds: updatingProductIds ?? this.updatingProductIds,
    );
  }
}
