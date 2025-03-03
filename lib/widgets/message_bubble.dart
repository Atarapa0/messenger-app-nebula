import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../utils/constants.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && message.senderId.username != null)
            Padding(
              padding: EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.senderId.username ?? 'Bilinmeyen Kullanıcı',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: message.senderProfilePicture != null
                      ? NetworkImage(message.senderProfilePicture!)
                      : null,
                  child: message.senderProfilePicture == null
                      ? Text(
                          message.senderId.username != null &&
                                  message.senderId.username!.isNotEmpty
                              ? message.senderId.username![0].toUpperCase()
                              : '?',
                          style: TextStyle(fontSize: 14),
                        )
                      : null,
                ),
              SizedBox(width: !isMe ? 8 : 0),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withAlpha(13), // 0.05 opacity = 13/255
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          if (isMe) SizedBox(width: 4),
                          if (isMe) _buildStatusIcon(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isMe ? 8 : 0),
              if (isMe)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: supabase
                              .auth.currentUser?.userMetadata['avatar_url'] !=
                          null
                      ? NetworkImage(
                          supabase.auth.currentUser!.userMetadata['avatar_url'])
                      : null,
                  child:
                      supabase.auth.currentUser?.userMetadata['avatar_url'] ==
                              null
                          ? Icon(Icons.person, size: 16, color: Colors.white)
                          : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return Icon(Icons.access_time, size: 12, color: Colors.white70);
      case MessageStatus.sent:
        return Icon(Icons.check, size: 12, color: Colors.white70);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 12, color: Colors.white70);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 12, color: Colors.blue[300]);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 12, color: Colors.red[300]);
    }
  }
}

extension on String {
  get username => null;
}
