class User {
  final int id;
  final String fullName;
  final String passwordHash;
  final String? email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.passwordHash,
    this.email,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      passwordHash: map['passwordHash'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'passwordHash': passwordHash,
    'email': email,
    'created_at': createdAt.toIso8601String(),
  };
}