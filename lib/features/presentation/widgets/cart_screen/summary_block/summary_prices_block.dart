import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/summary_block/summary_price_item.dart';

class SummaryPricesBlock extends StatelessWidget {
  const SummaryPricesBlock(
      {super.key, this.screenContext, required this.products});

  final BuildContext? screenContext;
  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartScreenBloc, CartScreenState>(
      bloc: screenContext?.read<CartScreenBloc>(),
      builder: (context, state) {
        // Подсчёт итоговых значений
        final productsTotal = calculateProductsTotal(products);
        //final productsFinalTotal = calculateProductsFinalTotal(products);
        final discount = calculateDiscount(products);
        final promoDiscount = calculatePromoDiscount(products);

        // Добавление стоимости доставки, если она включена
        final deliveryPrice = state.cartType == TypeReceiving.delivery
            ? state.deliveryPayment.toDouble()
            : 0.0;

        // Расчёт итоговой суммы
        final totalPrice =
            productsTotal + deliveryPrice - promoDiscount - discount;

        // Отображение итогового блока с ценами
        return Column(
          children: [
            SummaryPriceItem(
              title: '${products.length} товаров',
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
            SummaryPriceItem(
              title: 'Итого',
              price: totalPrice,
              isTotal: true,
            ),
          ],
        );
      },
    );
  }
}

// Получает актуальное количество товара: учитывает наличие на складе и запрошенное количество
int getActualQuantity(ProductEntity product) {
  final required = product.requiredQuantity ?? product.quantity ?? 1;
  final stock = product.stockCount ?? 1;
  return required > stock ? stock : required;
}

// Считает сумму всех товаров по старой цене
double calculateProductsTotal(List<ProductEntity> products) {
  return products.fold(0.0, (sum, product) {
    final price = product.prices?.priceOld ?? product.prices?.price ?? 0.0;
    return sum + price * getActualQuantity(product);
  });
}

// Считает итоговую сумму всех товаров по финальной цене
double calculateProductsFinalTotal(List<ProductEntity> products) {
  return products.fold(0.0, (sum, product) {
    final finalPrice = product.prices?.price ?? 0.0;
    return sum + finalPrice * getActualQuantity(product);
  });
}

// Считает скидку по старой цене (разница между старой и новой ценой, если есть)
double calculateDiscount(List<ProductEntity> products) {
  return products.fold(0.0, (sum, product) {
    final oldPrice = product.prices?.priceOld ?? product.prices?.price ?? 0.0;
    final newPrice = product.prices?.price ?? 0.0;
    final discount = oldPrice > newPrice ? (oldPrice - newPrice) : 0.0;
    return sum + discount * getActualQuantity(product);
  });
}

// Считает суммарную скидку по всем промокодам ко всем товарам
double calculatePromoDiscount(List<ProductEntity> products) {
  return products.fold(0.0, (sum, product) {
    final prices = product.prices;
    if (prices == null) return sum;

    // Если есть скидка без промокодов — промокоды не применяются
    if ((prices.discountWithoutPromos ?? 0) != 0) return sum;

    final basePrice = prices.price ?? 0.0;
    final promocodes = prices.appliedPromocodes ?? [];

    // Применяем промокоды последовательно
    double discountedPrice = basePrice;
    for (final promo in promocodes) {
      discountedPrice *= (1 - promo.promocodePercent / 100);
    }

    // Считаем разницу — это сумма скидки по промокодам
    final discountPerItem = basePrice - discountedPrice;

    // Умножаем на актуальное количество
    final quantity = getActualQuantity(product);

    return sum + discountPerItem * quantity;
  });
}
