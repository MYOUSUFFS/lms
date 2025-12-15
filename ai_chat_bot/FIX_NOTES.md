# Fix Notes - December 16, 2025

## Issue 1: device_info_plus NoSuchMethodError on Linux

### Problem

```
NoSuchMethodError: Class 'String' has no instance method 'cast'.
Receiver: "42 (KDE Plasma Desktop Edition)"
Tried calling: cast<String, dynamic>()
```

The `syncfusion_flutter_pdfviewer` package was trying to get Android device info on Linux desktop, causing a crash.

### Solution

1. **Added dependency override** in `pubspec.yaml`:

   ```yaml
   dependency_overrides:
     device_info_plus: ^12.0.0
   ```

2. **Platform-specific PDF viewer handling** in `document_viewer_screen.dart`:

   - Detects Linux platform and shows a user-friendly message
   - Provides download option for Linux users instead of in-app viewing
   - Other platforms continue to use the Syncfusion PDF viewer normally

3. **Implemented full download feature**:
   - Uses `file_picker` to let users choose save location
   - Saves with original filename
   - Shows success notification with "Open Folder" action
   - Cross-platform support (Linux, Windows, macOS)

## Issue 2: setState() called during build

### Problem

```
FlutterError: setState() or markNeedsBuild() called during build.
This _InheritedProviderScope<AuthProvider?> widget cannot be marked as needing to build...
```

**Root Causes:**

1. Providers were being initialized with `..init()` and `..initialize()` directly in the `create` callback
2. `SplashScreen` was calling `authProvider.init()` in `initState()`

Both caused `notifyListeners()` to be called during the build phase, which is not allowed in Flutter because the widget tree is still being constructed.

### Solution

Changed from immediate initialization in provider creation:

```dart
// BEFORE (Wrong)
ChangeNotifierProvider(
  create: (_) => ThemeProvider(...)..initialize(),  // ❌ Calls notifyListeners during build
),
```

To deferred initialization after the first frame:

```dart
// AFTER (Correct)
ChangeNotifierProvider(
  create: (_) => ThemeProvider(...),  // ✅ Just create the provider
),

// Then in the widget:
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeProviders();  // ✅ Initialize after build completes
  });
}
```

### Timing Diagram

```
BEFORE (❌ Causes Error):
┌─────────────────────────────────────────┐
│ MaterialApp Widget Build                │
│  ├─ Create Providers                    │
│  │   ├─ SettingsProvider..init() ──────┼──> notifyListeners() ❌
│  │   ├─ ThemeProvider..initialize() ───┼──> notifyListeners() ❌
│  │   └─ AuthProvider                    │
│  └─ Build SplashScreen                  │
│      └─ initState()                     │
│          └─ authProvider.init() ────────┼──> notifyListeners() ❌
└─────────────────────────────────────────┘
  Error: Cannot call notifyListeners during build!

AFTER (✅ Works Correctly):
┌─────────────────────────────────────────┐
│ MaterialApp Widget Build                │
│  ├─ Create Providers (no init)          │
│  └─ Build SplashScreen                  │
│      └─ initState()                     │
│          └─ addPostFrameCallback()      │
└─────────────────────────────────────────┘
           ↓ Build completes
┌─────────────────────────────────────────┐
│ Post-Frame Callbacks Execute            │
│  ├─ settingsProvider.init() ────────────┼──> notifyListeners() ✅
│  ├─ themeProvider.initialize() ─────────┼──> notifyListeners() ✅
│  ├─ chatProvider.init() ────────────────┼──> notifyListeners() ✅
│  └─ authProvider.init() ────────────────┼──> notifyListeners() ✅
└─────────────────────────────────────────┘
  Success: notifyListeners() called after build!
```

### Changes Made

1. Converted `AIChatBotApp` from StatelessWidget to StatefulWidget
2. Removed `..init()` and `..initialize()` calls from provider creation in `main.dart`
3. Added `initState()` to initialize all providers after the first frame using `addPostFrameCallback`
4. Used `Future.wait()` to initialize all providers concurrently
5. **Fixed `SplashScreen`** to also use `addPostFrameCallback` before calling `authProvider.init()`

### Benefits

- No more build-time errors
- Proper initialization order
- Better performance with concurrent initialization
- Cleaner separation of concerns

## Testing

Both issues have been fixed and the app should now:

1. Run without crashes on Linux desktop
2. Allow PDF download on Linux (with external viewer)
3. Initialize all providers properly without build-time errors
4. Support PDF viewing on other platforms (Windows, macOS, mobile)
