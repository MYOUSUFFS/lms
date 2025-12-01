# 📱 LMS AI Chat Bot

A beautiful, cross-platform Flutter chat application for the LMS AI Assistant. Features real-time streaming responses, conversation memory, and support for both direct chat and RAG-powered document Q&A.

![LMS AI Assistant](../sample.png)

## ✨ Features

- 🎨 **Modern UI** - Clean Material Design 3 interface with dark/light mode
- 🌊 **Real-time Streaming** - See AI responses as they are generated
- 🧠 **Conversation Memory** - AI remembers context within chat sessions
- 📚 **RAG Mode** - Query your uploaded documents for intelligent answers
- 💬 **Direct Chat** - Chat directly with the AI without document context
- 📱 **Cross-platform** - iOS, Android, Web, macOS, Windows, Linux
- 📝 **Markdown Support** - Rich text rendering with code highlighting
- 📂 **Conversation History** - Save, manage, and resume chat sessions
- ⌨️ **Keyboard Shortcuts** - Press Enter to send, Shift+Enter for new line

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK 3.8+
- Dart SDK 3.8+
- Backend server running (see main [README](../README.md))

### Installation

```bash
# Navigate to the Flutter app
cd ai_chat_bot

# Install dependencies
flutter pub get

# Run on your preferred platform
flutter run -d chrome       # Web browser
flutter run -d macos        # macOS desktop
flutter run -d ios          # iOS simulator/device
flutter run -d android      # Android emulator/device
flutter run -d windows      # Windows desktop
flutter run -d linux        # Linux desktop
```

### Configuration

On first launch, configure the app settings:

1. Click the **Settings** icon (⚙️) in the top-right
2. Enter your **API Base URL** (e.g., `http://localhost:8000`)
3. Enter your **API Key** (from your `.env` file)
4. Save settings

## 📁 Project Structure

```
ai_chat_bot/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/
│   │   ├── constants/            # App constants
│   │   ├── models/               # Data models (Message, Conversation)
│   │   ├── providers/            # State management
│   │   │   ├── chat_provider.dart    # Chat state & API calls
│   │   │   └── settings_provider.dart # App settings
│   │   ├── services/             # Services
│   │   │   ├── api_service.dart      # HTTP & streaming client
│   │   │   └── storage_service.dart  # Local storage
│   │   └── theme/                # App theming
│   │       └── app_theme.dart        # Light/dark themes
│   └── features/
│       └── chat/
│           ├── screens/
│           │   └── chat_screen.dart  # Main chat interface
│           └── widgets/
│               ├── chat_input.dart       # Message input field
│               ├── chat_sidebar.dart     # Conversation list
│               ├── message_bubble.dart   # Message display
│               ├── message_list.dart     # Messages container
│               └── settings_drawer.dart  # Settings panel
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── web/                          # Web platform code
├── macos/                        # macOS platform code
├── windows/                      # Windows platform code
├── linux/                        # Linux platform code
└── pubspec.yaml                  # Dependencies
```

## 🎯 Usage

### Starting a New Chat

1. Click **"Direct Chat"** for general AI conversation
2. Click **"Document Q&A"** to query uploaded documents (RAG mode)
3. Or use the **New Chat** button in the sidebar

### Chat Modes

| Mode        | Icon | Description                        |
| ----------- | ---- | ---------------------------------- |
| Direct Chat | 💬   | Chat directly with the AI          |
| RAG Mode    | 📚   | AI answers based on your documents |

### Keyboard Shortcuts

| Key             | Action       |
| --------------- | ------------ |
| `Enter`         | Send message |
| `Shift + Enter` | New line     |

### Settings

Access settings via the ⚙️ icon:

- **API URL**: Backend server address
- **API Key**: Authentication key
- **Theme**: Light / Dark / System
- **Streaming**: Enable/disable real-time responses
- **RAG Mode**: Toggle document context

## 📦 Dependencies

| Package              | Purpose            |
| -------------------- | ------------------ |
| `provider`           | State management   |
| `http`               | HTTP client        |
| `shared_preferences` | Local storage      |
| `flutter_markdown`   | Markdown rendering |
| `google_fonts`       | Typography         |
| `uuid`               | Unique IDs         |
| `intl`               | Date formatting    |

## 🔧 Building for Production

### Web

```bash
flutter build web --release
# Output: build/web/
```

### Android

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
flutter build ios --release
# Then archive in Xcode
```

### macOS

```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

## 📄 License

MIT License - see [LICENSE](../LICENSE) for details.
