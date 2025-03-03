import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final Channel channel;

  const ChatScreen({super.key, required this.channel});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messages = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    // Basit bir polling yaklaşımı kullanarak mesajları periyodik olarak yenile
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (mounted) {
        _loadInitialMessages();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = supabase
          .from('messages')
          .select('*, sender:sender_id(username, profile_picture)')
          .eq('channel_id', widget.channel.id)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(50);

      final List<Message> messages = [];
      for (final item in response as List<dynamic>) {
        messages.add(Message.fromJson(item));
      }

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Mesajlar yüklenirken hata: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Kanal bilgilerini göster
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadInitialMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Henüz mesaj yok',
                          style:
                              AppTextStyles.body.copyWith(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe =
                              message.senderId == supabase.auth.currentUser?.id;

                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                          );
                        },
                      ),
          ),
          MessageInput(channelId: widget.channel.id),
        ],
      ),
    );
  }
}
