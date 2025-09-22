import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/authentification_param.dart';
import 'package:inlek/features/domain/usecases/auth/login.dart';
import 'package:inlek/features/domain/usecases/profile/get_me.dart';

part 'login_screen_event.dart';
part 'login_screen_state.dart';

class LoginScreenBloc extends Bloc<LoginScreenEvent, LoginScreenState> {
  final LoginUC loginUC;
  final GetMeUC getMeUC;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreenBloc({
    required this.loginUC,
    required this.getMeUC,
    String? phone,
    LoginScreenType? loginScreenType,
  }) : super(const LoginScreenState()) {
    if (loginScreenType == LoginScreenType.accountExists) {
      phoneController.text = phone ?? '';
    }

    phoneController.addListener(() {
      add(PhoneChangedEvent(phoneController.text));
    });

    passwordController.addListener(() {
      add(PasswordChangedEvent(passwordController.text));
    });

    // Регистрация обработчиков событий
    on<PhoneChangedEvent>((event, emit) {
      final isValidPhone = Utils.phoneRegexp.hasMatch(event.phone);

      if (event.phone.length == 19 && !isValidPhone) {
        emit(
          state.copyWith(
              isValidPhone: isValidPhone,
              isButtonActive: isValidPhone && state.isValidPassword,
              phoneErrorText: 'Неверный формат телефона',
              resetPasswordErrorText: true,
              showError: true,
              resetPhoneErrorText: false),
        );
      } else {
        emit(state.copyWith(
            isValidPhone: isValidPhone,
            isButtonActive: isValidPhone && state.isValidPassword,
            resetPasswordErrorText: true,
            phoneErrorText: null,
            resetPhoneErrorText: true));
      }
    });

    on<PasswordChangedEvent>((event, emit) {
      final isValidPassword = event.password.isNotEmpty;

      emit(state.copyWith(
        isValidPassword: isValidPassword,
        isButtonActive: state.isValidPhone && isValidPassword,
        passwordErrorText: null,
        showError: false,
      ));
    });

    on<SubmitLoginEvent>(
      (event, emit) async {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        final failureOrLoads = await loginUC(
          AuthenticationParams(
            phone: Utils.formatPhoneNumber(phoneController.text),
            password: passwordController.text,
            fbid: fcmToken,
          ),
        );

        failureOrLoads.fold(
          (failure) => switch (failure) {
            PhoneDontFoundFailure _ => emit(state.copyWith(
                showError: true,
                passwordErrorText: 'Неправильный номер или пароль')),
            UncorrectedPasswordFailure _ => emit(state.copyWith(
                showError: true,
                passwordErrorText: 'Неправильный номер или пароль')),
            ServerFailure _ => emit(state.copyWith(
                showError: true, passwordErrorText: 'Неизвестная ошибка')),
            _ => emit(state.copyWith(
                showError: true, passwordErrorText: 'Неизвестная ошибка')),
          },
          (_) {
            // получаем данные для shared
            getMeUC();
            emit(state.copyWith(showError: false));
            emit(LogInState());
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    phoneController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
