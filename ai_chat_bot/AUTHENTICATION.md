# Flutter Authentication System

## Overview

Complete authentication UI for the LMS RAG system with JWT token management, local storage, and automatic token refresh.

## Components Created

### 1. Models (`lib/core/models/user.dart`)

- **User**: User profile model with all fields
- **AuthToken**: JWT token response (access + refresh)
- **LoginCredentials**: Login request model
- **RegisterData**: Registration request model

### 2. Services (`lib/core/services/auth_service.dart`)

- Token management (access + refresh tokens)
- Local storage persistence using SharedPreferences
- Automatic token refresh on 401 responses
- User registration, login, logout
- Email verification
- Authenticated HTTP request helper

### 3. State Management (`lib/core/providers/auth_provider.dart`)

- Authentication state management using Provider pattern
- User session state
- Loading and error states
- Notification of auth state changes

### 4. UI Screens (`lib/features/auth/`)

#### `splash_screen.dart`

- App initialization screen
- Loads stored auth tokens
- Auto-navigates to login or home based on auth state

#### `login_screen.dart`

- Email/password login form
- Form validation
- Error handling and display
- "Forgot Password" placeholder
- Link to registration screen

#### `register_screen.dart`

- User registration form with:
  - Full name (required)
  - Email (required, validated)
  - Phone (optional)
  - Password (min 8 chars, with confirmation)
- Form validation
- Auto-login after successful registration
- Terms & Privacy notice

#### `profile_screen.dart`

- Display user information
- Avatar with initials fallback
- Email verification status
- Account info (phone, bio, member since, last login)
- Edit profile placeholder
- Change password placeholder
- Logout with confirmation dialog

## Integration with Backend

### API Endpoints Used

- `POST /api/v2/auth/register` - User registration
- `POST /api/v2/auth/login` - Login with email/password
- `POST /api/v2/auth/refresh` - Refresh access token
- `POST /api/v2/auth/verify-email` - Email verification
- `GET /api/v2/auth/me` - Get current user info

### Token Flow

1. User logs in → Receives `access_token` + `refresh_token`
2. Tokens stored in SharedPreferences
3. Access token used in `Authorization: Bearer <token>` header
4. On 401 error → Auto-refresh using refresh token
5. On refresh failure → Logout and redirect to login

## Setup Instructions

### 1. Update `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.1.2
  shared_preferences: ^2.3.2
```

### 2. Initialize in `main.dart`

```dart
// Already updated in the codebase
final authService = AuthService(baseUrl: baseUrl ?? 'http://localhost:8000');

// Add AuthProvider to MultiProvider
ChangeNotifierProvider(
  create: (_) => AuthProvider(authService),
),
```

### 3. Run the app

```bash
cd ai_chat_bot
flutter pub get
flutter run
```

## Usage Examples

### Check Authentication State

```dart
final authProvider = Provider.of<AuthProvider>(context);

if (authProvider.isAuthenticated) {
  // User is logged in
  final user = authProvider.currentUser;
  print('Logged in as: ${user?.email}');
}
```

### Login

```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);

final success = await authProvider.login(
  email: 'user@example.com',
  password: 'password123',
);

if (success) {
  // Navigate to home
} else {
  // Show error: authProvider.error
}
```

### Register

```dart
final success = await authProvider.register(
  email: 'newuser@example.com',
  password: 'password123',
  fullName: 'John Doe',
  phone: '+1234567890', // optional
);
```

### Logout

```dart
await authProvider.logout();
Navigator.pushReplacementNamed(context, '/login');
```

### Make Authenticated Requests

```dart
final authService = Provider.of<AuthProvider>(context).authService;

final response = await authService.authenticatedRequest(
  'GET',
  '/api/v2/some-endpoint',
);
```

## Security Features

1. **Password Requirements**: Minimum 8 characters
2. **Email Validation**: Proper email format checking
3. **Token Storage**: Secure local storage via SharedPreferences
4. **Automatic Token Refresh**: Seamless session management
5. **Logout**: Complete token cleanup
6. **Email Verification**: Status tracking (not enforced yet)

## Future Enhancements

- [ ] Forgot password flow
- [ ] Edit profile functionality
- [ ] Change password
- [ ] Social login (Google, Apple)
- [ ] Biometric authentication
- [ ] Email verification enforcement
- [ ] Password strength indicator
- [ ] Remember me checkbox
- [ ] Multi-factor authentication

## Testing

### Test Accounts

Create test users via registration or use:

```bash
# Create via backend API
curl -X POST http://localhost:8000/api/v2/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123",
    "full_name": "Test User"
  }'
```

### Test Flow

1. Launch app → See splash screen
2. Auto-navigate to login (if not authenticated)
3. Register new account
4. Auto-login after registration
5. See home screen
6. Access profile screen
7. Logout
8. Login again with same credentials

## Troubleshooting

### Token Refresh Fails

- Check backend `/api/v2/auth/refresh` endpoint
- Verify refresh token hasn't expired (7 days default)
- Clear app data and login again

### Can't Login

- Verify backend is running (`http://localhost:8000`)
- Check network connectivity
- Verify email/password are correct
- Check backend logs for errors

### SharedPreferences Issues

- On iOS: Tokens stored in UserDefaults
- On Android: Tokens stored in SharedPreferences
- Clear app data to reset: `flutter clean && flutter run`

## Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│                   Flutter App                    │
├─────────────────────────────────────────────────┤
│                                                  │
│  ┌────────────┐      ┌──────────────┐          │
│  │   UI       │ ───> │ AuthProvider │          │
│  │  Screens   │      └──────────────┘          │
│  └────────────┘             │                   │
│                              ▼                   │
│                      ┌──────────────┐           │
│                      │ AuthService  │           │
│                      └──────────────┘           │
│                              │                   │
│                   ┌──────────┴──────────┐       │
│                   ▼                     ▼       │
│          ┌────────────────┐    ┌──────────────┐│
│          │ HTTP Requests  │    │SharedPrefs   ││
│          └────────────────┘    └──────────────┘│
│                   │                             │
└───────────────────┼─────────────────────────────┘
                    ▼
         ┌───────────────────────┐
         │  FastAPI Backend      │
         │  /api/v2/auth/*       │
         └───────────────────────┘
                    │
                    ▼
         ┌───────────────────────┐
         │  PostgreSQL Database  │
         │  (users table)        │
         └───────────────────────┘
```

## License

Part of the LMS RAG project - Version 2.0.0
