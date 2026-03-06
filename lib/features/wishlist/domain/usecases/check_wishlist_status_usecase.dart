import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/wishlist_repository.dart';

class CheckWishlistStatusUseCase {
  final WishlistRepository repository;

  CheckWishlistStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(String productId) {
    return repository.isInWishlist(productId);
  }
}
