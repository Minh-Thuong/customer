class UserUpdate {
  final String name;
  final String phone;
  final String email;
  final String address;

  UserUpdate({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}