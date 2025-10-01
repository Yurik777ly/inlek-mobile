import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/formatters/custom_phone_input_formatter.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/login_screen/login_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/home_screen.dart';
import 'package:inlek/features/presentation/pages/starts/sign_up_screen.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/app_template.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';
import 'package:inlek/features/presentation/widgets/policy_text_widget.dart';
import 'package:inlek/locator_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    LoginScreenType loginScreenType = args?['redirect_type'];
    String? phone = args?['phone'];

    return BlocProvider(
      create: (context) => LoginScreenBloc(
        loginScreenType: loginScreenType,
        phone: phone,
        loginUC: sl(),
        getMeUC: sl(),
      )..add(PhoneChangedEvent(phone ?? '')),
      child: BlocConsumer<LoginScreenBloc, LoginScreenState>(
        listener: (context, state) async {
          if (state is LogInState) {
            Navigator.of(context).pushAndRemoveUntil(
                Routes.createRoute(
                  const HomeScreen(),
                ),
                (route) => false);
          }
        },
        builder: (context, state) {
          final bloc = context.read<LoginScreenBloc>();

          return AppTemplate(
            hasBack: loginScreenType == LoginScreenType.accountExists,
            title: loginScreenType == LoginScreenType.login
                ? 'Войти в аккаунт'
                : 'Такой аккаунт уже существует',
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      AppTextFieldWidget(
                        title: 'Телефон',
                        hintText: '+375 (00) 000-00-00',
                        controller: bloc.phoneController,
                        errorText: state.phoneErrorText,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CustomPhoneInputFormatter()
                        ],
                        validator: Utils.validatePhone,
                      ),
                      SizedBox(height: 24.dp),
                      AppTextFieldWidget(
                        title: 'Пароль',
                        hintText: 'Введите пароль',
                        isObscuredText: true,
                        controller: bloc.passwordController,
                        errorText: state.showError
                            ? state.passwordErrorText
                            : null, // Показывать ошибку при неверном пароле
                      ),
                      SizedBox(height: 32.dp),
                      AppButtonWidget(
                        isActive: state.isButtonActive,
                        text: 'Войти',
                        onTap: () => bloc.add(SubmitLoginEvent()),
                      ),
                      SizedBox(height: 32.dp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Забыли пароль?',
                            style: UiConstants.textStyle3.copyWith(
                              color: UiConstants.darkBlue2Color.withOpacity(.6),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                loginScreenType == LoginScreenType.accountExists
                                    ? Navigator.of(context).pushAndRemoveUntil(
                                        Routes.createRoute(
                                          const SignUpScreen(),
                                          settings: RouteSettings(
                                            name: Routes.signUpScreen,
                                            arguments: {
                                              'redirect_type':
                                                  PasswordScreenType.reset
                                            },
                                          ),
                                        ),
                                        (route) {
                                          return route.settings.name ==
                                                  "/login_screen" &&
                                              (route.settings.arguments as Map<
                                                          String, dynamic>?)?[
                                                      'redirect_type'] ==
                                                  LoginScreenType.login;
                                        },
                                      )
                                    : Navigator.of(context).push(
                                        Routes.createRoute(
                                          const SignUpScreen(),
                                          settings: RouteSettings(
                                            name: Routes.signUpScreen,
                                            arguments: {
                                              'redirect_type':
                                                  PasswordScreenType.reset,
                                              'phone': state.isValidPhone
                                                  ? bloc.phoneController.text
                                                  : null
                                            },
                                          ),
                                        ),
                                      ),
                            child: Text(
                              'Восстановить',
                              style: UiConstants.textStyle3
                                  .copyWith(color: UiConstants.purpleColor),
                            ),
                          ),
                        ],
                      ),
                      if (loginScreenType == LoginScreenType.login)
                        Padding(
                          padding: getMarginOrPadding(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Нет аккаунта?',
                                style: UiConstants.textStyle3.copyWith(
                                  color: UiConstants.darkBlue2Color
                                      .withOpacity(.6),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  Routes.createRoute(
                                    const SignUpScreen(),
                                    settings: RouteSettings(
                                      name: Routes.signUpScreen,
                                      arguments: {
                                        'redirect_type':
                                            PasswordScreenType.signUp,
                                        'phone': state.isValidPhone
                                            ? bloc.phoneController.text
                                            : null
                                      },
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Зарегистрироваться',
                                  style: UiConstants.textStyle3
                                      .copyWith(color: UiConstants.purpleColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                16.ph,
                PolicyTextWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}
