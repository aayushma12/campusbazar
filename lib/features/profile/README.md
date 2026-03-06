# Profile Feature (Clean Architecture)

This module follows:

- `data/` → model + API + local cache + repository implementation
- `domain/` → entity + repository abstraction + use cases
- `presentation/` → state + notifier + UI

## Backend API Contract Used

Base URL comes from `core/api/api_endpoints.dart`.

### Get Profile

- **Method:** `GET`
- **Endpoint:** `/api/v1/users/me`
- **Auth:** `Authorization: Bearer <access_token>`

**Response (example)**

```json
{
  "id": "...",
  "name": "...",
  "email": "...",
  "phoneNumber": "...",
  "studentId": "...",
  "batch": "...",
  "collegeId": "...",
  "university": "...",
  "campus": "...",
  "bio": "...",
  "profilePicture": "..."
}
```

### Update Profile

- **Method:** `PATCH`
- **Endpoint:** `/api/v1/users/me`
- **Auth:** `Authorization: Bearer <access_token>`
- **Content-Type:** `multipart/form-data`

**Fields supported by backend DTO**

- `name`
- `phoneNumber`
- `studentId`
- `batch`
- `collegeId`
- `university`
- `campus`
- `bio`
- `profilePicture` (file, optional)
- `oldPassword` (optional)
- `newPassword` (optional)

### Error format

```json
{
  "message": "..."
}
```

(or global middleware may produce `{ "success": false, "message": "..." }`)

## Local Storage (Hive)

- Box: `profileBox`
- Key: `CACHED_PROFILE`
- Adapter: `ProfileModelAdapter` (manual)

## State Lifecycle

`ProfileStatus` values:

- `initial`
- `loading`
- `loaded`
- `updating`
- `success`
- `error`

## Flow

`UI -> ViewModel -> UseCase -> Repository -> Remote/Local DataSource -> API/Hive`
