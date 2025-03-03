import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/channel.dart';
import '../screens/chat_screen.dart';

class ChannelList extends StatefulWidget {
  const ChannelList({super.key});

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  final List<Channel> _channels = [];
  bool _isLoading = true;
  final _channelNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _channelNameController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    try {
      final response = await supabase.from('channels').select().execute();

      if (response.error != null) {
        throw response.error!.message;
      }

      final data = response.data as List;
      if (mounted) {
        setState(() {
          _channels.clear();
          _channels.addAll(data.map((channel) => Channel.fromJson(channel)));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kanallar yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _createChannel(String name) async {
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kanal adı boş olamaz')),
      );
      return;
    }

    try {
      final response = await supabase.from('channels').insert({
        'name': name.trim(),
        'created_by': supabase.auth.currentUser!.id,
      }).execute();

      if (response.error != null) {
        throw response.error!.message;
      }

      await _loadChannels();
      _channelNameController.clear();
      if (mounted) {
        Navigator.pop(context); // Dialog'u kapat
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kanal oluşturulurken hata oluştu: $e')),
        );
      }
    }
  }

  void _showCreateChannelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kanal Oluştur'),
        content: TextField(
          controller: _channelNameController,
          decoration: const InputDecoration(
            labelText: 'Kanal Adı',
            hintText: 'Örn: Genel Sohbet',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => _createChannel(_channelNameController.text),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          style: const TextStyle(color: Colors.white),
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
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateChannelDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
