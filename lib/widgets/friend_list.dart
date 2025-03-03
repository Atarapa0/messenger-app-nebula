import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FriendList extends StatefulWidget {
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Arkadaşları yükle
      final friendsResponse = await supabase
          .from('friends')
          .select(
              '*, friend:friend_id(id, username, status, profile_picture, last_seen)')
          .eq('user_id', userId)
          .eq('status', 'accepted');

      // Bekleyen arkadaşlık isteklerini yükle
      final pendingResponse = await supabase
          .from('friends')
          .select('*, user:user_id(id, username, profile_picture)')
          .eq('friend_id', userId)
          .eq('status', 'pending');

      setState(() {
        _friends =
            List<Map<String, dynamic>>.from(friendsResponse as List<dynamic>);
        _pendingRequests =
            List<Map<String, dynamic>>.from(pendingResponse as List<dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading friends: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptFriendRequest(String requestId) async {
    try {
      await supabase
          .from('friends')
          .update({'status': 'accepted'}).eq('id', requestId);

      // Reload friends list
      _loadFriends();
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  Future<void> _rejectFriendRequest(String requestId) async {
    try {
      await supabase.from('friends').delete().eq('id', requestId);

      // Reload friends list
      _loadFriends();
    } catch (e) {
      print('Error rejecting friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arkadaşlar'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              // TODO: Arkadaş ekleme ekranını aç
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                if (_pendingRequests.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Arkadaşlık İstekleri',
                        style: AppTextStyles.subheading,
                      ),
                    ),
                  ),
                if (_pendingRequests.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final request = _pendingRequests[index];
                        final user = request['user'];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['profile_picture'] != null
                                ? NetworkImage(user['profile_picture'])
                                : null,
                            child: user['profile_picture'] == null
                                ? Text(user['username'][0].toUpperCase())
                                : null,
                          ),
                          title: Text(user['username']),
                          subtitle: Text('Arkadaşlık isteği gönderdi'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () =>
                                    _acceptFriendRequest(request['id']),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () =>
                                    _rejectFriendRequest(request['id']),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: _pendingRequests.length,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Arkadaşlarım',
                      style: AppTextStyles.subheading,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final friend = _friends[index];
                      final user = friend['friend'];
                      final isOnline = user['status'] == 'online';

                      return ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: user['profile_picture'] != null
                                  ? NetworkImage(user['profile_picture'])
                                  : null,
                              child: user['profile_picture'] == null
                                  ? Text(user['username'][0].toUpperCase())
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? AppColors.online
                                      : AppColors.offline,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(user['username']),
                        subtitle: Text(isOnline ? 'Çevrimiçi' : 'Çevrimdışı'),
                        onTap: () {
                          // TODO: Özel mesajlaşma ekranını aç
                        },
                      );
                    },
                    childCount: _friends.length,
                  ),
                ),
              ],
            ),
    );
  }
}
