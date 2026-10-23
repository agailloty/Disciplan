import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final String token;
  final String email;
  final String displayName;
  final List<String> roles;
  final DateTime expiresAt;

  const AuthResponse({
    required this.token,
    required this.email,
    required this.displayName,
    required this.roles,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'].toString())
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'email': email,
        'displayName': displayName,
        'roles': roles,
        'expiresAt': expiresAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [token, email, displayName, roles, expiresAt];
}

class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequest extends Equatable {
  final String email;
  final String displayName;
  final String password;

  const RegisterRequest({
    required this.email,
    required this.displayName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        'password': password,
      };

  @override
  List<Object?> get props => [email, displayName, password];
}

class SetupRequest extends Equatable {
  final String email;
  final String displayName;
  final String password;

  const SetupRequest({
    required this.email,
    required this.displayName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        'password': password,
      };

  @override
  List<Object?> get props => [email, displayName, password];
}

class SetupStatusResponse extends Equatable {
  final bool setupRequired;

  const SetupStatusResponse({required this.setupRequired});

  factory SetupStatusResponse.fromJson(Map<String, dynamic> json) {
    return SetupStatusResponse(
      setupRequired: json['setupRequired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'setupRequired': setupRequired,
      };

  @override
  List<Object?> get props => [setupRequired];
}

class InvitationInfoResponse extends Equatable {
  final bool isValid;
  final String? email;
  final DateTime? expiresAt;

  const InvitationInfoResponse({
    required this.isValid,
    this.email,
    this.expiresAt,
  });

  factory InvitationInfoResponse.fromJson(Map<String, dynamic> json) {
    return InvitationInfoResponse(
      isValid: json['isValid'] as bool? ?? false,
      email: json['email'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'isValid': isValid,
        if (email != null) 'email': email,
        if (expiresAt != null) 'expiresAt': expiresAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [isValid, email, expiresAt];
}

class InvitationRegisterRequest extends Equatable {
  final String token;
  final String email;
  final String displayName;
  final String password;

  const InvitationRegisterRequest({
    required this.token,
    required this.email,
    required this.displayName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'email': email,
        'displayName': displayName,
        'password': password,
      };

  @override
  List<Object?> get props => [token, email, displayName, password];
}
