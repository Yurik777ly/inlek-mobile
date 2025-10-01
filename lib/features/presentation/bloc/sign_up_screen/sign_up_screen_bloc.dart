import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/authentification_param.dart';
import 'package:inlek/features/domain/usecases/auth/is_phone_exists.dart';
import 'package:inlek/features/presentation/bloc/sign_up_screen/sign_up_screen_state.dart';

part 'sign_up_screen_event.dart';

class SignUpScreenBloc extends Bloc<SignUpScreenEvent, SignUpScreenState> {
  final IsPhoneExistsUC isPhoneExistsUC;

  final TextEditingController phoneController = TextEditingController();

  PasswordScreenType? _passwordScreenType;

  SignUpScreenBloc({
    required this.isPhoneExistsUC,
    PasswordScreenType? passwordScreenType,
    String? phone,
  }) : super(const SignUpScreenState()) {
    _passwordScreenType = passwordScreenType;
    phoneController.text = phone ?? '';
    phoneController.addListener(() {
      add(PhoneChangedEvent(phoneController.text));
    });

    on<PhoneChangedEvent>(
      (event, emit) {
        final isValidPhone = Utils.phoneRegexp.hasMatch(event.phone);
        if (event.phone.length == 19 && !isValidPhone) {
          emit(
            state.copyWith(
                isValidPhone: isValidPhone,
                phoneErrorText: 'Неверный формат телефона',
                showError: true),
          );
        } else {
          emit(
            state.copyWith(isValidPhone: isValidPhone),
          );
        }
      },
    );

    on<GetCodeEvent>(
      (event, emit) async {
        if (state.isValidPhone && !state.isLoading) {
          emit(state.copyWith(isLoading: true));
          // проверка на существование такого номера в системе
          final failureOrLoads = await isPhoneExistsUC(
            AuthenticationParams(
              phone: Utils.formatPhoneNumber(phoneController.text),
            ),
          );

          try {
            return failureOrLoads.fold(
              (failure) => switch (failure) {
                InvalidFormatFailure _ => emit(state.copyWith(
                    showError: true,
                    phoneErrorText: 'Неверный формат телефона')),
                ServerFailure _ => emit(state.copyWith(
                    showError: true, phoneErrorText: 'Неизвестная ошибка')),
                _ => emit(state.copyWith(
                    showError: true, phoneErrorText: 'Неизвестная ошибка')),
              },
              (isExists) {
                // регистрация
                if (_passwordScreenType == PasswordScreenType.signUp) {
                  // номер телефона уже зарегистрирован
                  if (isExists!) {
                    emit(state.copyWith(showError: false));
                    emit(AccountAlreadyExistsState());
                    return;
                  }

                  // восстановление пароля
                } else {
                  // номер телефона ещё не зарегистрирован
                  if (!isExists!) {
                    emit(state.copyWith(showError: false));
                    emit(NotFoundAccountState());
                    return;
                  }
                }

                // вызывает состояние получения кода (перенаправление на другой экран)
                emit(state.copyWith(showError: false));
                emit(GetCodeState());
              },
            );
          } finally {
            emit(state.copyWith(isLoading: false));
          }
        }
      },
    );
  }

  @override
  Future<void> close() {
    phoneController.dispose();
    return super.close();
  }
}
