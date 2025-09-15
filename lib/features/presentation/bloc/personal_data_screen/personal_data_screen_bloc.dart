import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/features/data/models/profile_model.dart';
import 'package:inlek/features/domain/usecases/profile/delete_me.dart';
import 'package:inlek/features/domain/usecases/profile/get_me.dart';
import 'package:inlek/features/domain/usecases/profile/update_me.dart';
import 'package:inlek/main.dart';

part 'personal_data_screen_event.dart';
part 'personal_data_screen_state.dart';

class PersonalDataScreenBloc
    extends Bloc<PersonalDataScreenEvent, PersonalDataScreenState> {
  final GetMeUC getMeUC;
  final UpdateMeUC updateMeUC;
  final DeleteMeUC deleteMeUC;

  TextEditingController fNameController = TextEditingController();
  TextEditingController sNameController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmController = TextEditingController();

  // Store initial values to compare with current values
  String? initialFirstName = "";
  String? initialLastName = "";
  String? initialBirthday = "";
  String? initialPhone = "";
  String? initialEmail = "";
  GenderType? initialGender;
  bool? initialNotificationStatus;
  bool? initialPolicyStatus;

  bool hasUnsavedChanges() {
    return initialFirstName != fNameController.text ||
        initialLastName != sNameController.text ||
        initialBirthday != birthdayController.text ||
        initialPhone != phoneController.text ||
        initialEmail != emailController.text ||
        initialGender != state.gender ||
        initialNotificationStatus != state.isCheckedNotificationCheckbox ||
        initialPolicyStatus != state.isCheckedPolicyCheckbox ||
        oldPasswordController.text.isNotEmpty ||
        newPasswordController.text.isNotEmpty ||
        newPasswordConfirmController.text.isNotEmpty;
  }

  String get fName => fNameController.text;

  PersonalDataScreenBloc(
      {required this.getMeUC,
      required this.updateMeUC,
      required this.deleteMeUC,
      BuildContext? context})
      : super(PersonalDataScreenLoadingState()) {
    oldPasswordController.addListener(() {
      add(PasswordChangedEvent());
    });

    newPasswordController.addListener(() {
      add(PasswordChangedEvent());
    });

    newPasswordConfirmController.addListener(() {
      add(PasswordChangedEvent());
    });

    on<PasswordChangedEvent>((event, emit) {
      bool isPasswordValid = true;
      String? passwordErrorText;
      bool showError = false;

      if (oldPasswordController.text.isEmpty &&
          newPasswordController.text.isEmpty &&
          newPasswordConfirmController.text.isEmpty) {
        // All password fields are empty - no validation needed
        isPasswordValid = true;
        passwordErrorText = null;
        showError = false;
      } else if (oldPasswordController.text.isEmpty &&
              [newPasswordController.text, newPasswordConfirmController.text]
                  .any((e) => e.isNotEmpty) ||
          oldPasswordController.text.isNotEmpty &&
              [newPasswordController.text, newPasswordConfirmController.text]
                  .any((e) => e.isEmpty)) {
        // Incomplete password change
        isPasswordValid = false;
        passwordErrorText = 'Поле должно быть заполнено';
        showError = true;
      } else if (newPasswordController.text !=
          newPasswordConfirmController.text) {
        // Passwords don't match
        isPasswordValid = false;
        passwordErrorText = 'Пароли не совпадают';
        showError = true;
      } else {
        // Password validation passed
        isPasswordValid = true;
        passwordErrorText = null;
        showError = false;
      }

      emit(
        state.copyWith(
          isButtonActive: isPasswordValid,
          passwordErrorText: passwordErrorText,
          showError: showError,
        ),
      );
    });

    on<FormFieldChangedEvent>((event, emit) {
      // This event is now handled by the UI form validation
      // We keep it for compatibility but don't need to do anything here
    });

    on<ChangeNotificationCheckboxEvent>(
      (event, emit) {
        emit(
          state.copyWith(
              isCheckedNotificationCheckbox:
                  event.isCheckedNotificationCheckbox),
        );
      },
    );

    on<ChangePolicyCheckboxEvent>(
      (event, emit) {
        emit(
          state.copyWith(
              isCheckedPolicyCheckbox: event.isCheckedPolicyCheckbox,
              showPolicyError: false,
              installedPhone: state.installedPhone),
        );
      },
    );

    on<ChangeGenderEvent>(
      (event, emit) {
        emit(
          state.copyWith(gender: event.gender),
        );
      },
    );

    on<ConfirmPhoneChangeEvent>(
      (event, emit) {
        emit(
          state.copyWith(confirmPhoneCode: event.confirmPhoneCode),
        );
      },
    );

    on<SubmitEvent>(
      (event, emit) async {
        // Устанавливаем состояние сохранения
        emit(state.copyWith(isSaving: true));

        // Проверяем политику при попытке сохранить данные
        if (!state.isCheckedPolicyCheckbox) {
          emit(state.copyWith(
              isSaving: false,
              showPolicyError: true,
              installedPhone: state.installedPhone));
          ScaffoldMessenger.of(navigatorKey.currentContext!)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Примите условия обработки персональных данных'),
              ),
            );
          return;
        }

        final isValidPhone = Utils.phoneRegexp.hasMatch(phoneController.text);
        if (state.installedPhone != phoneController.text && isValidPhone) {
          emit(state.copyWith(isSaving: false));
          Utils.showCustomDialog(
            screenContext: navigatorKey.currentContext!,
            text: 'Номер телефона не подтверждён',
            action: (context) {
              Navigator.of(context).pop();
            },
          );
        } else {
          await updateProfile();
        }
      },
    );

    on<DeleteAccountEvent>(
      (event, emit) async {
        final failureOrLoads = await deleteMeUC();

        return failureOrLoads.fold(
          (_) => Utils.showCustomDialog(
            screenContext: navigatorKey.currentContext!,
            text: 'Неизвестная ошибка',
            action: (context) {
              Navigator.of(context).pop();
            },
          ),
          (_) => emit(DeleteAccountState()),
        );
      },
    );

    on<BackButtonPressedEvent>(
      (event, emit) async {
        // Проверяем политику при попытке уйти со страницы
        if (!state.isCheckedPolicyCheckbox) {
          ScaffoldMessenger.of(event.context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Примите условия обработки персональных данных'),
              ),
            );
          emit(state.copyWith(
              showPolicyError: true, installedPhone: state.installedPhone));

          return;
        }

        if (hasUnsavedChanges()) {
          bool? shouldSave =
              await BottomSheetManager.showUnsavedChangesSheet(event.context);

          if (shouldSave == true) {
            // User chose to save, update profile and then leave
            String? answer = await updateProfile();
            if (answer == null) {
              Navigator.of(event.context).pop();
            }
          } else if (shouldSave == false) {
            // User chose not to save, just leave
            Navigator.of(event.context).pop();
          }
          // If shouldSave is null (bottom sheet was dismissed), stay on screen
        } else {
          // No unsaved changes, just leave
          Navigator.of(event.context).pop();
        }
      },
    );
  }

  Future getProfile() async {
    final failureOrLoads = await getMeUC();

    return failureOrLoads.fold(
      (_) => Utils.showCustomDialog(
        screenContext: navigatorKey.currentContext!,
        text: 'Ошибказагрузки данных',
        action: (context) {
          Navigator.of(context).pop();
          //Navigator.of(navigatorKey.currentContext!).pop();
        },
      ),
      (profile) {
        oldPasswordController.clear();
        newPasswordConfirmController.clear();
        newPasswordController.clear();

        fNameController.text = profile.firstName ?? '';
        sNameController.text = profile.lastName ?? '';
        birthdayController.text = profile.birthday != null
            ? profile.birthday!.replaceAll('.', ' / ')
            : '';
        phoneController.text =
            Utils.formatPhoneNumber(profile.phoneNumber, toServerFormat: false);
        emailController.text = profile.emailAddress ?? '';

        // Store initial values
        initialFirstName = profile.firstName ?? "";
        initialLastName = profile.lastName ?? "";
        initialBirthday = profile.birthday != null
            ? profile.birthday!.replaceAll('.', ' / ')
            : '';
        initialPhone =
            Utils.formatPhoneNumber(profile.phoneNumber, toServerFormat: false);
        initialEmail = profile.emailAddress ?? '';
        initialGender = GenderType.values
                .firstWhereOrNull((e) => e.name == profile.gender) ??
            GenderType.values.first;
        initialNotificationStatus = profile.statusNotifications;
        initialPolicyStatus = profile.acceptPolicy;

        emit(
          PersonalDataScreenState(
            isLoading: false,
            gender: initialGender,
            isCheckedNotificationCheckbox: profile.statusNotifications ?? false,
            isCheckedPolicyCheckbox: profile.acceptPolicy ?? false,
            installedPhone: initialPhone,
          ),
        );
      },
    );
  }

  Future<String?> updateProfile(
      {bool requestedCode = false, String? confirmedCode}) async {
    final failureOrLoads = await updateMeUC(
      ProfileModel(
          firstName: fNameController.text,
          lastName: sNameController.text,
          phoneNumber: Utils.formatPhoneNumber(phoneController.text),
          gender: GenderType.values.firstWhere((e) => e == state.gender).name,
          birthday: birthdayController.text.replaceAll(' / ', '.'),
          emailAddress: emailController.text,
          acceptPolicy: state.isCheckedPolicyCheckbox ? "1" : "0",
          statusNotifications: state.isCheckedNotificationCheckbox ? "1" : "0",
          code: confirmedCode,
          oldPassword: oldPasswordController.text,
          newPassword: newPasswordController.text,
          newPasswordConfirm: newPasswordConfirmController.text),
    );

    return failureOrLoads.fold(
      (failure) {
        // Сбрасываем состояние сохранения при ошибке
        emit(state.copyWith(isSaving: false));

        String error = switch (failure) {
          SendingCodeTooOftenFailure _ =>
            'Слишком частая отправка кода или превышено число попыток за день',
          PasswordMatchesPreviousOneFailure _ =>
            'Старый и новый пароли совпадают',
          UncorrectedPasswordFailure _ =>
            'Текущий пароль пользователя указан неверно',
          AcceptPersonalDataFailure _ =>
            'Примите условия политики обработки персональных данных',
          _ => 'Ошибка обновления данных'
        };
        if (!requestedCode) {
          Utils.showCustomDialog(
            screenContext: navigatorKey.currentContext!,
            text: error,
            action: (context) {
              Navigator.of(context).pop();
            },
          );
        }
        return error;
      },
      (code) async {
        if (!requestedCode) {
          if (confirmedCode != null) {
            Navigator.of(UiConstants.homeContext!).pop();
          }

          await getProfile();

          // Reset initial values after successful save
          initialFirstName = fNameController.text;
          initialLastName = sNameController.text;
          initialBirthday = birthdayController.text;
          initialPhone = phoneController.text;
          initialEmail = emailController.text;
          initialGender = state.gender;
          initialNotificationStatus = state.isCheckedNotificationCheckbox;
          initialPolicyStatus = state.isCheckedPolicyCheckbox;

          // Clear password fields
          oldPasswordController.clear();
          newPasswordController.clear();
          newPasswordConfirmController.clear();

          // Clear policy error and reset saving state
          emit(state.copyWith(showPolicyError: false, isSaving: false));

          Utils.showCustomDialog(
            screenContext: navigatorKey.currentContext!,
            title: 'Уведомление',
            text: 'Данные обновлены',
            action: (context) {
              Navigator.of(context).pop();
            },
          );
        }

        return code;
      },
    );
  }

  @override
  Future<void> close() {
    fNameController.dispose();
    sNameController.dispose();
    birthdayController.dispose();
    phoneController.dispose();
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordConfirmController.dispose();

    // Remove all listeners
    oldPasswordController.removeListener(() {
      add(PasswordChangedEvent());
    });
    newPasswordController.removeListener(() {
      add(PasswordChangedEvent());
    });
    newPasswordConfirmController.removeListener(() {
      add(PasswordChangedEvent());
    });

    return super.close();
  }
}
