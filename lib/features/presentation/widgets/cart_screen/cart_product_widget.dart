import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dismissible_tile/flutter_dismissible_tile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/custom_cache_manager.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/change_count_product_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/info_border_plate.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/only_pickup_chip.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/product_price.dart';
import 'package:inlek/features/presentation/widgets/custom_checkbox.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CartProductWidget extends StatelessWidget {
  const CartProductWidget({
    super.key,
    required this.index,
    required this.product,
    required this.productsListScreenType,
    this.screenContext,
  });

  final int index;
  final ProductEntity product;
  final ProductsListScreenType productsListScreenType;
  final BuildContext? screenContext;

  @override
  Widget build(BuildContext context) {
    bool isLoadingProduct = product.price == null;

    return BlocBuilder<CartScreenBloc, CartScreenState>(
      bloc: screenContext?.read<CartScreenBloc>(),
      buildWhen: (previous, current) => screenContext == null,
      builder: (context, state) {
        final bloc = (screenContext ?? context).read<CartScreenBloc>();

        return GestureDetector(
          child: DismissibleTile(
            onDismissed: (_) => bloc.add(
              DeleteProductEvent(context, product.productId!),
            ),
            direction: productsListScreenType == ProductsListScreenType.cart
                ? DismissibleTileDirection.rightToLeft
                : DismissibleTileDirection.none,
            key: UniqueKey(),
            borderRadius: BorderRadius.all(
              Radius.circular(16.r),
            ),
            delayBeforeResize: const Duration(milliseconds: 500),
            rtlBackground: const ColoredBox(color: UiConstants.redColor),
            rtlOverlayIndent: 0,
            rtlDismissedColor: UiConstants.redColor,
            rtlOverlay: SvgPicture.asset(Paths.deleteIconPath,
                height: 24.w, width: 24.w, color: UiConstants.whiteColor),
            rtlOverlayDismissed: SvgPicture.asset(Paths.deleteIconPath,
                height: 24.w, width: 24.w, color: UiConstants.whiteColor),
            child: Container(
              padding: getMarginOrPadding(all: 8),
              decoration: BoxDecoration(
                color: UiConstants.whiteColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Skeletonizer(
                ignorePointers: false,
                enabled: isLoadingProduct,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (productsListScreenType ==
                            ProductsListScreenType.cart)
                          Skeleton.keep(
                            child: CustomCheckbox(
                              isChecked: state.selectedProductIds
                                  .contains(product.productId),
                              onChanged: (isChecked) => bloc.add(
                                ToggleSelectionEvent(
                                    isChecked, product.productId!),
                              ),
                            ),
                          ),
                        SizedBox(width: 8.w),
                        Stack(
                          children: [
                            CachedNetworkImage(
                              height: 104.w,
                              width: 104.w,
                              imageUrl:
                                  '${dotenv.env['PUBLIC_URL']!}${product.image}',
                              fit: BoxFit.fitHeight,
                              cacheManager: CustomCacheManager(),
                              errorWidget: (context, url, error) =>
                                  SvgPicture.asset(Paths.drugTemplateIconPath,
                                      height: double.infinity),
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                child: CircularProgressIndicator(
                                    color: UiConstants.pink2Color),
                              ),
                            ),
                            /*if (!inStock)
                              Container(
                                height: 104.w,
                                width: 104.w,
                                color: UiConstants.whiteColor.withOpacity(.6),
                              ),
                            Positioned(
                              top: 4.h,
                              left: 8.w,
                              right: 8.w,
                              child: Wrap(
                                spacing: 4.w,
                                runSpacing: 4.w,
                                children: [
                                  if (product.productSticker != null)
                                    ProductChipWidget(
                                      productChipType:
                                          ProductChipTypeExtension.fromString(
                                              product.productSticker!),
                                    ),
                                ],
                              ),
                            )*/
                          ],
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((product.pagetitle ?? product.name).orDash(),
                                  style: UiConstants.textStyle8.copyWith(
                                      color: UiConstants.darkBlueColor),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis),
                              SizedBox(height: 8.h),
                              /*if (!inStock)
                                Padding(
                                  padding: getMarginOrPadding(bottom: 4),
                                  child: OutStockChip(),
                                ),*/
                              if (product.delivery == TypeReceiving.pickup)
                                Padding(
                                  padding: getMarginOrPadding(bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      OnlyPickupChip(),
                                      /*if (widget.productsListScreenType ==
                                          ProductsListScreenType.order)
                                        Skeleton.ignore(
                                          child: CircleAvatar(
                                            backgroundColor:
                                                UiConstants.pink2Color,
                                            radius: 12.w,
                                            child: Padding(
                                              padding:
                                                  getMarginOrPadding(all: 4),
                                              child: SvgPicture.asset(
                                                  Paths.replaceIconPath,
                                                  color:
                                                      UiConstants.whiteColor),
                                            ),
                                          ),
                                        )*/
                                    ],
                                  ),
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: productsListScreenType ==
                                        ProductsListScreenType.order
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment
                                        .center, // TODO: если нет скидки, то CrossAxisAlignment.end
                                children: [
                                  Expanded(
                                    child: ProductPrice(product: product),
                                  ),
                                  if (productsListScreenType !=
                                      ProductsListScreenType.order)
                                    Padding(
                                      padding: getMarginOrPadding(
                                          top: 2, bottom: 2, left: 8),
                                      child: ChangeCountProductWidget(
                                          product: product,
                                          cartOrProductType:
                                              CartOrProductType.cart,
                                          screenContext: screenContext),
                                    ),
                                  if (productsListScreenType ==
                                      ProductsListScreenType.order)
                                    Text(
                                      '${product.quantity ?? product.count} шт.',
                                      style: UiConstants.textStyle8.copyWith(
                                        color: UiConstants.darkBlueColor
                                            .withOpacity(.6),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (product.discount != null &&
                        state.selectedPromoCodes.isNotEmpty)
                      Padding(
                        padding: getMarginOrPadding(top: 8),
                        child: InfoBorderPlate(
                            imagePath: Paths.stockIconPath,
                            title:
                                'Этот товар уже со скидкой, промокод не действует'),
                      ),
                    //if (widget.index % 3 == 2)
                    //  Padding(
                    //    padding: getMarginOrPadding(top: 8),
                    //    child: ProductStockChip(),
                    //  )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
