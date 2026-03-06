class AuthRequestModel {
  final String name;
  final String email;
  final String password;
  final String? university;
  final String? campus;

  AuthRequestModel({
    required this.name,
    required this.email,
    required this.password,
    this.university,
    this.campus,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        if (university != null && university!.isNotEmpty) 'university': university,
        if (campus != null && campus!.isNotEmpty) 'campus': campus,
      };
}
