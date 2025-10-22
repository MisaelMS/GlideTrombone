import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String email;

  @HiveField(3)
  late String password;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime lastLogin;

  @HiveField(6)
  bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    required this.lastLogin,
    this.isActive = true,
  });

  factory User.create({
    required String name,
    required String email,
    required String password,
  }) {
    final now = DateTime.now();
    return User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email.toLowerCase().trim(),
      password: password,
      createdAt: now,
      lastLogin: now,
    );
  }

  bool checkPassword(String inputPassword) {
    return password == inputPassword;
  }

  void updateLastLogin() {
    lastLogin = DateTime.now();
    save();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, isActive: $isActive}';
  }
}