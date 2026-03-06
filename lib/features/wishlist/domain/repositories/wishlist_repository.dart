import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wishlist_item_entity.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<WishlistItem>>> getWishlist();
  Future<Either<Failure, void>> addToWishlist(String productId);
  Future<Either<Failure, void>> removeFromWishlist(String productId);
  Future<Either<Failure, bool>> isInWishlist(String productId);
}
