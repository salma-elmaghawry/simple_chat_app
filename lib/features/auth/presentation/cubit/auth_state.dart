part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

final class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess({required this.user});
}

final class AuthEmailNotVerified extends AuthState {
  final User user;
  AuthEmailNotVerified({required this.user});
}

final class AuthPasswordResetSent extends AuthState {}
