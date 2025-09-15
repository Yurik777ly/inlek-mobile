import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/summary_block/summary_price_item.dart';

class SummaryPharmacyPricesBlock extends StatelessWidget {
  const SummaryPharmacyPricesBlock(
      {super.key, this.screenContext, required this.pharmacy});

  final BuildContext? screenContext;
  final CartPharmacyEntity pharmacy;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartScreenBloc, CartScreenState>(
      bloc: screenContext?.read<CartScreenBloc>(),
      builder: (context, state) {
        // Подсчёт итоговых значений
        final productsTotal = calculateProductsTotal(pharmacy.products);
        //final productsFinalTotal = calculateProductsFinalTotal(products);
        final discount = calculateDiscount(pharmacy.products);
        final promoDiscount =
            calculatePromoDiscount(pharmacy.products, state.selectedPromoCodes);

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
              title: '${pharmacy.products.length} товаров',
              price: productsTotal,
            ),
            if (state.cartType == TypeReceiving.delivery)
              Padding(
                padding: getMarginOrPadding(top: 8),
                child:
                    SummaryPriceItem(title: 'Доставка', price: deliveryPrice),
              ),
            if (discount != 0)
              Padding(
                padding: getMarginOrPadding(top: 8),
                child: SummaryPriceItem(
                  title: 'Скидка',
                  price: -discount,
                  isDiscount: true,
                ),
              ),
            if (promoDiscount != 0)
              Padding(
                padding: getMarginOrPadding(top: 8),
                child: SummaryPriceItem(
                  title: 'Скидка по промокоду',
                  price: -promoDiscount,
                  isDiscount: true,
                ),
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
int getActualQuantity(CartPharmaciesProductEntity product) {
  final required = product.requestedQuantity!;
  final stock = product.stockCount!;
  return required > stock ? stock : required;
}

// Считает сумму всех товаров по старой цене
double calculateProductsTotal(List<CartPharmaciesProductEntity> products) {
  return products.fold(0.0, (sum, product) {
    final price = product.oldPrice;
    return sum + price! * getActualQuantity(product);
  });
}

// Считает итоговую сумму всех товаров по финальной цене
double calculateProductsFinalTotal(List<CartPharmaciesProductEntity> products) {
  return products.fold(0.0, (sum, product) {
    final finalPrice = product.price;
    return sum + finalPrice! * getActualQuantity(product);
  });
}

// Считает скидку по старой цене (разница между старой и новой ценой, если есть)
double calculateDiscount(List<CartPharmaciesProductEntity> products) {
  return products.fold(0.0, (sum, product) {
    final oldPrice = product.oldPrice;
    final newPrice = product.price;
    final discount = oldPrice! > newPrice! ? (oldPrice - newPrice) : 0.0;
    return sum + discount * getActualQuantity(product);
  });
}

// Считает суммарную скидку по всем промокодам ко всем товарам
double calculatePromoDiscount(
  List<CartPharmaciesProductEntity> products,
  List<PromocodeEntity> selectedPromoCodes,
) {
  return products.fold(0.0, (sum, product) {
    final basePrice = product.price;
    final quantity = getActualQuantity(product);

    // Промокоды, применимые к текущему товару
    final applicablePromos = selectedPromoCodes.where((promo) {
      final now = DateTime.now();
      final isDateValid = (promo.begin == null || now.isAfter(promo.begin!)) &&
          (promo.end == null || now.isBefore(promo.end!));
      final meetsMinAmount =
          promo.minAmount == null || basePrice! >= promo.minAmount!;
      return isDateValid && meetsMinAmount;
    });

    // Применяем все подходящие промокоды последовательно
    double discountedPrice = basePrice!;
    for (final promo in applicablePromos) {
      discountedPrice *= (1 - promo.promocodePercent / 100);
    }

    final discountPerItem = basePrice - discountedPrice;
    return sum + discountPerItem * quantity;
  });
}
