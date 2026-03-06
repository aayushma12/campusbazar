import 'package:equatable/equatable.dart';

class ProductFilter extends Equatable {
  final String? keyword;
  final String? campus;
  final String? condition;
  final double? minPrice;
  final double? maxPrice;
  final String? category;
  final String? sortBy;
  final int page;
  final int limit;

  const ProductFilter({
    this.keyword,
    this.campus,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.category,
    this.sortBy,
    this.page = 1,
    this.limit = 12,
  });

  factory ProductFilter.initial() => const ProductFilter();

  ProductFilter copyWith({
    String? keyword,
    String? campus,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
    int? page,
    int? limit,
    bool clearKeyword = false,
    bool clearCampus = false,
    bool clearCondition = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCategory = false,
    bool clearSortBy = false,
  }) {
    return ProductFilter(
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
      campus: clearCampus ? null : (campus ?? this.campus),
      condition: clearCondition ? null : (condition ?? this.condition),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      category: clearCategory ? null : (category ?? this.category),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (keyword != null && keyword!.trim().isNotEmpty) count++;
    if (campus != null && campus!.trim().isNotEmpty) count++;
    if (condition != null && condition!.trim().isNotEmpty) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    if (category != null && category!.trim().isNotEmpty) count++;
    if (sortBy != null && sortBy!.trim().isNotEmpty) count++;
    return count;
  }

  @override
  List<Object?> get props => [
        keyword,
        campus,
        condition,
        minPrice,
        maxPrice,
        category,
        sortBy,
        page,
        limit,
      ];
}
