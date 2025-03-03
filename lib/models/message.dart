enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class Message {
  final String id;
  final String channelId;
  final String senderId;
  final String? senderUsername;
  final String? senderProfilePicture;
  final String content;
  final DateTime createdAt;
  final bool isDeleted;
  final MessageStatus status;
  final String messageType;

  Message({
    required this.id,
    required this.channelId,
    required this.senderId,
    this.senderUsername,
    this.senderProfilePicture,
    required this.content,
    required this.createdAt,
    this.isDeleted = false,
    this.status = MessageStatus.sent,
    this.messageType = 'text',
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      channelId: json['channel_id'],
      senderId: json['sender_id'],
      senderUsername:
          json['sender'] != null ? json['sender']['username'] : null,
      senderProfilePicture:
          json['sender'] != null ? json['sender']['profile_picture'] : null,
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isDeleted: json['is_deleted'] ?? false,
      status: _parseStatus(json['status']),
      messageType: json['message_type'] ?? 'text',
    );
  }

  static MessageStatus _parseStatus(String? status) {
    if (status == null) return MessageStatus.sent;

    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }
}
