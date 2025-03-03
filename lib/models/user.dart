class User {
  final String id;
  final String username;
  final String? profilePicture;
  final String status;
  final DateTime? lastSeen;

  User({
    required this.id,
    required this.username,
    this.profilePicture,
    required this.status,
    this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      profilePicture: json['profile_picture'] as String?,
      status: json['status'] as String? ?? 'offline',
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_picture': profilePicture,
      'status': status,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }
}
