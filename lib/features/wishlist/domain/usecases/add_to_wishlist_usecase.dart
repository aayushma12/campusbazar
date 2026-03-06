import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/wishlist_repository.dart';

class AddToWishlistUseCase {
  final WishlistRepository repository;

  AddToWishlistUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId) {
    return repository.addToWishlist(productId);
  }
}
