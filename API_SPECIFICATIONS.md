# 📡 Auth API Contract & Specifications

## Base Configuration

```
Base URL: http://localhost:3000
Content-Type: application/json
Timeout: 30 seconds
```

---

## 1. Register Student

**Endpoint:**
```
POST /api/auth/register
```

**Request Body:**
```json
{
  "email": "student@example.com",
  "password": "SecurePassword@123"
}
```

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Student registered successfully",
  "userId": "507f1f77bcf86cd799439011",
  "email": "student@example.com",
  "role": "student",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "createdAt": "2026-01-14T10:30:00Z"
}
```

**Error Responses:**
- **400 Bad Request** - Missing/invalid fields
  ```json
  {
    "success": false,
    "message": "Email and password are required"
  }
  ```

- **409 Conflict** - User already exists
  ```json
  {
    "success": false,
    "message": "User already exists with this email"
  }
  ```

- **422 Unprocessable Entity** - Validation error
  ```json
  {
    "success": false,
    "message": "Invalid email format"
  }
  ```

- **500 Internal Server Error** - Server error
  ```json
  {
    "success": false,
    "message": "Server error occurred"
  }
  ```

---

## 2. Register Admin

**Endpoint:**
```
POST /api/auth/register/admin
```

**Request Body:**
```json
{
  "email": "admin@example.com",
  "password": "AdminPassword@123"
}
```

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Admin registered successfully",
  "userId": "507f1f77bcf86cd799439012",
  "email": "admin@example.com",
  "role": "admin",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "createdAt": "2026-01-14T10:30:00Z"
}
```

**Error Responses:** (Same as Register Student)

---

## 3. Register Tutor

**Endpoint:**
```
POST /api/auth/register/tutor
```

**Request Body:**
```json
{
  "email": "tutor@example.com",
  "password": "TutorPassword@123"
}
```

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Tutor registered successfully",
  "userId": "507f1f77bcf86cd799439013",
  "email": "tutor@example.com",
  "role": "tutor",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "createdAt": "2026-01-14T10:30:00Z"
}
```

**Error Responses:** (Same as Register Student)

---

## 4. Login

**Endpoint:**
```
POST /api/auth/login
```

**Request Body:**
```json
{
  "email": "student@example.com",
  "password": "SecurePassword@123"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "userId": "507f1f77bcf86cd799439011",
    "email": "student@example.com",
    "role": "student"
  }
}
```

**Error Responses:**
- **401 Unauthorized** - Invalid credentials
  ```json
  {
    "success": false,
    "message": "Invalid email or password"
  }
  ```

- **400 Bad Request** - Missing fields
  ```json
  {
    "success": false,
    "message": "Email and password are required"
  }
  ```

- **500 Internal Server Error** - Server error
  ```json
  {
    "success": false,
    "message": "Server error occurred"
  }
  ```

---

## HTTP Status Codes

| Code | Meaning | Scenario |
|------|---------|----------|
| 200 | OK | Successful login |
| 201 | Created | Successful registration |
| 400 | Bad Request | Missing/invalid fields |
| 401 | Unauthorized | Invalid credentials |
| 403 | Forbidden | Permission denied |
| 404 | Not Found | Endpoint not found |
| 409 | Conflict | Resource already exists |
| 422 | Unprocessable Entity | Validation failed |
| 500 | Server Error | Backend error |
| 502 | Bad Gateway | Backend unavailable |
| 503 | Service Unavailable | Maintenance |

---

## Authentication Headers

**For authenticated requests (not auth endpoints):**

```
Authorization: Bearer <token>
Content-Type: application/json
```

**Example:**
```
GET /api/user/profile HTTP/1.1
Host: localhost:3000
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

---

## Token Specifications

### Access Token
- **Type**: JWT
- **Lifespan**: Typically 15 minutes to 1 hour
- **Usage**: Sent in Authorization header
- **Storage**: flutter_secure_storage

### Refresh Token
- **Type**: JWT
- **Lifespan**: Typically 7 days to 30 days
- **Usage**: Used to obtain new access token when expired
- **Storage**: flutter_secure_storage

### Token Payload Example
```json
{
  "sub": "507f1f77bcf86cd799439011",      // User ID
  "email": "student@example.com",
  "role": "student",
  "iat": 1642156200,                      // Issued at
  "exp": 1642159800                       // Expiration
}
```

---

## Error Response Format

**Standard Error Response:**
```json
{
  "success": false,
  "message": "Error description",
  "error": {
    "code": "ERROR_CODE",
    "details": "Additional details if available"
  }
}
```

**Example:**
```json
{
  "success": false,
  "message": "Invalid email format",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": "Email must be a valid email address"
  }
}
```

---

## Request/Response Examples

### cURL Examples

**Register Student:**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "SecurePassword@123"
  }'
```

**Register Tutor:**
```bash
curl -X POST http://localhost:3000/api/auth/register/tutor \
  -H "Content-Type: application/json" \
  -d '{
    "email": "tutor@example.com",
    "password": "TutorPassword@123"
  }'
```

**Register Admin:**
```bash
curl -X POST http://localhost:3000/api/auth/register/admin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "AdminPassword@123"
  }'
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "SecurePassword@123"
  }'
```

**Make Authenticated Request:**
```bash
curl -X GET http://localhost:3000/api/user/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

---

## Validation Rules

### Email
- ✅ Must be valid email format
- ✅ Must be unique (not already registered)
- ✅ Case insensitive
- ✅ Example: `user@example.com`

### Password
- ✅ Minimum 8 characters (recommended)
- ✅ May require special characters (backend dependent)
- ✅ May require uppercase letters (backend dependent)
- ✅ May require numbers (backend dependent)
- ⚠️ Never sent back in responses
- ⚠️ Never logged

### Role
- ✅ Must be one of: `student`, `tutor`, `admin`
- ✅ Determined by endpoint used
- ✅ Cannot be changed via register

---

## API Implementation Map

### Flutter Implementation
```
Request: AuthRequestModel
  └─ email: String
  └─ password: String

Response: AuthResponseModel
  ├─ userId: String
  ├─ email: String
  ├─ role: String (converted to UserRole enum)
  ├─ token: String
  ├─ refreshToken: String
  ├─ message: String
  └─ createdAt: DateTime

Entity: AuthEntity
  ├─ userId: String
  ├─ email: String
  ├─ role: UserRole (enum: student, tutor, admin)
  ├─ token: String
  ├─ refreshToken: String
  ├─ createdAt: DateTime
  └─ password: String (registration only)
```

---

## Rate Limiting (If Applicable)

```
Rate Limit: 100 requests per minute
Per User: Limited by API implementation
Headers: 
  - X-RateLimit-Limit: 100
  - X-RateLimit-Remaining: 95
  - X-RateLimit-Reset: 1642159800
```

---

## CORS Configuration

**Required CORS Headers:**
```
Access-Control-Allow-Origin: * (or specific domain)
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 3600
```

---

## SSL/TLS Requirements

- **Development**: `http://localhost:3000`
- **Production**: `https://api.example.com` (HTTPS required)

---

## Changelog & Versioning

### Version 1.0 (Current)
- ✅ Basic register endpoints (student, tutor, admin)
- ✅ Login endpoint
- ✅ JWT token-based auth
- ✅ Refresh token support

### Future Versions
- 🔄 Logout endpoint
- 🔄 Forgot password endpoint
- 🔄 Email verification
- 🔄 Two-factor authentication
- 🔄 Social login integration

---

**Document Version**: 1.0  
**Last Updated**: January 14, 2026  
**API Status**: ✅ Active
