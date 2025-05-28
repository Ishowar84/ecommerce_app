// lib/models/user.dart

class User {
  final int id;
  final String name;
  final String email;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? 'Guest',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}