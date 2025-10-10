import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/passwrod_screen/password_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/home_screen.dart';
import 'package:inlek/features/presentation/pages/starts/login_screen.dart';
import 'package:inlek/features/presentation/pages/starts/select_region_screen.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/app_template.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';
import 'package:inlek/locator_service.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    PasswordScreenType passwordScreenType = args!['redirect_type'];

    return BlocProvider(
      create: (context) => PasswordScreenBloc(
          phone: args['phone'],
          code: args['code'],
          updatePasswordUC: sl(),
          registrationUC: sl(),
          loginUC: sl(),
          passwordScreenType: passwordScreenType),
      child: BlocConsumer<PasswordScreenBloc, PasswordScreenState>(
        listener: (context, state) {
          if (state is NavigateHomeState) {
            if (PasswordScreenType.signUp == passwordScreenType) {
              Navigator.of(context).pushAndRemoveUntil(
                  Routes.createRoute(
                    SelectRegionScreen(
                        selectRegionScreenType: SelectRegionScreenType.signUp),
                  ),
                  (route) => false);
            } else if (PasswordScreenType.reset == passwordScreenType) {
              Navigator.of(context).pushAndRemoveUntil(
                  Routes.createRoute(const HomeScreen(),
                      settings: RouteSettings(name: Routes.homeScreen)),
                  (route) => false);
            }
          } else if (state is NavigateLoginState) {
            Navigator.of(context).pushAndRemoveUntil(
                Routes.createRoute(
                  const LoginScreen(),
                ),
                (route) => false);
          }
        },
        builder: (context, state) {
          final bloc = context.read<PasswordScreenBloc>();

          return AppTemplate(
            hasBack: true,
            title: passwordScreenType == PasswordScreenType.signUp
                ? 'Придумайте пароль'
                : 'Восстановление пароля',
            subtitle: passwordScreenType == PasswordScreenType.reset
                ? 'Придумайте новый пароль:'
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextFieldWidget(
                    title: 'Пароль',
                    hintText: 'Введите пароль',
                    isObscuredText: true,
                    controller: bloc.password1Controller,
                    isShowError: state.showError,
                    errorText: state.passwordErrorText),
                SizedBox(height: 24),
                AppTextFieldWidget(
                    title: 'Повторите пароль',
                    hintText: 'Введите пароль',
                    isObscuredText: true,
                    controller: bloc.password2Controller,
                    isShowError: state.showError,
                    errorText: state.passwordErrorText),
                SizedBox(height: 32),
                AppButtonWidget(
                  isActive: state.isButtonActive && !state.isLoading,
                  isLoading: state.isLoading,
                  text: 'Подтвердить',
                  onTap: () => bloc.add(SubmitPasswordEvent()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
