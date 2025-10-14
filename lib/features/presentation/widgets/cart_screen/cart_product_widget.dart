import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
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
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/available_pickup_chip.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/change_count_product_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/info_border_plate.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/only_pickup_chip.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/out_stock_chip.dart';
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
    this.cartBloc,
    this.onProductDeleted,
    this.onSelectionToggled,
    this.selectedProductIds,
    this.selectedPromoCodes,
  });

  final int index;
  final dynamic product;
  final ProductsListScreenType productsListScreenType;
  final BuildContext? screenContext;
  final CartScreenBloc? cartBloc;
  final Function(String productId, int count)? onProductDeleted;
  final Function(bool isChecked, String productId)? onSelectionToggled;
  final List<String>? selectedProductIds;
  final List<String>? selectedPromoCodes;

  @override
  Widget build(BuildContext context) {
    // Use provided bloc or try to get from context
    CartScreenBloc? effectiveCartBloc = cartBloc;
    if (effectiveCartBloc == null) {
      try {
        effectiveCartBloc = (screenContext ?? context).read<CartScreenBloc>();
      } catch (e) {}
    }

    // If we have a bloc, use BlocBuilder, otherwise build directly
    if (effectiveCartBloc != null) {
      return BlocBuilder<CartScreenBloc, CartScreenState>(
        buildWhen: (previous, current) => true,
        bloc: effectiveCartBloc,
        builder: (context, state) =>
            _buildContent(context, state, effectiveCartBloc),
      );
    } else {
      // Create a mock state for when bloc is not available
      final mockState = CartScreenState(
        cartData: null,
        selectedProductIds:
            (selectedProductIds ?? []).map((e) => int.tryParse(e) ?? 0).toSet(),
        selectedPromoCodes: const [],
      );
      return _buildContent(context, mockState, null);
    }
  }

  Widget _buildContent(BuildContext context, CartScreenState state,
      CartScreenBloc? effectiveCartBloc) {
    bool isLoadingProduct =
        product is! ProductEntity ? false : product.isLoading;
    String name = product is ProductEntity
        ? product.pagetitle ?? product.name
        : product.name;
    double? oldPrice = product.oldPrice;
    double? price = product.price;

    if ([ProductsListScreenType.cart, ProductsListScreenType.order]
        .contains(productsListScreenType)) {
      final cartProduct = (effectiveCartBloc?.state.cartData?.products ??
              state.cartData?.products ??
              [])
          .firstWhereOrNull((e) => e.productId == product.productId);
      if (cartProduct != null) {
        oldPrice = cartProduct.prices?.priceOld;
        price = cartProduct.prices?.price;
      }
    }

    return Stack(
      children: [
        DismissibleTile(
          onDismissed: (_) {
            if (effectiveCartBloc != null) {
              effectiveCartBloc.add(
                DeleteCartEvent(
                    context: context, productId: product.productId, count: 0),
              );
            } else if (onProductDeleted != null) {
              onProductDeleted!(product.productId, 0);
            }
          },
          direction: productsListScreenType == ProductsListScreenType.cart
              ? DismissibleTileDirection.horizontal
              : DismissibleTileDirection.none,
          key: UniqueKey(),
          borderRadius: BorderRadius.all(
            Radius.circular(16.r),
          ),
          delayBeforeResize: Duration.zero,
          overlayTransitionDuration: Duration.zero,
          movementDuration: Duration.zero,
          rtlBackground: const ColoredBox(color: UiConstants.redColor),
          rtlOverlayIndent: 0,
          rtlDismissedColor: UiConstants.redColor,
          rtlOverlay: SvgPicture.asset(Paths.deleteIconPath,
              height: 24, width: 24, color: UiConstants.whiteColor),
          rtlOverlayDismissed: SvgPicture.asset(Paths.deleteIconPath,
              height: 24, width: 24, color: UiConstants.whiteColor),
          ltrBackground: const ColoredBox(color: UiConstants.redColor),
          ltrOverlayIndent: 0,
          resizeDuration: Duration(milliseconds: 1),
          ltrDismissedColor: UiConstants.redColor,
          ltrOverlay: SvgPicture.asset(Paths.deleteIconPath,
              height: 24, width: 24, color: UiConstants.whiteColor),
          ltrOverlayDismissed: SvgPicture.asset(Paths.deleteIconPath,
              height: 24, width: 24, color: UiConstants.whiteColor),
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
                  Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (productsListScreenType ==
                                  ProductsListScreenType.cart &&
                              product.availability != 'absent')
                            Skeleton.keep(
                              child: Padding(
                                padding: getMarginOrPadding(right: 8),
                                child: CustomCheckbox(
                                  isChecked: state.selectedProductIds
                                      .contains(product.productId),
                                  onChanged: (isChecked) {
                                    if (effectiveCartBloc != null) {
                                      effectiveCartBloc.add(
                                        ToggleSelectionEvent(isChecked ?? false,
                                            product.productId),
                                      );
                                    } else if (onSelectionToggled != null) {
                                      onSelectionToggled!(isChecked ?? false,
                                          product.productId);
                                    }
                                  },
                                ),
                              ),
                            ),
                          Stack(
                            children: [
                              if (product.stockCount == 0)
                                Container(
                                  height: 104,
                                  width: 104,
                                  color: UiConstants.whiteColor.withOpacity(.6),
                                ),
                              CachedNetworkImage(
                                height: 104,
                                width: 104,
                                imageUrl:
                                    '${dotenv.env['PUBLIC_URL']!}${product.image}',
                                fit: BoxFit.contain,
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

                              /*Positioned(
                                  top: 4,
                                  left: 8,
                                  right: 8,
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
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
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((name as String?).orDash(),
                                    style: UiConstants.textStyle8.copyWith(
                                        color: UiConstants.darkBlueColor),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis),
                                SizedBox(height: 8),
                                if (product.stockCount == 0)
                                  Padding(
                                    padding: getMarginOrPadding(bottom: 4),
                                    child: product?.otherPharmacy == 1 &&
                                            (effectiveCartBloc
                                                        ?.state.cartType ??
                                                    state.cartType) !=
                                                TypeReceiving.pickup
                                        ? AvailablePickupChip()
                                        : OutStockChip(),
                                  )
                                else if (product.isAlcohol || product.isRecipe)
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
                                                radius: 12,
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
                                    if (product.availability != 'absent')
                                      Expanded(
                                        child: ProductPrice(
                                            oldPrice: oldPrice,
                                            price: price,
                                            productsListScreenType:
                                                productsListScreenType),
                                      ),
                                    if (productsListScreenType ==
                                            ProductsListScreenType.cart &&
                                        product.availability != 'absent')
                                      Padding(
                                        padding: getMarginOrPadding(
                                            top: 2, bottom: 2, left: 8),
                                        child: ChangeCountProductWidget(
                                            product: product,
                                            cartOrProductType:
                                                CartOrProductType.cart,
                                            screenContext: screenContext,
                                            cartBloc: effectiveCartBloc),
                                      )
                                    else if (productsListScreenType ==
                                        ProductsListScreenType.order)
                                      Text(
                                        '${product.quantity ?? product.count} шт.',
                                        style: UiConstants.textStyle8.copyWith(
                                          color: UiConstants.darkBlueColor
                                              .withOpacity(.6),
                                        ),
                                      )
                                  ],
                                ),
                                if (productsListScreenType ==
                                        ProductsListScreenType.pharmacy &&
                                    product.stockCount != 0)
                                  Padding(
                                    padding: getMarginOrPadding(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_rounded,
                                            color: UiConstants.greenColor),
                                        SizedBox(width: 4),
                                        Text(
                                          'В наличии ${product.stockCount} шт.',
                                          style:
                                              UiConstants.textStyle8.copyWith(
                                            color: UiConstants.blackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (product.stockCount == 0)
                        Container(
                          height: 104,
                          color: UiConstants.whiteColor.withOpacity(.5),
                        ),
                    ],
                  ),
                  if (product is ProductEntity &&
                      product.prices?.discountWithoutPromos != 0 &&
                      (product.prices?.appliedPromocodes ?? [])
                          .any((e) => state.selectedPromoCodes.contains(e)))
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

        // такой баг, что если нажимать на каунтер быстро, то открывалась карточка товара, решил, что нужно ограничить область клика
        Positioned.fill(
          right: 100,
          child: GestureDetector(
            onTap: () {
              Navigator.of(screenContext ?? context).push(
                Routes.createRoute(
                  const ProductScreen(),
                  settings: RouteSettings(
                    name: Routes.productScreen,
                    arguments: {'id': product.productId},
                  ),
                ),
              );
            },
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
