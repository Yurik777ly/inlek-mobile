import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/custom_cache_manager.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/widgets/product_chip_widget.dart';

class ProductBannerItem extends StatelessWidget {
  final ProductEntity? product;

  const ProductBannerItem({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CachedNetworkImage(
          width: double.infinity,
          height: double.infinity,
          imageUrl: '${dotenv.env['PUBLIC_URL']!}${product?.image}',
          fit: BoxFit.fitHeight,
          cacheManager: CustomCacheManager(),
          errorWidget: (context, url, error) =>
              Icon(Icons.image, size: 56.dp, color: UiConstants.whiteColor),
          progressIndicatorBuilder: (context, url, progress) => Center(
            child: CircularProgressIndicator(color: UiConstants.pink2Color),
          ),
        ),
        Positioned(
          top: 8.dp,
          left: 20.dp,
          right: 20.dp,
          child: Wrap(
            spacing: 8.dp,
            runSpacing: 8.dp,
            children: [
              if (product?.productSticker != null)
                ProductChipWidget(
                    productChipType: ProductChipTypeExtension.fromString(
                        product!.productSticker!),
                    textStyle: UiConstants.textStyle8),
            ],
          ),
        )
      ],
    );
  }
}
