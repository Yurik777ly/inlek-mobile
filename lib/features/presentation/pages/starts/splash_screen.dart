import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/splash_screen/splash_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/home_screen.dart';
import 'package:inlek/features/presentation/pages/starts/login_screen.dart';
import 'package:inlek/locator_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashScreenBloc(
        sharedPreferences: sl(),
        getMeUC: sl(),
      )..add(SplashScreenStarted()),
      child: BlocListener<SplashScreenBloc, SplashScreenState>(
        listener: (context, state) {
          if (state is SplashScreenNavigateLogin) {
            Navigator.of(context).pushReplacement(
              Routes.createRoute(
                const LoginScreen(),
                settings: RouteSettings(
                  name: Routes.loginScreen,
                  arguments: {'redirect_type': LoginScreenType.login},
                ),
              ),
            );
          } else if (state is SplashScreenNavigateHome) {
            Navigator.of(context).pushReplacement(
              Routes.createRoute(
                const HomeScreen(),
                settings: RouteSettings(name: Routes.homeScreen),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
              toolbarHeight: 0,
              backgroundColor: UiConstants.whiteColor,
              surfaceTintColor: Colors.transparent),
          body: Padding(
            padding: getMarginOrPadding(left: 87, right: 87),
            child: SvgPicture.asset(Paths.logoIconPath, width: double.infinity),
          ),
        ),
      ),
    );
  }
}
