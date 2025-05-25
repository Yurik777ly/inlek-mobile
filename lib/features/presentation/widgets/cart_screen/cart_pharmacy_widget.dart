import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/pharmacy_available_products_chip.dart';

class CartPharmacyWidget extends StatelessWidget {
  const CartPharmacyWidget({
    super.key,
    required this.pharmacy,
    this.onButtonTap,
    this.screenContext,
  });

  final PharmacyEntity pharmacy;

  final Function()? onButtonTap;
  final BuildContext? screenContext;

  @override
  Widget build(BuildContext context) {
    CartScreenBloc? cartBloc = screenContext?.read<CartScreenBloc>();
    return BlocBuilder<CartScreenBloc, CartScreenState>(
      bloc: screenContext?.read<CartScreenBloc>(),
      buildWhen: (previous, current) => screenContext == null,
      builder: (context, state) {
        /*final Set<int> selectedProductIds =
            cartBloc?.state.selectedProductIds ?? {};

        // Проверяем, что в аптеке есть все выбранные товары
        final bool allSelectedProductsExist = selectedProductIds.every(
          (id) => pharmacy.products.any((product) => product.productId == id),
        );

        // Фильтруем продукты, которые совпадают с выбранными
        final List<ProductEntity> filteredProducts = pharmacy.products
            .where((product) => selectedProductIds.contains(product.productId))
            .toList();*/

        // Проверяем, что у всех этих продуктов availability = 'full'
        final bool allAvailable = pharmacy.products.every(
          (product) => product.availability == 'full',
        );

        // Финальный флаг: и все есть, и все full
        final bool allProductsAvailable = allAvailable;

        //bool allProductsAvailable = state.selectedProductIds.every(
        //    (e) => pharmacy.availableProducts.map((e) => e.id).contains(e));
        return Container(
          padding: getMarginOrPadding(top: 16, bottom: 16, left: 20, right: 20),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pharmacy.pageTitle ?? pharmacy.pharmacyName ?? '-',
                style: UiConstants.textStyle3.copyWith(
                    color: UiConstants.darkBlueColor,
                    fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 16.h),
              Text(
                pharmacy.address ?? '-',
                style: UiConstants.textStyle2
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              Padding(
                padding: getMarginOrPadding(top: 16),
                child: PharmacyAvailableProductsChip(
                    allProductsAvailable: allProductsAvailable),
              ),
              if (onButtonTap != null)
                Padding(
                  padding: getMarginOrPadding(top: 16),
                  child: AppButtonWidget(
                      isFilled: allProductsAvailable,
                      showBorder: !allProductsAvailable,
                      textColor:
                          allProductsAvailable ? null : UiConstants.purpleColor,
                      isActive: true,
                      text: allProductsAvailable ? 'Выбрать' : 'Подробнее',
                      onTap: onButtonTap),
                )
            ],
          ),
        );
      },
    );
  }
}
