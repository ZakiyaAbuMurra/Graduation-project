part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

// Update the AuthSuccess class to hold the userType
class AuthSuccess extends AuthState {
  final String? userType;

  AuthSuccess({this.userType});
}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}