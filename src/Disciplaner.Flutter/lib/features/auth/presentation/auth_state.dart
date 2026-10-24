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
  /// Raw error (typically an AppFailure); the UI resolves the localized text.
  final Object? error;
  const AuthUnconfiguredServer({this.error});

  @override
  List<Object?> get props => [error];
}

class AuthNeedsInitialSetup extends AuthState {
  const AuthNeedsInitialSetup();
}

class AuthUnauthenticated extends AuthState {
  /// Raw error (typically an AppFailure); the UI resolves the localized text.
  final Object? error;
  const AuthUnauthenticated({this.error});

  @override
  List<Object?> get props => [error];
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
