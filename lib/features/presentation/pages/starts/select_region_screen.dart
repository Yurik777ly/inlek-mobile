import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/domain/entities/city_entity.dart';
import 'package:inlek/features/presentation/bloc/select_region_screen/select_region_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/home_screen.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/app_template.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/delivery_bottom_sheet/delivery_plate_widget.dart';
import 'package:inlek/features/presentation/widgets/select_region_screen/city_search_field.dart';
import 'package:inlek/features/presentation/widgets/select_region_screen/popularity_cities_widget.dart';
import 'package:inlek/locator_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectRegionScreen extends StatelessWidget {
  const SelectRegionScreen({super.key, this.selectRegionScreenType});

  final SelectRegionScreenType? selectRegionScreenType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectRegionScreenBloc(
        getCitiesUC: sl(),
        sharedPreferences: sl(),
      )..add(LoadDataEvent()),
      child: BlocBuilder<SelectRegionScreenBloc, SelectRegionScreenState>(
        builder: (context, state) {
          final bloc = context.read<SelectRegionScreenBloc>();

          return AppTemplate(
            hasBack: selectRegionScreenType == SelectRegionScreenType.main,
            title: 'Выберите регион',
            child: SafeArea(
              bottom: true,
              left: false,
              right: false,
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(Paths.locationIconPath,
                                  width: 24, height: 24),
                              SizedBox(width: 8),
                              Text(
                                state.detectedCity ?? 'Определение...',
                                style: UiConstants.textStyle5
                                    .copyWith(color: UiConstants.darkBlueColor),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'На основе вашей геолокации',
                            style: UiConstants.textStyle3.copyWith(
                              color: UiConstants.darkBlue2Color.withOpacity(.6),
                            ),
                          ),
                          SizedBox(height: 16),
                          CitySearchField(
                            prefixIcon: Paths.searchIconPath,
                            hintText: 'Найти другой город',
                            controller: bloc.regionController,
                            minFetcherLength: 1,
                            suggestionFetcher: (query) {
                              final completer = Completer<List<String>>();

                              completer.complete(
                                state.popularCities
                                    .map((e) => e.pagetitle)
                                    .where((title) => title
                                        .toLowerCase()
                                        .startsWith(query.toLowerCase()))
                                    .toList(),
                              );

                              return completer.future;
                            },
                            onSuggestionTap: (p0) {
                              bloc.regionController.text = p0;
                            },
                            suggestionObjects: state.popularCities,
                          ),
                          if (state.showError)
                            Padding(
                              padding: getMarginOrPadding(top: 16),
                              child: InfoPlateWidget(
                                  text:
                                      'Мы еще не работаем в этом городе, выберите другой'),
                            ),
                          SizedBox(height: 16),
                          PopularityCitiesWidget(
                              regions: state.popularCities,
                              onTapRegion: (CityEntity region) => bloc
                                  .regionController.text = region.pagetitle),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      AppButtonWidget(
                        isActive: state.isButtonActive,
                        text: 'Подтвердить',
                        onTap: () {
                          bloc.add(ConfirmRegionEvent(context: context));
                          if (selectRegionScreenType ==
                              SelectRegionScreenType.signUp) {
                            Navigator.of(context).pushAndRemoveUntil(
                                Routes.createRoute(
                                  HomeScreen(
                                      initPersonalDataScreen:
                                          selectRegionScreenType ==
                                              SelectRegionScreenType.signUp),
                                  settings: RouteSettings(
                                      arguments: Routes.homeScreen),
                                ),
                                (route) => false);
                          } else {
                            sl<SharedPreferences>()
                                .remove(SharedPreferencesKeys.pharmacyId);
                            Navigator.pop(context, state.selectedRegion);
                          }
                        },
                      ),
                      SizedBox(height: 8),
                      AppButtonWidget(
                        text: 'Пропустить',
                        isFilled: false,
                        onTap: () {
                          if (selectRegionScreenType ==
                              SelectRegionScreenType.signUp) {
                            Navigator.of(context).pushAndRemoveUntil(
                                Routes.createRoute(
                                  HomeScreen(
                                      initPersonalDataScreen:
                                          selectRegionScreenType ==
                                              SelectRegionScreenType.signUp),
                                  settings: RouteSettings(
                                      arguments: Routes.homeScreen),
                                ),
                                (route) => false);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
