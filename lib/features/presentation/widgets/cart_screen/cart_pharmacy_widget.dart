import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/pharmacy_available_products_chip.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CartPharmacyWidget extends StatelessWidget {
  const CartPharmacyWidget({
    super.key,
    required this.pharmacy,
    this.onButtonTap,
    this.screenContext,
    this.isLoading = false,
    this.isShowAvailableCount = false,
  });

  final CartPharmacyEntity pharmacy;
  final bool isLoading;
  final Function()? onButtonTap;
  final BuildContext? screenContext;
  final bool isShowAvailableCount;

  @override
  Widget build(BuildContext context) {
    //CartScreenBloc? cartBloc = screenContext?.read<CartScreenBloc>();
    return Skeletonizer(
      ignoreContainers: true,
      enabled: isLoading,
      child: BlocBuilder<CartScreenBloc, CartScreenState>(
        bloc: screenContext?.read<CartScreenBloc>(),
        buildWhen: (previous, current) => screenContext == null,
        builder: (context, state) {
          // Финальный флаг: и все есть, и все full
          final bool allProductsAvailable = pharmacy.availability == 'full';

          return Container(
            padding:
                getMarginOrPadding(top: 16, bottom: 16, left: 20, right: 20),
            decoration: BoxDecoration(
              color: UiConstants.whiteColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pharmacy.pharmacyName,
                  style: UiConstants.textStyle3.copyWith(
                      color: UiConstants.darkBlueColor,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 16),
                Text(
                  pharmacy.address,
                  style: UiConstants.textStyle2
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                16.ph,
                PharmacyAvailableProductsChip(
                  availability: pharmacy.availability,
                  sumAvailability: pharmacy.sumAvailability,
                  isShowAvailableCount: isShowAvailableCount,
                ),
                if (onButtonTap != null)
                  Padding(
                    padding: getMarginOrPadding(top: 16),
                    child: AppButtonWidget(
                        isFilled: allProductsAvailable,
                        showBorder: !allProductsAvailable,
                        textColor: allProductsAvailable
                            ? null
                            : UiConstants.purpleColor,
                        isActive: true,
                        text: allProductsAvailable ? 'Выбрать' : 'Подробнее',
                        onTap: onButtonTap),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
