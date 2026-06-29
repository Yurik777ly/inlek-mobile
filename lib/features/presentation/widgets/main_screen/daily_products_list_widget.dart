import 'package:flutter/material.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/widgets/products_screen/product_widget.dart';

class ProductsListWidget extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductsListWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.separated(
          padding: getMarginOrPadding(left: 20, right: 20),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) =>
              ProductWidget(product: products[index]),
          separatorBuilder: (context, index) => SizedBox(width: 8),
          itemCount: products.length),
    );
  }
}
