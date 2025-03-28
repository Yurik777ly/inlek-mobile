import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
import 'package:inlek/features/presentation/widgets/products_screen/product_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductsGridWidget extends StatelessWidget {
  final bool isLoading;
  final bool isLoadingProducts;
  final List<ProductEntity> products;
  final ScrollController controller;

  const ProductsGridWidget(
      {super.key,
      required this.products,
      required this.isLoading,
      required this.isLoadingProducts,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    int itemCount = isLoading
        ? 4
        : isLoadingProducts
            ? products.length + 4
            : products.length;
    double itemHeight = 285.w;
    double itemWidth = 156.w;
    double blocksSize = itemHeight * (itemCount / 2).round();
    double mainAxisSpacingSize =
        8.w * ((itemCount / 2 - 1) > 0 ? (itemCount / 2 - 1) : 0).round();
    return SizedBox(
      height: (blocksSize + mainAxisSpacingSize),
      child: Skeleton.ignorePointer(
        child: Skeleton.shade(
          child: GridView.builder(
            controller: controller,
            padding: getMarginOrPadding(bottom: 94),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.w,
              childAspectRatio: itemWidth / itemHeight,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              print(isLoading);
              if (isLoadingProducts && index > products.length - 1) {
                return Skeletonizer(
                    enabled: isLoadingProducts,
                    child: Skeleton.unite(
                        child: ProductWidget(product: ProductEntity())));
              }
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  Routes.createRoute(
                    const ProductScreen(),
                    settings: RouteSettings(
                        name: Routes.productScreen,
                        arguments: products[index].productId),
                  ),
                ),
                child: ProductWidget(
                    product: isLoading ? ProductEntity() : products[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
