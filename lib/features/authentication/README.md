# Authentication Module (User Only)

This module follows **Clean Architecture** inside:

- `data/` → API + Hive/secure storage + repository implementation
- `domain/` → entities + repository abstraction + use cases
- `presentation/` → Riverpod state + UI screens

## Backend Contract Used

### Base URL

From `core/api/api_endpoints.dart`:

- `http://10.0.2.2:4000`

### Endpoints

- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`

### Request Body

#### Login

```json
{
  "email": "user@example.com",
  "password": "secret123"
}
```

#### Register

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "secret123",
  "university": "Dhaka University",
  "campus": "Main Campus"
}
```

### Response Body

#### Login (200)

```json
{
  "user": {
    "id": "...",
    "name": "...",
    "email": "...",
    "role": "user",
    "university": "...",
    "campus": "...",
    "profilePicture": "..."
  },
  "accessToken": "...",
  "refreshToken": "..."
}
```

#### Register (201)

```json
{
  "message": "Registration successful. Please check your email to verify your account."
}
```

### Error Format

```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

## Local Storage Strategy

- Hive box: `authenticationBox`
- Stored values:
  - `AUTH_USER` (typed `AuthUserModel`)
  - `ACCESS_TOKEN`
  - `REFRESH_TOKEN`
- Secure mirror:
  - `secure_access_token`
  - `secure_refresh_token`

`AuthNotifier` calls `restoreSession()` during build for **auto-login if token exists**.

## Quick Usage

Use route: `'/auth-gate-v2'` to test this module.
