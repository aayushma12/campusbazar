# Products Module (Clean Architecture)

This module is implemented under:

```text
lib/features/products/
  data/
    models/
    datasources/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    pages/
    widgets/
    providers/
```

## APIs used

### Fetch products

- **Method:** `GET`
- **Endpoint:** `/api/v1/products`
- **Query:** `page`, `limit`
- **Response:**

```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "title": "...",
      "description": "...",
      "price": 99,
      "condition": "good",
      "status": "available",
      "images": ["..."],
      "ownerId": { "_id": "...", "name": "...", "email": "..." },
      "categoryId": { "_id": "...", "name": "..." },
      "createdAt": "..."
    }
  ],
  "pagination": {
    "total": 100,
    "page": 1,
    "limit": 12,
    "totalPages": 9
  }
}
```

### Get product detail

- **Method:** `GET`
- **Endpoint:** `/api/v1/products/{id}`

### Create product

- **Method:** `POST`
- **Endpoint:** `/api/v1/products`
- **Auth:** Bearer token
- **Content-Type:** multipart/form-data
- **Body fields:**
  - `title`
  - `description`
  - `price`
  - `categoryId`
  - `condition` (`new`, `like_new`, `good`, `fair`, `poor`)
  - `campus`
  - `negotiable`
  - `images[]`

### Update product

- **Method:** `PATCH`
- **Endpoint:** `/api/v1/products/{id}`

### Delete product

- **Method:** `DELETE`
- **Endpoint:** `/api/v1/products/{id}`

## Error handling

- 400 -> Validation error
- 401 -> Unauthorized (UI redirects to login)
- 500 -> Server error

## State lifecycle

`initial -> loading -> loaded`

Mutation states:

- `creating`
- `updating`
- `deleting`
- `success`
- `error`

## Search / Filter / Sorting

### ProductFilter entity

`ProductFilter` supports:

- `keyword`
- `campus`
- `condition`
- `minPrice`
- `maxPrice`
- `category`
- `sortBy`
- `page`
- `limit`

### Query Builder

`ProductQueryBuilder.toQuery(filter)` converts `ProductFilter` into backend query params and removes null/empty values.

Example:

```text
/api/v1/products?search=laptop&minPrice=100&maxPrice=500&condition=new&sort=price:asc&page=1&limit=12
```

### Filter state

`ProductFilterState` statuses:

- `initial`
- `loading`
- `loaded`
- `empty`
- `error`

Includes:

- active filter object
- active filter count badge
- products list
- pagination booleans (`hasMore`, `isFetchingMore`)

### Use cases

- `SearchProductsUseCase`
- `ApplyFilterUseCase`
- `ClearFilterUseCase`

## Flow

`UI -> ProductFilterNotifier/ProductsNotifier -> UseCase -> Repository -> DataSource -> API/Hive -> UI`
