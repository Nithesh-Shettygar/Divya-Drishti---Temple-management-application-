class User {
  final int id;
  final String userRef;
  final String phone;
  final String name;
  final String dob;
  final String gender;
  final String address;
  final DateTime createdAt;

  User({
    required this.id,
    required this.userRef,
    required this.phone,
    required this.name,
    required this.dob,
    required this.gender,
    required this.address,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      userRef: json['user_ref'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_ref': userRef,
      'phone': phone,
      'name': name,
      'dob': dob,
      'gender': gender,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }
}