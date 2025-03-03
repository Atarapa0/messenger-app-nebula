import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/constants.dart';

class MessageInput extends StatefulWidget {
  final String channelId;

  const MessageInput({
    Key? key,
    required this.channelId,
  }) : super(key: key);

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  bool _showAttachmentOptions = false;
  File? _selectedImage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty && _selectedImage == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Mesaj verilerini hazırla
      final messageData = {
        'channel_id': widget.channelId,
        'sender_id': userId,
        'content': content,
        'is_deleted': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Dosya varsa yükle
      if (_selectedImage != null) {
        final fileName = 'message_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'messages/$fileName';

        await supabase.storage.from('files').upload(
              filePath,
              _selectedImage!,
            );

        final fileUrl = supabase.storage.from('files').getPublicUrl(filePath);
        messageData['file_url'] = fileUrl.toString();
        messageData['file_type'] = 'image';
      }

      // Mesajı veritabanına ekle
      await supabase.from('messages').insert(messageData);

      // Mesaj gönderildikten sonra input'u temizle
      _messageController.clear();
      setState(() {
        _selectedImage = null;
        _showAttachmentOptions = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesaj gönderilirken hata: $e')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _showAttachmentOptions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null)
            Stack(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          if (_showAttachmentOptions)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.image,
                    label: 'Galeri',
                    onTap: _pickImage,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () {
                      // TODO: Implement camera
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.insert_drive_file,
                    label: 'Dosya',
                    onTap: () {
                      // TODO: Implement file picker
                    },
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.attach_file),
                onPressed: () {
                  setState(() {
                    _showAttachmentOptions = !_showAttachmentOptions;
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Mesaj yazın...',
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
              IconButton(
                icon: _isSending
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.send),
                color: AppColors.primary,
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
