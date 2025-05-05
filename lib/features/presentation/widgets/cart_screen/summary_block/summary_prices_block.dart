import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/summary_block/summary_price_item.dart';

class SummaryPricesBlock extends StatelessWidget {
  const SummaryPricesBlock({super.key, this.screenContext});

  final BuildContext? screenContext;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartScreenBloc, CartScreenState>(
      bloc: screenContext?.read<CartScreenBloc>(),
      builder: (context, state) {
        final selectedProducts = state.cartData?.products
                ?.where((product) =>
                    state.selectedProductIds.contains(product.productId))
                .toList() ??
            [];

        // Считаем сумму всех товаров
        final productsTotal = selectedProducts.fold<double>(
          0,
          (sum, product) =>
              sum +
              (product.oldPrice ?? product.price ?? 0) *
                  (product.quantity ?? 1),
        );

        // Считаем скидку от старой цены
        final discount = selectedProducts.fold<double>(
          0,
          (sum, product) {
            final oldPrice = product.oldPrice ?? product.price ?? 0;
            final price = product.price ?? 0;
            return sum +
                (oldPrice > price
                    ? (oldPrice - price) * (product.quantity ?? 1)
                    : 0);
          },
        );

        // Считаем скидку по промокоду
        final promoDiscount = selectedProducts.fold<double>(
          0,
          (sum, product) {
            final appliedPromo = state.availablePromoCodes.firstWhereOrNull(
              (promo) =>
                  promo.productId == product.productId &&
                  state.selectedPromoCodes.contains(promo),
            );

            if (appliedPromo != null) {
              final productDiscount =
                  (product.price ?? 0) * (appliedPromo.promocodePercent / 100);
              return sum + productDiscount * (product.quantity ?? 1);
            }
            return sum;
          },
        );

        final deliveryPrice = state.cartType == TypeReceiving.delivery
            ? state.deliveryPayment.toDouble()
            : 0.0;

        // Итоговая сумма
        final totalPrice =
            productsTotal + deliveryPrice - discount - promoDiscount;

        return Column(
          children: [
            SummaryPriceItem(
              title: '${selectedProducts.length} товаров',
              price: productsTotal,
            ),
            if (state.cartType == TypeReceiving.delivery)
              Padding(
                padding: getMarginOrPadding(top: 8),
                child:
                    SummaryPriceItem(title: 'Доставка', price: deliveryPrice),
              ),
            SizedBox(height: 8.h),
            SummaryPriceItem(
              title: 'Скидка',
              price: -discount,
              isDiscount: true,
            ),
            SizedBox(height: 8.h),
            SummaryPriceItem(
              title: 'Скидка по промокоду',
              price: -promoDiscount,
              isDiscount: true,
            ),
            Padding(
              padding: getMarginOrPadding(top: 16, bottom: 16),
              child: Divider(color: UiConstants.white5Color),
            ),
            SummaryPriceItem(title: 'Итого', price: totalPrice, isTotal: true),
          ],
        );
      },
    );
  }
}
