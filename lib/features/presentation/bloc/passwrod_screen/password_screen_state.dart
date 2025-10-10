part of 'password_screen_bloc.dart';

class PasswordScreenState extends Equatable {
  final String? phone;
  final String? code;
  final bool isButtonActive;
  final String? passwordErrorText;
  final bool showError;
  final bool isLoading;

  const PasswordScreenState({
    this.phone,
    this.code,
    this.isButtonActive = false,
    this.passwordErrorText,
    this.showError = false,
    this.isLoading = false,
  });

  PasswordScreenState copyWith({
    String? phone,
    String? code,
    bool? isButtonActive,
    String? passwordErrorText,
    bool? showError,
    bool? isLoading,
  }) {
    return PasswordScreenState(
      phone: phone ?? this.phone,
      code: code ?? this.code,
      isButtonActive: isButtonActive ?? this.isButtonActive,
      passwordErrorText: passwordErrorText ?? this.passwordErrorText,
      showError: showError ?? this.showError,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        isButtonActive,
        passwordErrorText,
        showError,
        isLoading,
      ];
}

class NavigateHomeState extends PasswordScreenState {}

class NavigateLoginState extends PasswordScreenState {}
