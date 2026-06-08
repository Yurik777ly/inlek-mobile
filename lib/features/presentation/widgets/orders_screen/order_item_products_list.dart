import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/custom_cache_manager.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

Widget _buildOrderProductThumb(String? image) {
  final normalizedImage = image?.trim();
  final baseUrl = dotenv.env['PUBLIC_URL'];
  final imageUrl = normalizedImage != null &&
          normalizedImage.isNotEmpty &&
          baseUrl != null &&
          baseUrl.isNotEmpty
      ? (normalizedImage.startsWith('http')
          ? normalizedImage
          : '$baseUrl$normalizedImage')
      : null;

  if (imageUrl == null) {
    return SvgPicture.asset(
      Paths.drugTemplateIconPath,
      height: 56,
      width: 56,
    );
  }

  return CachedNetworkImage(
    height: 56,
    width: 56,
    imageUrl: imageUrl,
    fit: BoxFit.fitHeight,
    cacheManager: CustomCacheManager(),
    errorWidget: (context, url, error) => SvgPicture.asset(
      Paths.drugTemplateIconPath,
      height: 56,
      width: 56,
    ),
    progressIndicatorBuilder: (context, url, progress) => Center(
      child: CircularProgressIndicator(color: UiConstants.pink2Color),
    ),
  );
}

class OrderItemProductsList extends StatelessWidget {
  const OrderItemProductsList({super.key, required this.orderProducts});

  final List<ProductEntity> orderProducts;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: UiConstants.white2Color),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildOrderProductThumb(orderProducts[index].image),
                ),
              ),
          separatorBuilder: (context, index) => SizedBox(width: 4),
          itemCount: orderProducts.length),
    );
  }
}
