# 🚀 Quick Reference - Auth Feature Implementation

## Files Created/Updated

### ✅ Core API Setup
- `lib/core/api/api_endpoints.dart` - API endpoint URLs & base URL
- `lib/core/api/api_client.dart` - Dio HTTP client with token interceptor
- `lib/core/error/failures.dart` - Error/Failure classes
- `pubspec.yaml` - Dependencies (dio, flutter_secure_storage, equatable)

### ✅ Domain Layer
- `lib/features/auth/domain/entities/auth_entity.dart` - User entity with UserRole enum
- `lib/features/auth/domain/repositories/auth_repository.dart` - Repository interface (IAuthRepository)
- `lib/features/auth/domain/usecases/login_usecase.dart` - Login use case
- `lib/features/auth/domain/usecases/register_usecase.dart` - Register student use case
- `lib/features/auth/domain/usecases/register_admin_usecase.dart` - Register admin use case
- `lib/features/auth/domain/usecases/register_tutor_usecase.dart` - Register tutor use case

### ✅ Data Layer
- `lib/features/auth/data/models/auth_request_model.dart` - Request model (email, password)
- `lib/features/auth/data/models/auth_response_model.dart` - Response model with parsing
- `lib/features/auth/data/datasources/auth_datasource.dart` - DataSource interface
- `lib/features/auth/data/datasources/remote/auth_remote_datasource.dart` - Remote implementation ⭐
- `lib/features/auth/data/repositories/auth_repository_impl.dart` - Repository implementation

### ✅ Presentation Layer
- `lib/features/auth/presentation/state/auth_state.dart` - Auth state & status enum
- `lib/features/auth/presentation/view_model/auth_viewmodel.dart` - Auth notifier provider
- `lib/features/auth/presentation/pages/login_page.dart` - Login UI
- `lib/features/auth/presentation/pages/register_page.dart` - Register UI

## Key Features

```
Authentication:
  ✅ Login with email/password
  ✅ Register (Student/Tutor/Admin)
  ✅ Logout
  ✅ Token-based auth
  
Token Management:
  ✅ Automatic token storage (flutter_secure_storage)
  ✅ Token injection in all requests
  ✅ Token clearing on logout
  ✅ 401 error handling
  
Error Handling:
  ✅ Network errors
  ✅ Validation errors
  ✅ HTTP status codes (400, 401, 403, 409, 500, etc)
  ✅ User-friendly error messages
  
UI:
  ✅ Form validation
  ✅ Loading indicators
  ✅ Error feedback
  ✅ Role selection
  ✅ Password visibility toggle
```

## API Endpoints

```
POST   /api/auth/register         → Register student
POST   /api/auth/register/admin   → Register admin
POST   /api/auth/register/tutor   → Register tutor
POST   /api/auth/login            → Login user
```

Base: `http://localhost:3000`  
(Change in `api_endpoints.dart` for different environment)

## Getting Started

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Start backend server**
   ```bash
   npm start  # or your backend command
   ```

3. **Add to main.dart**
   ```dart
   routes: {
     '/login': (context) => const LoginPage(),
     '/register': (context) => const RegisterPage(),
   }
   ```

4. **Test**
   - Navigate to `/login` or `/register`
   - Test registration with different roles
   - Test login with credentials

## Provider Chain

```
authViewModelProvider
  └─ reads: authRepositoryProvider
      └─ reads: authRemoteDatasourceProvider
          └─ reads: apiClientProvider
```

## Code Example: Login

```dart
// In widget
ref.watch(authViewModelProvider);

// Call login
ref.read(authViewModelProvider.notifier).login(
  email: 'user@example.com',
  password: 'password123',
);

// Listen for results
ref.listen(authViewModelProvider, (prev, next) {
  if (next.status == AuthStatus.authenticated) {
    // Success - navigate to home
  } else if (next.status == AuthStatus.error) {
    // Show error
    print(next.errorMessage);
  }
});
```

## Code Example: Register

```dart
// Register as student
ref.read(authViewModelProvider.notifier).register(
  email: 'student@example.com',
  password: 'password123',
);

// Register as tutor
ref.read(authViewModelProvider.notifier).registerTutor(
  email: 'tutor@example.com',
  password: 'password123',
);

// Register as admin
ref.read(authViewModelProvider.notifier).registerAdmin(
  email: 'admin@example.com',
  password: 'password123',
);
```

## Debugging

### Enable Logging
Already enabled in debug mode via `PrettyDioLogger`. Shows:
- Request/response headers
- Request/response body
- Error details

### Check Token Storage
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
final token = await storage.read(key: 'access_token');
print('Token: $token');
```

### Test API Manually
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

## Clean Architecture Pattern

```
Presentation Layer (UI)
  LoginPage → AuthViewModel ← AuthState
  RegisterPage

Domain Layer (Business Logic)
  UseCase (LoginUsecase, RegisterUsecase, etc.)
    ↓
  Repository Interface (IAuthRepository)

Data Layer (Data Access)
  Repository Implementation
    ↓
  DataSource (AuthRemoteDatasource)
    ↓
  API Client (Dio)
    ↓
  REST API
```

## UserRole Enum

```dart
enum UserRole {
  student,   // Default role
  admin,     // Administrator
  tutor      // Instructor
}
```

## AuthEntity Fields

```dart
class AuthEntity {
  final String? userId;           // User ID from backend
  final String email;             // User email
  final String? password;         // Only for registration
  final UserRole role;            // User role
  final String? token;            // JWT token
  final String? refreshToken;     // Refresh token
  final DateTime? createdAt;      // Account creation time
}
```

## AuthStatus States

```dart
enum AuthStatus {
  initial,           // Initial state
  loading,           // Loading data
  authenticated,     // Successfully logged in
  unauthenticated,   // Not logged in
  registered,        // Successfully registered
  error              // Error occurred
}
```

## Next Features to Add

1. Forgot Password Flow
2. Google/Facebook Sign-in
3. Email Verification
4. Two-Factor Authentication
5. Profile Management
6. Session Management
7. Auto-login on app startup

## Configuration for Different Environments

### Android Emulator
```dart
// api_endpoints.dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

### iOS Simulator
```dart
// api_endpoints.dart
static const String baseUrl = 'http://localhost:3000';
```

### Physical Device
```dart
// api_endpoints.dart - Replace with your machine IP
static const String baseUrl = 'http://192.168.1.100:3000';
```

## Security Checklist

- ✅ Tokens stored securely (not SharedPreferences)
- ✅ Passwords validated client-side
- ✅ Error messages sanitized
- ✅ No sensitive data in logs
- ✅ Token auto-injection in requests
- ✅ 401 error handling
- ✅ HTTPS recommended for production

## Common Errors & Fixes

| Error | Fix |
|-------|-----|
| Connection refused | Start backend server |
| Token not sent | Check interceptor in api_client.dart |
| CORS error | Enable CORS in backend |
| Page doesn't navigate | Uncomment navigation code in pages |
| Tokens not saving | Check SecureStorage permissions |

---

**Last Updated**: January 14, 2026  
**Version**: 1.0  
**Status**: ✅ Complete
