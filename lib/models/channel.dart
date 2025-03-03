class Channel {
  final String id;
  final String name;
  final String? description;
  final bool isPrivate;
  final String createdBy;
  final String? createdByUsername;
  final DateTime createdAt;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;

  Channel({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    this.createdByUsername,
    required this.createdAt,
    this.lastMessageContent,
    this.lastMessageAt,
    this.isPrivate = false,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['created_by'],
      createdByUsername:
          json['users'] != null ? json['users']['username'] : null,
      createdAt: DateTime.parse(json['created_at']),
      lastMessageContent: json['last_message_content'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      isPrivate: json['is_private'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'is_private': isPrivate,
    };
  }
}
