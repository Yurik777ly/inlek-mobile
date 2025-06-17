part of 'personal_data_screen_bloc.dart';

class PersonalDataScreenState extends Equatable {
  final bool isLoading;
  final bool isButtonActive;
  final GenderType? gender;
  final bool isCheckedNotificationCheckbox;
  final bool isCheckedPolicyCheckbox;
  final String? passwordErrorText;
  final bool showError;
  final String? confirmPhoneCode;
  final String? installedPhone;
  final bool showPolicyError;

  const PersonalDataScreenState({
    this.isLoading = true,
    this.isButtonActive = true,
    this.gender = GenderType.male,
    this.isCheckedNotificationCheckbox = false,
    this.isCheckedPolicyCheckbox = false,
    this.passwordErrorText,
    this.showError = false,
    this.confirmPhoneCode,
    this.installedPhone,
    this.showPolicyError = false,
  });

  PersonalDataScreenState copyWith({
    bool? isLoading,
    bool? isButtonActive,
    GenderType? gender,
    bool? isCheckedNotificationCheckbox,
    bool? isCheckedPolicyCheckbox,
    String? passwordErrorText,
    bool? showError,
    String? confirmPhoneCode,
    String? installedPhone,
    bool? showPolicyError,
  }) {
    return PersonalDataScreenState(
      isLoading: isLoading ?? this.isLoading,
      isButtonActive: isButtonActive ?? this.isButtonActive,
      gender: gender ?? this.gender,
      isCheckedNotificationCheckbox:
          isCheckedNotificationCheckbox ?? this.isCheckedNotificationCheckbox,
      isCheckedPolicyCheckbox:
          isCheckedPolicyCheckbox ?? this.isCheckedPolicyCheckbox,
      passwordErrorText: passwordErrorText,
      showError: showError ?? this.showError,
      confirmPhoneCode: confirmPhoneCode,
      installedPhone: installedPhone ?? this.installedPhone,
      showPolicyError: showPolicyError ?? this.showPolicyError,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isButtonActive,
        gender,
        isCheckedNotificationCheckbox,
        isCheckedPolicyCheckbox,
        passwordErrorText,
        showError,
        confirmPhoneCode,
        installedPhone,
        showPolicyError,
      ];
}

class PersonalDataScreenLoadingState extends PersonalDataScreenState {}

class DeleteAccountState extends PersonalDataScreenState {}
