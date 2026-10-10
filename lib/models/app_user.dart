class AppUser {
  final String id;
  final String nama;
  final String email;
  final String role; // 'pencari' atau 'pemilik'

  const AppUser({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      nama: json['nama'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  bool get isPemilik => role == 'pemilik';
}
