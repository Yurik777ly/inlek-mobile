import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/pages/catalog/pharmacies_screen.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_receiving_method_item.dart';

class ProductReceivingMethodsWidget extends StatelessWidget {
  final List<PharmacyEntity> pharmacies;
  final ProductEntity product;
  final bool isLoadingPharmacies;

  const ProductReceivingMethodsWidget(
      {super.key,
      required this.pharmacies,
      required this.product,
      this.isLoadingPharmacies = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProductReceivingMethodItem(
            isLoading: isLoadingPharmacies,
            title: 'В наличии',
            subtitle:
                'в ${pharmacies.length} ${Utils.getPharmacyLabel(pharmacies.length)}',
            onTap: () => Navigator.of(context).push(
              Routes.createRoute(
                const PharmaciesScreen(),
                settings: RouteSettings(
                  name: Routes.pharmaciesScreen,
                  arguments: {
                    "mapScreenType": MapScreenType.product,
                    "pharmacies": pharmacies,
                    "product": product
                  },
                ),
              ),
            ),
            onTapArrowButton: () {},
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ProductReceivingMethodItem(
              title: 'Самовывоз', subtitle: 'от 30 мин'),
        ),
      ],
    );
  }
}
