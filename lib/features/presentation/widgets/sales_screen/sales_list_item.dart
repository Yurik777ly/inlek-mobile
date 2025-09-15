import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/extensions.dart';
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
    this.isExpanded = true,
    required this.action,
    this.isOneElementInList = false,
  });

  final ActionEntity action;
  final bool isExpanded;
  final bool isOneElementInList;

  @override
  Widget build(BuildContext context) {
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
        width: isOneElementInList ? null : 296.dp,
        decoration: BoxDecoration(
          color: UiConstants.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Expanded(
              flex: isExpanded ? 1 : 0,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r),
                ),
                child: CachedNetworkImage(
                  height: 128.dp,
                  width: double.infinity,
                  imageUrl: '${dotenv.env['PUBLIC_URL']!}${action.image}',
                  fit: BoxFit.fill,
                  cacheManager: CustomCacheManager(),
                  errorWidget: (context, url, error) => Icon(Icons.image,
                      size: 72.dp, color: UiConstants.white3Color),
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(
                        color: UiConstants.pink2Color),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.dp),
            Padding(
              padding: getMarginOrPadding(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  Text(action.pageTitle ?? '',
                      style: UiConstants.textStyle3.copyWith(
                          color: UiConstants.darkBlueColor,
                          fontWeight: FontWeight.w800),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8.dp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Utils.formatActionDate(
                            action.createDttm, action.endActionDate),
                        style: UiConstants.textStyle8.copyWith(
                          color: UiConstants.darkBlue2Color.withOpacity(.6),
                        ),
                      ),
                      Skeleton.unite(
                        child: Container(
                          padding: getMarginOrPadding(all: 4),
                          decoration: BoxDecoration(
                            color: UiConstants.pink2Color.withOpacity(.05),
                            borderRadius: BorderRadius.circular(200.r),
                          ),
                          child: Builder(builder: (context) {
                            ProductEntity? productWhereDiscountDontNull =
                                (action.actionProducts ?? []).firstWhereOrNull(
                                    (e) => e.discount != null);
                            return Text(
                              '-${productWhereDiscountDontNull?.discount}%',
                              style: UiConstants.textStyle6
                                  .copyWith(color: UiConstants.pink2Color),
                            );
                          }),
                        ),
                      ),
                    ],
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
