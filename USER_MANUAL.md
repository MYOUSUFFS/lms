# 📖 LMS AI Assistant - User Manual

Welcome to the **LMS AI Assistant** User Manual! This guide will help you get started and make the most of your AI-powered learning companion.

![LMS AI Assistant](sample.png)

---

## 📋 Table of Contents

1. [Introduction](#-introduction)
2. [Getting Started](#-getting-started)
3. [Interface Overview](#-interface-overview)
4. [Chat Modes](#-chat-modes)
5. [Using the Chat](#-using-the-chat)
6. [Managing Conversations](#-managing-conversations)
7. [Settings](#-settings)
8. [Keyboard Shortcuts](#-keyboard-shortcuts)
9. [Tips & Best Practices](#-tips--best-practices)
10. [Troubleshooting](#-troubleshooting)
11. [FAQ](#-faq)

---

## 🎯 Introduction

The **LMS AI Assistant** is an intelligent chatbot designed to help you with your learning journey. It can:

- ✅ Answer questions on any topic
- ✅ Remember your conversation context
- ✅ Query your uploaded documents (RAG mode)
- ✅ Provide real-time streaming responses
- ✅ Support multiple conversations

---

## 🚀 Getting Started

### First Launch

When you first open the application, you'll see a welcome screen with two options:

1. **Direct Chat** - Chat directly with the AI
2. **Document Q&A** - Query your uploaded documents

### Initial Setup

Before you can start chatting, you need to configure the connection settings:

1. Click the **Settings icon** (⚙️) in the top-right corner
2. Enter your **API Base URL** (e.g., `http://localhost:8000`)
3. Enter your **API Key** (provided by your administrator)
4. Click **Save**

> 💡 **Tip**: The connection status indicator in the top bar will show **"Connected"** (green) when properly configured.

---

## 🖥️ Interface Overview

### Main Screen Layout

```
┌─────────────────────────────────────────────────────────────┐
│  [≡] Sidebar  │  LMS AI Assistant          [●] Connected [⚙️]│
├───────────────┼─────────────────────────────────────────────┤
│               │                                             │
│  [+ New Chat] │                                             │
│               │           Welcome Screen                    │
│  ─────────────│              or                             │
│               │         Chat Messages                       │
│  Today        │                                             │
│  • Chat 1     │                                             │
│  • Chat 2     │                                             │
│               │                                             │
│  Yesterday    │                                             │
│  • Chat 3     │                                             │
│               ├─────────────────────────────────────────────┤
│               │  [Type a message...]              [Send ➤]  │
└───────────────┴─────────────────────────────────────────────┘
```

### Key UI Elements

| Element               | Description                                     |
| --------------------- | ----------------------------------------------- |
| **Sidebar**           | Shows all your conversations, organized by date |
| **Connection Status** | Green = Connected, Red = Offline                |
| **RAG Toggle**        | 📚 = RAG mode, 💬 = Direct chat                 |
| **Settings**          | Access app configuration                        |
| **Chat Input**        | Type your messages here                         |
| **Send Button**       | Click or press Enter to send                    |

---

## 💬 Chat Modes

### 1. Direct Chat Mode 💬

In this mode, the AI responds based on its general knowledge without referencing any documents.

**Best for:**

- General questions
- Learning new concepts
- Getting explanations
- Brainstorming ideas

**How to enable:**

- Click the chat bubble icon (💬) in the top bar
- Or select "Direct Chat" from the welcome screen

### 2. RAG Mode (Document Q&A) 📚

RAG (Retrieval-Augmented Generation) mode allows the AI to search through your uploaded documents and provide answers based on that content.

**Best for:**

- Querying course materials
- Finding specific information in documents
- Getting answers with source references
- Studying from uploaded content

**How to enable:**

- Click the books icon (📚) in the top bar
- Or select "Document Q&A" from the welcome screen

> 📝 **Note**: RAG mode requires documents to be uploaded through the backend API first.

---

## ✍️ Using the Chat

### Sending Messages

1. **Type your message** in the input field at the bottom
2. **Press Enter** or click the **Send button** (➤)
3. Wait for the AI response

### Multi-line Messages

To type a message with multiple lines:

- Press **Shift + Enter** to add a new line
- Press **Enter** (without Shift) to send

### Real-time Streaming

When enabled, you'll see the AI's response appear word-by-word as it's generated. This provides:

- Faster perceived response time
- Ability to see the response forming
- Option to interrupt if needed

### Message Types

| Icon | Type      | Description          |
| ---- | --------- | -------------------- |
| 👤   | User      | Your messages        |
| 🤖   | Assistant | AI responses         |
| ⏳   | Loading   | AI is thinking       |
| ❌   | Error     | Something went wrong |

---

## 📂 Managing Conversations

### Creating a New Chat

**Method 1:** Click the **"+ New Chat"** button in the sidebar

**Method 2:** From the welcome screen, choose a chat mode

### Switching Between Chats

Click on any conversation in the sidebar to switch to it. Your messages are preserved and the AI remembers the context.

### Deleting a Chat

1. Hover over the conversation in the sidebar
2. Click the **delete icon** (🗑️)
3. Confirm deletion

> ⚠️ **Warning**: Deleted conversations cannot be recovered!

### Conversation Organization

Conversations are automatically organized by date:

- **Today** - Chats from today
- **Yesterday** - Chats from yesterday
- **Previous 7 Days** - Older recent chats
- **Older** - Chats older than a week

---

## ⚙️ Settings

Access settings by clicking the **gear icon** (⚙️) in the top-right corner.

### Available Settings

| Setting          | Description            | Options                             |
| ---------------- | ---------------------- | ----------------------------------- |
| **API Base URL** | Backend server address | URL (e.g., `http://localhost:8000`) |
| **API Key**      | Authentication key     | Your secret key                     |
| **Theme**        | App appearance         | Light / Dark / System               |
| **Streaming**    | Real-time responses    | On / Off                            |
| **RAG Mode**     | Document context       | On / Off                            |

### Saving Settings

Click **"Save"** after making changes. The app will automatically reconnect with the new settings.

---

## ⌨️ Keyboard Shortcuts

| Shortcut        | Action                |
| --------------- | --------------------- |
| `Enter`         | Send message          |
| `Shift + Enter` | New line in message   |
| `Esc`           | Close settings drawer |

---

## 💡 Tips & Best Practices

### For Better Responses

1. **Be specific** - The more details you provide, the better the response
2. **Ask follow-up questions** - The AI remembers your conversation
3. **Use RAG mode** - When you need information from specific documents
4. **Break complex questions** - Into smaller, focused questions

### Examples of Good Questions

✅ **Good**: "Explain the concept of machine learning and give me 3 real-world examples"

✅ **Good**: "Based on the uploaded course materials, what are the key differences between supervised and unsupervised learning?"

❌ **Vague**: "Tell me about AI"

❌ **Too broad**: "Explain everything about data science"

### Conversation Memory

The AI remembers:

- ✅ Previous messages in the current session
- ✅ Context from earlier in the conversation
- ✅ Your preferences mentioned in the chat

The AI does NOT remember:

- ❌ Conversations from previous sessions (unless saved)
- ❌ Personal information across different chats

---

## 🔧 Troubleshooting

### Connection Issues

**Problem**: Status shows "Offline"

**Solutions**:

1. Check if the backend server is running
2. Verify the API URL in settings
3. Check your internet connection
4. Ensure the API key is correct

### Slow Responses

**Problem**: AI takes too long to respond

**Solutions**:

1. Enable streaming for faster perceived response
2. Check server load
3. Try a shorter, more focused question
4. Ensure the backend LLM is running

### Messages Not Sending

**Problem**: Send button doesn't work

**Solutions**:

1. Check connection status
2. Ensure message isn't empty
3. Try refreshing the app
4. Check for JavaScript errors (web)

### RAG Mode Not Working

**Problem**: AI doesn't reference documents

**Solutions**:

1. Ensure RAG mode is enabled (📚 icon)
2. Verify documents are uploaded to the backend
3. Try rephrasing your question
4. Check backend logs for errors

---

## ❓ FAQ

### General Questions

**Q: How does the AI remember my previous messages?**

A: The app sends the last 20 messages as context with each new message. This allows the AI to maintain conversation continuity.

**Q: Is my data stored securely?**

A: Your conversations are stored locally on your device. The backend processes messages but doesn't store them permanently unless configured to do so.

**Q: Can I export my conversations?**

A: Currently, conversations are stored locally. Export functionality may be added in future updates.

### Technical Questions

**Q: What AI model is being used?**

A: The backend uses Ollama with models like Llama 3, Mistral, or Phi-3. Cloud fallback options include Groq and Together AI.

**Q: Why do some responses take longer than others?**

A: Response time depends on:

- Question complexity
- Document search (in RAG mode)
- Server load
- Network latency

**Q: Can I use this offline?**

A: No, the app requires a connection to the backend server. The backend can run locally on your machine, but the AI processing happens server-side.

### Troubleshooting Questions

**Q: What should I do if the AI gives incorrect information?**

A: AI responses are generated based on patterns and may not always be accurate. Always verify important information from authoritative sources.

**Q: The app is showing a blank screen. What do I do?**

A: Try these steps:

1. Refresh the page (web) or restart the app
2. Clear app cache
3. Check browser console for errors
4. Ensure you have a stable internet connection

---

## 📞 Support

If you encounter issues not covered in this manual:

1. Check the [GitHub Issues](https://github.com/MYOUSUFFS/lms/issues)
2. Review the [README](README.md) for technical details
3. Contact your system administrator

---

## 📝 Version History

| Version | Date          | Changes                                             |
| ------- | ------------- | --------------------------------------------------- |
| 1.0.0   | December 2024 | Initial release with streaming and LangChain memory |

---

**Thank you for using LMS AI Assistant! Happy learning! 🎓**
