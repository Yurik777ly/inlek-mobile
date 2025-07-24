import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/profile_screen/profile_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/starts/login_screen.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/profile_screen/profile_categories_list.dart';
import 'package:inlek/locator_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        // HomeScreenBloc homeBloc = context.read<HomeScreenBloc>();
        return BlocProvider(
          create: (context) => ProfileScreenBloc(
            logoutUC: sl(),
            sharedPreferences: sl(),
          ),
          child: BlocConsumer<ProfileScreenBloc, ProfileScreenState>(
            listener: (context, state) => switch (state) {
              NavigateLoginState _ =>
                Navigator.of(UiConstants.homeContext!).pushAndRemoveUntil(
                    Routes.createRoute(
                      const LoginScreen(),
                      settings: RouteSettings(
                        name: Routes.loginScreen,
                        arguments: {'redirect_type': LoginScreenType.login},
                      ),
                    ),
                    (_) => false),
              ProfileScreenState() => throw UnimplementedError(),
            },
            builder: (context, state) {
              final bloc = context.read<ProfileScreenBloc>();
              return Scaffold(
                backgroundColor: UiConstants.backgroundColor,
                body: SafeArea(
                  child: Builder(
                    builder: (context) {
                      return Column(
                        children: [
                          CustomAppBar(
                            backgroundColor: UiConstants.backgroundColor,
                            title: 'Профиль',
                            action: GestureDetector(
                              onTap: () async {
                                bool? confirm = await BottomSheetManager
                                    .showExitAccountSheet(context);
                                if (confirm == true) {
                                  bloc.add(LogoutEvent());
                                }
                              },
                              child: SvgPicture.asset(Paths.exitIconPath,
                                  height: 24.dp, width: 24.dp),
                            ),
                          ),
                          Expanded(
                            child: homeState is InternetUnavailable
                                ? InternetNoInternetConnectionWidget()
                                : ListView(
                                    shrinkWrap: true,
                                    padding: getMarginOrPadding(
                                        bottom: 94,
                                        right: 20,
                                        left: 20,
                                        top: 16),
                                    children: [
                                      ProfileCategoriesList(),
                                    ],
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
