import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role; // entrepreneur or backer
  final String bio;
  final String location;
  final bool isVerified;
  final String avatarUrl;
  final String mobileMoneyNumber;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.bio = '',
    this.location = '',
    this.isVerified = true,
    this.avatarUrl = '',
    this.mobileMoneyNumber = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'entrepreneur',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      isVerified: json['isVerified'] ?? true,
      avatarUrl: json['avatarUrl'] ?? '',
      mobileMoneyNumber: json['mobileMoneyNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'bio': bio,
      'location': location,
      'isVerified': isVerified,
      'avatarUrl': avatarUrl,
      'mobileMoneyNumber': mobileMoneyNumber,
    };
  }

  UserModel copyWith({
    String? name,
    String? bio,
    String? location,
    bool? isVerified,
    String? avatarUrl,
    String? mobileMoneyNumber,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      mobileMoneyNumber: mobileMoneyNumber ?? this.mobileMoneyNumber,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, bio, location, isVerified, avatarUrl, mobileMoneyNumber];
}
