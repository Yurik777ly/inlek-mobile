import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/city_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/search/search_screen_page.dart';
import 'package:inlek/features/presentation/pages/starts/select_region_screen.dart';
import 'package:inlek/features/presentation/widgets/filter_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchProductAppBar extends StatelessWidget {
  const SearchProductAppBar({
    super.key,
    this.onTapBack,
    this.screenContext,
    this.showFilters = false,
    this.showLocationChip = false,
    this.showBack = false,
  });

  final Function()? onTapBack;
  final BuildContext? screenContext;
  final bool showFilters;
  final bool showLocationChip;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: UiConstants.whiteColor,
      padding: getMarginOrPadding(top: 8, bottom: 8, right: 20, left: 20),
      child: Column(
        children: [
          Row(
            children: [
              if (showLocationChip)
                Skeleton.replace(
                  child: GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      dynamic city =
                          await Navigator.of(context, rootNavigator: true).push(
                        Routes.createRoute(
                          const SelectRegionScreen(
                              selectRegionScreenType:
                                  SelectRegionScreenType.main),
                        ),
                      );

                      if (city != null && city is CityEntity) {
                        context
                            .read<CartScreenBloc>()
                            .add(ChangeAvailableDeliveryEvent(city: city));
                      }
                    },
                    child: Padding(
                      padding: getMarginOrPadding(right: 8),
                      child: SvgPicture.asset(Paths.locationIconPath,
                          width: 24, height: 24),
                    ),
                  ),
                ),
              if (showBack)
                Padding(
                  padding: getMarginOrPadding(right: 10),
                  child: GestureDetector(
                    onTap: onTapBack ?? () => Navigator.pop(context),
                    child: SvgPicture.asset(Paths.arrowBackIconPath,
                        color: UiConstants.darkBlue2Color.withOpacity(.6),
                        width: 24,
                        height: 24),
                  ),
                ),
              Expanded(
                child: Skeleton.ignorePointer(
                  child: Skeleton.shade(
                    child: GestureDetector(
                      onTap: () {
                        // Если это не экран поиска, то переходим на него
                        if (ModalRoute.of(context)?.settings.name !=
                            Routes.searchScreen) {
                          Navigator.push(
                            context,
                            Routes.createRoute(
                              const SearchScreenPage(),
                              settings:
                                  RouteSettings(name: Routes.searchScreen),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: getMarginOrPadding(
                            left: 16, right: 16, top: 12, bottom: 12),
                        decoration: BoxDecoration(
                          color: UiConstants.white2Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Skeleton.ignore(
                              child: SvgPicture.asset(Paths.searchIconPath),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Искать препараты',
                              style: UiConstants.textStyle3.copyWith(
                                color:
                                    UiConstants.darkBlue2Color.withOpacity(.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (showFilters)
                Padding(
                  padding: getMarginOrPadding(left: 8),
                  child: Skeleton.ignorePointer(
                    child: FilterButton(
                      onTap: () => BottomSheetManager.showProductsFilterSheet(
                          screenContext!),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
}
