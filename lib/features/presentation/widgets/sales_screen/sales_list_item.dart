import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/custom_cache_manager.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/pages/profile/sales/sale_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SalesListItem extends StatelessWidget {
  const SalesListItem({
    super.key,
    required this.action,
    this.isOneElementInList = false,
    this.height,
  });

  final ActionEntity action;
  final bool isOneElementInList;
  final double? height;

  static const double _imageHeight = 128;

  @override
  Widget build(BuildContext context) {
    final productWhereDiscountDontNull = (action.actionProducts ?? [])
        .firstWhereOrNull((e) => e.discount != null);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        Routes.createRoute(
          SaleScreen(),
          settings: RouteSettings(
            name: Routes.saleScreen,
            arguments: {'id': action.actionId},
          ),
        ),
      ),
      child: Container(
        padding:
            isOneElementInList ? getMarginOrPadding(left: 16, right: 16) : null,
        width: isOneElementInList ? null : 296,
        height: height,
        decoration: BoxDecoration(
          color: UiConstants.whiteColor,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(),
            const SizedBox(height: 8),
            if (height != null)
              Expanded(
                child: _buildDetails(productWhereDiscountDontNull),
              )
            else
              _buildDetails(productWhereDiscountDontNull),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: _imageHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        child: CachedNetworkImage(
          height: _imageHeight,
          width: double.infinity,
          imageUrl: '${dotenv.env['PUBLIC_URL']!}${action.image}',
          fit: BoxFit.cover,
          cacheManager: CustomCacheManager(),
          errorWidget: (context, url, error) =>
              Icon(Icons.image, size: 72, color: UiConstants.white3Color),
          progressIndicatorBuilder: (context, url, progress) => Center(
            child: CircularProgressIndicator(color: UiConstants.pink2Color),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(ProductEntity? productWhereDiscountDontNull) {
    return Padding(
      padding: getMarginOrPadding(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (height != null)
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  action.pageTitle ?? '',
                  style: UiConstants.textStyle3.copyWith(
                    color: UiConstants.darkBlueColor,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          else
            Text(
              action.pageTitle ?? '',
              style: UiConstants.textStyle3.copyWith(
                color: UiConstants.darkBlueColor,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  Utils.formatActionDate(
                    action.createDttm,
                    action.endActionDate,
                  ),
                  style: UiConstants.textStyle8.copyWith(
                    color: UiConstants.darkBlue2Color.withOpacity(.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (productWhereDiscountDontNull != null) ...[
                const SizedBox(width: 8),
                Skeleton.unite(
                  child: Container(
                    padding: getMarginOrPadding(all: 4),
                    decoration: BoxDecoration(
                      color: UiConstants.pink2Color.withOpacity(.05),
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Text(
                      '-${productWhereDiscountDontNull.discount}%',
                      style: UiConstants.textStyle6
                          .copyWith(color: UiConstants.pink2Color),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
