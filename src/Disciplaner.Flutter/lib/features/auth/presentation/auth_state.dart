import 'package:equatable/equatable.dart';
import 'package:disciplaner_flutter/core/models/auth_models.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthUnconfiguredServer extends AuthState {
  final String? errorMessage;
  const AuthUnconfiguredServer({this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthNeedsInitialSetup extends AuthState {
  const AuthNeedsInitialSetup();
}

class AuthUnauthenticated extends AuthState {
  final String? errorMessage;
  const AuthUnauthenticated({this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthAuthenticated extends AuthState {
  final AuthResponse session;
  const AuthAuthenticated(this.session);

  @override
  List<Object?> get props => [session];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}
