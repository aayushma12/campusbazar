import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase {
  final WishlistRepository repository;

  RemoveFromWishlistUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId) {
    return repository.removeFromWishlist(productId);
  }
}
