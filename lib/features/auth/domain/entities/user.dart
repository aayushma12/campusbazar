/// Domain entity for User
class User {
  final String id;
  final String name;
  final String email;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
  });

  // Optionally, you can override `toString` or `==` and `hashCode` if needed
  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, token: $token}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.token == token;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode ^ token.hashCode;
}
