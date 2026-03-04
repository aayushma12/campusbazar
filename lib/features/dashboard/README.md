# Dashboard Feature (Clean Architecture)

This module provides:

- Product listing for homepage/dashboard
- Create product (sell flow)
- Token-authenticated API integration
- Hive-based local cache for products

## Folder Structure

```text
features/dashboard/
  data/
    datasources/
      dashboard_remote_data_source.dart
      dashboard_local_data_source.dart
    models/
      dashboard_product_model.dart
    repositories/
      dashboard_repository_impl.dart
  domain/
    entities/
      dashboard_product_entity.dart
    repositories/
      dashboard_repository.dart
    usecases/
      get_products_usecase.dart
      create_product_usecase.dart
  presentation/
    providers/
      dashboard_providers.dart
    state/
      dashboard_state.dart
    view_model/
      dashboard_notifier.dart
    pages/
      home_page.dart
      create_product_page.dart
```

## Backend APIs used

### 1) Fetch products

- **Endpoint:** `GET /api/v1/products`
- **Auth:** Bearer token is attached by shared API interceptor
- **Response shape:**

```json
{
  "success": true,
  "data": [{ "_id": "...", "title": "..." }],
  "pagination": { "total": 120, "page": 1, "limit": 20, "totalPages": 6 }
}
```

### 2) Create product

- **Endpoint:** `POST /api/v1/products`
- **Auth:** Bearer token required
- **Content-Type:** `multipart/form-data`
- **Request fields:**

`title`, `description`, `price`, `categoryId`, `campus`, `condition`, `negotiable`, `images[]`

- **Response shape:**

```json
{
  "success": true,
  "data": {
    "_id": "...",
    "title": "...",
    "description": "...",
    "price": 100,
    "images": ["https://..."],
    "status": "available"
  }
}
```

### Error handling format

```json
{
  "success": false,
  "message": "Unauthorized"
}
```

If API returns `401` or `Unauthorized`, UI redirects user to login.

## State lifecycle

`DashboardStatus`:

- `initial`
- `loading`
- `loaded`
- `creating`
- `success`
- `error`

## Data flow

`UI -> Notifier -> UseCase -> Repository -> Remote/Local DataSource -> API/Hive`
