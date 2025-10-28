import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String lastName;
  final String? phone;
  final String? profileImage;
  final String role;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    this.phone,
    this.profileImage,
    required this.role,
    required this.isActive,
    required this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$name $lastName';

  bool get isOrganizer => role == 'organizer' || role == 'admin';

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    lastName,
    phone,
    profileImage,
    role,
    isActive,
    isEmailVerified,
    createdAt,
    updatedAt,
  ];
}
