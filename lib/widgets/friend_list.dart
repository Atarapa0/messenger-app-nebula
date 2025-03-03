import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key});

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final List<User> _friends = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('friends')
          .select('friend_id, users!friends_friend_id_fkey(*)')
          .eq('user_id', userId)
          .execute();

      if (response.error != null) {
        throw response.error!.message;
      }

      final data = response.data as List;
      if (mounted) {
        setState(() {
          _friends.clear();
          _friends.addAll(
              data.map((friend) => User.fromJson(friend['users'])).toList());
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arkadaşlar yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await supabase
          .from('users')
          .select()
          .ilike('username', '%${query.trim()}%')
          .execute();

      if (response.error != null) {
        throw response.error!.message;
      }

      final data = response.data as List;
      if (mounted) {
        setState(() {
          _searchResults = data.map((user) => User.fromJson(user)).toList();
          // Kendimizi ve mevcut arkadaşları sonuçlardan çıkar
          final currentUserId = supabase.auth.currentUser?.id;
          _searchResults.removeWhere((user) =>
              user.id == currentUserId ||
              _friends.any((friend) => friend.id == user.id));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı arama hatası: $e')),
        );
      }
    }
  }

  Future<void> _addFriend(String friendId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase.from('friends').insert({
        'user_id': userId,
        'friend_id': friendId,
      }).execute();

      if (response.error != null) {
        throw response.error!.message;
      }

      await _loadFriends();
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
          _searchController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arkadaş başarıyla eklendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arkadaş eklenirken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkadaşlar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Kullanıcı ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _searchUsers,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSearching
              ? _buildSearchResults()
              : _buildFriendsList(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('Kullanıcı bulunamadı'),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePicture != null
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null
                ? Text(user.username[0].toUpperCase())
                : null,
          ),
          title: Text(user.username),
          subtitle: const Text('Arkadaş ekle'),
          trailing: IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _addFriend(user.id),
          ),
        );
      },
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return Center(
        child: Text(
          'Henüz arkadaşınız yok',
          style: AppTextStyles.body,
        ),
      );
    }

    return ListView.builder(
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: friend.profilePicture != null
                ? NetworkImage(friend.profilePicture!)
                : null,
            child: friend.profilePicture == null
                ? Text(friend.username[0].toUpperCase())
                : null,
          ),
          title: Text(friend.username),
          subtitle: Text(
            friend.status == 'online'
                ? 'Çevrimiçi'
                : friend.lastSeen != null
                    ? 'Son görülme: ${_formatLastSeen(friend.lastSeen!)}'
                    : 'Çevrimdışı',
          ),
          trailing: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: friend.status == 'online'
                  ? AppColors.online
                  : AppColors.offline,
            ),
          ),
        );
      },
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }
}
