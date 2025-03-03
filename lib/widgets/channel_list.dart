import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/channel.dart';
import '../screens/chat_screen.dart';

class ChannelList extends StatefulWidget {
  const ChannelList({super.key});

  @override
  _ChannelListState createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  List<Channel> _channels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user's ID
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Get channels where the user is a member
      final response = await supabase
          .from('channel_members')
          .select('channel_id')
          .eq('user_id', userId);

      // Supabase'in yeni sürümünde response bir List<dynamic>
      final responseList = response as List<dynamic>;

      if (responseList.isEmpty) {
        setState(() {
          _channels = [];
          _isLoading = false;
        });
        return;
      }

      // Get channel IDs
      final channelIds = responseList
          .map<String>((item) => item['channel_id'] as String)
          .toList();

      // Get channel details
      final channelsResponse = await supabase
          .from('channels')
          .select('*, users:created_by(username)')
          .filter('id', 'in', channelIds);

      // Convert to Channel objects
      final List<Channel> channels = [];
      for (final data in channelsResponse as List<dynamic>) {
        channels.add(Channel.fromJson(data));
      }

      setState(() {
        _channels = channels;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading channels: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _channels.isEmpty
            ? Center(
                child: Text(
                  'Henüz kanal yok',
                  style: AppTextStyles.body.copyWith(color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: _channels.length,
                itemBuilder: (context, index) {
                  final channel = _channels[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        channel.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(channel.name),
                    subtitle: Text(
                      channel.description ?? 'Açıklama yok',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(channel: channel),
                        ),
                      );
                    },
                  );
                },
              );
  }
}
