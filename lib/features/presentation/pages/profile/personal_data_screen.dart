import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/personal_data_screen/personal_data_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/starts/login_screen.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/personal_data_screen/change_password_block.dart';
import 'package:inlek/features/presentation/widgets/personal_data_screen/checkboxed_block.dart';
import 'package:inlek/features/presentation/widgets/personal_data_screen/contacts_block.dart';
import 'package:inlek/features/presentation/widgets/personal_data_screen/general_information_block.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Validate form after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
      context.read<PersonalDataScreenBloc>().getProfile();
    });
  }

  void _validateForm() {
    if (formKey.currentState != null) {
      setState(() {
        isFormValid = formKey.currentState!.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        return BlocConsumer<PersonalDataScreenBloc, PersonalDataScreenState>(
          listener: (context, state) => switch (state) {
            DeleteAccountState _ =>
              Navigator.of(UiConstants.homeContext!).pushAndRemoveUntil(
                  Routes.createRoute(
                    const LoginScreen(),
                    settings: RouteSettings(
                      name: Routes.loginScreen,
                      arguments: {'redirect_type': LoginScreenType.login},
                    ),
                  ),
                  (_) => false),
            _ => {},
          },
          builder: (context, state) {
            final personalDataBloc = context.read<PersonalDataScreenBloc>();

            // Validate form whenever state changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (formKey.currentState != null) {
                bool newFormValid = formKey.currentState!.validate();
                if (newFormValid != isFormValid) {
                  setState(() {
                    isFormValid = newFormValid;
                  });
                }
              }
            });

            return WillPopScope(
              onWillPop: () async {
                final isValid = formKey.currentState?.validate() ?? false;

                if (isValid) {
                  personalDataBloc.add(
                    BackButtonPressedEvent(context: context),
                  );
                }

                // Возвращаем false, чтобы предотвратить автоматический pop
                return false;
              },
              child: Scaffold(
                backgroundColor: UiConstants.backgroundColor,
                body: SafeArea(
                  child: Skeletonizer(
                    ignorePointers: false,
                    enabled: state.isLoading,
                    child: Builder(
                      builder: (context) {
                        return Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: _validateForm,
                          child: Column(
                            children: [
                              CustomAppBar(
                                backgroundColor: UiConstants.backgroundColor,
                                title: 'Личные данные',
                                showBack: true,
                                onTapBack: () {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    personalDataBloc.add(
                                      BackButtonPressedEvent(context: context),
                                    );
                                  }
                                },
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
                                          GeneralInformationBlock(
                                              screenContext: context),
                                          SizedBox(height: 16.dp),
                                          ContactsBlock(screenContext: context),
                                          SizedBox(height: 16.dp),
                                          ChangePasswordBlock(
                                              screenContext: context),
                                          SizedBox(height: 16.dp),
                                          CheckboxesBlock(
                                              screenContext: context),
                                          SizedBox(height: 32.dp),
                                          AppButtonWidget(
                                            isActive: state.isButtonActive &&
                                                isFormValid &&
                                                !state.isSaving,
                                            isLoading: state.isSaving,
                                            text: 'Сохранить',
                                            onTap: () {
                                              if (formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                personalDataBloc.add(
                                                  SubmitEvent(context: context),
                                                );
                                              }
                                            },
                                          ),
                                          SizedBox(height: 8.dp),
                                          AppButtonWidget(
                                            text: 'Удалить аккаунт',
                                            backgroundColor:
                                                UiConstants.backgroundColor,
                                            textColor:
                                                UiConstants.darkBlueColor,
                                            onTap: () async {
                                              bool? isSuccess =
                                                  await BottomSheetManager
                                                      .showDeleteAccountSheet(
                                                          context);

                                              if (isSuccess == true) {
                                                personalDataBloc
                                                    .add(DeleteAccountEvent());
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
