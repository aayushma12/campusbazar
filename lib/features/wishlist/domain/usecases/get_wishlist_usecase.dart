import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase {
  final WishlistRepository repository;

  GetWishlistUseCase(this.repository);

  Future<Either<Failure, List<WishlistItem>>> call() {
    return repository.getWishlist();
  }
}
