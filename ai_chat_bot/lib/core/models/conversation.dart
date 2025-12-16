import 'package:uuid/uuid.dart';
import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool useRag;
  final Map<String, dynamic>? metadata; // Add metadata field

  Conversation({
    String? id,
    required this.title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.useRag = false,
    this.metadata,
  }) : id = id ?? const Uuid().v4(),
       messages = messages ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Conversation copyWith({
    String? id,
    String? title,
    List<Message>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? useRag,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      useRag: useRag ?? this.useRag,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'useRag': useRag,
      'metadata': metadata,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      useRag: json['useRag'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  String get preview {
    if (messages.isEmpty) return 'No messages yet';
    final lastMessage = messages.last;
    final content = lastMessage.content;
    return content.length > 50 ? '${content.substring(0, 50)}...' : content;
  }

  int get messageCount => messages.length;
}
