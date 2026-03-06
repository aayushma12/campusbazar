import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remote;

  WishlistRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<WishlistItem>>> getWishlist() async {
    try {
      final items = await remote.getWishlist();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(_msg(e)));
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist(String productId) async {
    try {
      await remote.addToWishlist(productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_msg(e)));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist(String productId) async {
    try {
      await remote.removeFromWishlist(productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_msg(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist(String productId) async {
    final listResult = await getWishlist();
    return listResult.fold(
      (failure) => Left(failure),
      (items) => Right(items.any((e) => e.productId == productId)),
    );
  }

  String _msg(Object e) {
    final text = e.toString().replaceAll('Exception: ', '').trim();
    return text.isEmpty ? 'Wishlist operation failed' : text;
  }
}
