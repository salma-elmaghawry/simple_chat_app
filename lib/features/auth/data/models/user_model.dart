class UserModel {
  final String email;
  final String password;
  final String name;
  final String uid;
  final String? image;

  UserModel({
    required this.email,
    required this.name,
    required this.uid,
    required this.password,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      password: json['password'] as String? ?? '',
      email: json['email'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      uid: json['uid'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'name': name, 'image': image, 'uid': uid};
  }
}
