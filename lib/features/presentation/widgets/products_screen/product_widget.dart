import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/custom_cache_manager.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/change_count_product_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/product_price.dart';
import 'package:inlek/features/presentation/widgets/product_chip_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_sale_chip.dart';

class ProductWidget extends StatelessWidget {
  final ProductEntity product;

  const ProductWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        Routes.createRoute(
          const ProductScreen(),
          settings: RouteSettings(
            name: Routes.productScreen,
            arguments: {'id': product.productId},
          ),
        ),
      ),
      child: Container(
        width: 148.dp,
        decoration: BoxDecoration(
          color: UiConstants.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: CachedNetworkImage(
                    height: 112.dp,
                    width: double.infinity,
                    imageUrl: '${dotenv.env['PUBLIC_URL']!}${product.image}',
                    fit: BoxFit.fitHeight,
                    cacheManager: CustomCacheManager(),
                    errorWidget: (context, url, error) => SvgPicture.asset(
                        Paths.drugTemplateIconPath,
                        height: double.infinity),
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child: CircularProgressIndicator(
                          color: UiConstants.pink2Color),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: getMarginOrPadding(all: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.pagetitle ?? '-',
                            style: UiConstants.textStyle8
                                .copyWith(color: UiConstants.darkBlueColor),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 8.dp),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ProductPrice(
                                price: product.price,
                                oldPrice: product.oldPrice,
                                productsListScreenType:
                                    ProductsListScreenType.pharmacy),
                            if (product.discount != null &&
                                product.discount != 0)
                              ProductSaleChip(discount: product.discount ?? 0)
                          ],
                        ),
                        Spacer(),
                        BlocBuilder<CartScreenBloc, CartScreenState>(
                          builder: (context, state) {
                            return ChangeCountProductWidget(product: product);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4.dp,
              left: 8.dp,
              right: 8.dp,
              child: Wrap(
                spacing: 4.dp,
                runSpacing: 4.dp,
                children: [
                  if (product.productSticker != null)
                    ProductChipWidget(
                      productChipType: ProductChipTypeExtension.fromString(
                          product.productSticker!),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
