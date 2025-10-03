import 'package:flutter/material.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_characteristic_item.dart';

class ProductCharacteristicWidget extends StatelessWidget {
  final ProductEntity? product;

  const ProductCharacteristicWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductCharacteristicItem(
            title: 'Международное непатентованное название',
            subtitle: product!.mnn.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Порядок отпуска фактический',
            subtitle: product!.recipe.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Производитель', subtitle: product!.brand.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Страна производства', subtitle: product!.country.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Лекарственная форма', subtitle: product!.form.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Дозировка', subtitle: product!.dose.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'МНН англ/лат', subtitle: product!.mnnLat.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Штрих-код', subtitle: product!.code.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Форма выпуска', subtitle: product!.releaseForm.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Путь введения', subtitle: product!.productInsert.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Срок регистрации',
            subtitle: product!.productTimeRegister.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Регистрационное удостоверение',
            subtitle: product!.productRegister.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Дата регистрации',
            subtitle: product!.productDateRegister.orDash()),
        SizedBox(height: 8),
        ProductCharacteristicItem(
            title: 'Температура хранения',
            subtitle: product!.temperature.orDash()),
      ],
    );
  }
}
