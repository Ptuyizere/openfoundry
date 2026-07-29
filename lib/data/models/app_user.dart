import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoundry/core/constants/enums.dart';

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.bio = '',
    this.profileImageUrl,
    this.location = '',
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String bio;
  final String? profileImageUrl;
  final String location;
  final DateTime createdAt;

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.backer,
      ),
      bio: (map['bio'] ?? '') as String,
      profileImageUrl: map['profileImageUrl'] as String?,
      location: (map['location'] ?? '') as String,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? bio,
    String? profileImageUrl,
    String? location,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      location: location ?? this.location,
      createdAt: createdAt,
    );
  }
}


