import 'package:equatable/equatable.dart';

class SignUpScreenState extends Equatable {
  final String? phoneErrorText;
  final bool showError;
  final bool isValidPhone;
  final bool isLoading;

  const SignUpScreenState({
    this.phoneErrorText,
    this.showError = false,
    this.isValidPhone = false,
    this.isLoading = false,
  });

  SignUpScreenState copyWith({
    String? phoneErrorText,
    bool? showError,
    bool? isValidPhone,
    bool? isLoading,
  }) {
    return SignUpScreenState(
      phoneErrorText: phoneErrorText,
      showError: showError ?? this.showError,
      isValidPhone: isValidPhone ?? this.isValidPhone,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props =>
      [phoneErrorText, showError, isValidPhone, isLoading];
}

class AccountAlreadyExistsState extends SignUpScreenState {}

class GetCodeState extends SignUpScreenState {}

class NotFoundAccountState extends SignUpScreenState {}
