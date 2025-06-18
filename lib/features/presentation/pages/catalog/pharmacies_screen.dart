import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/pharmacies_screen/pharmacies_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/pharmacy_map/pharmacy_map_bloc.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/selector_widget.dart/cubit/selector_cubit.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/selector_widget.dart/selector/selector.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/map/pharmacy_map_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_pharmacy_widget.dart';
import 'package:inlek/locator_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PharmaciesScreen extends StatelessWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    List<PharmacyEntity> pharmacies =
        arguments['pharmacies'] as List<PharmacyEntity>;
    MapScreenType mapScreenType = arguments['mapScreenType'] as MapScreenType;
    ProductEntity product = arguments['product'] as ProductEntity;

    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        HomeScreenBloc homeBloc = context.read<HomeScreenBloc>();
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  PharmaciesScreenBloc(getCartPharmaciesUC: sl())
                    ..add(CheckProductAvailableDeliveryEvent())
                    ..add(
                      LoadPharmaciesDataEvent(pharmacies: pharmacies),
                    ),
            ),
            BlocProvider(
              create: (context) =>
                  PharmacyMapBloc(mapScreenType: mapScreenType),
            ),
          ],
          child: BlocConsumer<PharmaciesScreenBloc, PharmaciesScreenState>(
            listener: (context, state) async {
              await Future.delayed(Duration(milliseconds: 300));
              context.read<PharmacyMapBloc>().add(
                    InitPharmacyMapEvent(points: state.mapObjects),
                  );
            },
            builder: (context, pharmaciesState) {
              PharmaciesScreenBloc pharmaciesBloc =
                  context.read<PharmaciesScreenBloc>();

              return BlocProvider(
                create: (context) =>
                    SelectorCubit(index: pharmaciesState.selectorIndex),
                child: Scaffold(
                  backgroundColor: UiConstants.backgroundColor,
                  body: SafeArea(
                    child: Skeletonizer(
                      ignorePointers: false,
                      enabled: false,
                      child: Builder(
                        builder: (context) {
                          return Column(
                            children: [
                              CustomAppBar(
                                hintText: 'Искать аптеки',
                                controller: pharmaciesBloc.queryController,
                                title: 'Аптеки',
                                showBack: true,
                                action: Text(
                                  '${pharmaciesState.filteredPharmacies.length} аптек${pharmaciesState.filteredPharmacies.length % 10 == 1 && pharmaciesState.filteredPharmacies.length % 100 != 11 ? 'a' : ''}',
                                  style: UiConstants.textStyle3.copyWith(
                                    color: UiConstants.darkBlue2Color
                                        .withOpacity(.6),
                                  ),
                                ),
                                isShowFilterButton: true,
                                onTapFilterButton: () =>
                                    BottomSheetManager.showPharmacySortSheet(
                                        UiConstants.homeContext!, context,
                                        product: product),
                                onChangedField: (value) => pharmaciesBloc.add(
                                  ChangePharmacyQueryEvent(value),
                                ),
                              ),
                              Expanded(
                                child: homeState is InternetUnavailable
                                    ? InternetNoInternetConnectionWidget()
                                    : Padding(
                                        padding: getMarginOrPadding(
                                            top: 16,
                                            left: 20,
                                            right: 20,
                                            bottom:
                                                pharmaciesState.selectorIndex ==
                                                        0
                                                    ? 0
                                                    : 94),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment:
                                                  AlignmentDirectional.center,
                                              child: Selector(
                                                titlesList: const [
                                                  'Список',
                                                  'Карта'
                                                ],
                                                onTap: (int index) =>
                                                    pharmaciesBloc.add(
                                                  ChangeSelectorIndexEvent(
                                                      index),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 16.h),
                                            Expanded(
                                              child: pharmaciesState
                                                          .selectorIndex ==
                                                      0
                                                  ? pharmaciesState
                                                          .filteredPharmacies
                                                          .isEmpty
                                                      ? Center(
                                                          child: Text(
                                                            'По выбранным фильтрам аптек нет',
                                                            style: UiConstants
                                                                .textStyle3
                                                                .copyWith(
                                                                    color: UiConstants
                                                                        .darkBlueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800),
                                                          ),
                                                        )
                                                      : ListView(
                                                          shrinkWrap: true,
                                                          padding:
                                                              getMarginOrPadding(
                                                                  bottom: 94),
                                                          children: [
                                                            ListView.separated(
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                shrinkWrap:
                                                                    true,
                                                                itemBuilder: (context,
                                                                        index) =>
                                                                    ProductPharmacyWidget(
                                                                      pharmacy:
                                                                          pharmaciesState
                                                                              .filteredPharmacies[index],
                                                                    ),
                                                                separatorBuilder: (context,
                                                                        index) =>
                                                                    SizedBox(
                                                                        height: 8
                                                                            .h),
                                                                itemCount:
                                                                    pharmaciesState
                                                                        .filteredPharmacies
                                                                        .length)
                                                          ],
                                                        )
                                                  : PharmacyMapWidget(),
                                            )
                                          ],
                                        ),
                                      ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
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
