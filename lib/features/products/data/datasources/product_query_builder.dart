import '../../domain/entities/product_filter_entity.dart';

class ProductQueryBuilder {
  /// Build API query params from filter.
  ///
  /// - removes null/empty values
  /// - maps keyword -> search
  /// - maps sortBy to backend sort format (`field:asc|desc`)
  static Map<String, dynamic> toQuery(ProductFilter filter) {
    final query = <String, dynamic>{
      'page': filter.page,
      'limit': filter.limit,
    };

    void add(String key, dynamic value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isEmpty) return;
      query[key] = value;
    }

    add('search', filter.keyword);
    add('campus', filter.campus);
    add('condition', filter.condition);
    add('category', filter.category);

    if (filter.minPrice != null) query['minPrice'] = filter.minPrice;
    if (filter.maxPrice != null) query['maxPrice'] = filter.maxPrice;

    final sort = _mapSort(filter.sortBy);
    if (sort != null) {
      query['sort'] = sort;
    }

    return query;
  }

  static String? _mapSort(String? sortBy) {
    switch (sortBy) {
      case 'price_asc':
        return 'price:asc';
      case 'price_desc':
        return 'price:desc';
      case 'newest':
        return 'createdAt:desc';
      default:
        return null;
    }
  }
}
