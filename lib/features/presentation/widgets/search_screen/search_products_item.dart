import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/custom_cache_manager.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';

class SearchProductsItem extends StatelessWidget {
  const SearchProductsItem(
      {super.key, required this.product, required this.onProductTap});

  final ProductEntity product;
  final Function() onProductTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onProductTap,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.transparent,
        child: SizedBox(
          height: 60.dp,
          child: Row(
            children: [
              ClipRRect(
                child: CachedNetworkImage(
                  height: 60.dp,
                  width: 60.dp,
                  imageUrl: '${dotenv.env['PUBLIC_URL']!}${product.image}',
                  fit: BoxFit.cover,
                  cacheManager: CustomCacheManager(),
                  errorWidget: (context, url, error) => SvgPicture.asset(
                      Paths.drugTemplateIconPath,
                      height: double.infinity),
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child:
                        CircularProgressIndicator(color: UiConstants.pinkColor),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(product.name,
                          style: UiConstants.textStyle8.copyWith(
                            color: UiConstants.darkBlueColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      'от ${Utils.formatPrice(product.price)}',
                      style: UiConstants.textStyle3.copyWith(
                          color: UiConstants.darkBlueColor,
                          fontWeight: FontWeight.w800,
                          height: 1),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.dp),
              BlocBuilder<CartScreenBloc, CartScreenState>(
                builder: (context, state) {
                  final isChecked = (state.cartData?.products ?? [])
                      .any((e) => e.productId == product.productId);

                  return GestureDetector(
                    onTap: () {
                      if (isChecked) {
                        context.read<CartScreenBloc>().add(
                              DeleteCartEvent(
                                context: context,
                                productId: product.productId,
                                count: 0,
                              ),
                            );
                      } else {
                        context.read<CartScreenBloc>().add(
                              AddCartEvent(
                                context: context,
                                productId: product.productId,
                              ),
                            );
                      }
                    },
                    child: SvgPicture.asset(
                      Paths.cartIconPath,
                      height: 24.dp,
                      width: 24.dp,
                      color: isChecked ? UiConstants.purple2Color : null,
                    ),
                  );
                },
              ),
              /*CustomCheckbox(
                isChecked:
                    (context.read<CartScreenBloc>().state.cartData?.products ??
                            [])
                        .map((e) => e.productId)
                        .contains(product.productId),
                scale: 1.8,
                borderRadius: 200.r,
                onChanged: (isChecked) {
                  if (isChecked == null) return;
                  if (isChecked) {
                    context.read<CartScreenBloc>().add(
                          AddCartEvent(
                              context: context, productId: product.productId!),
                        );
                  } else {
                    context.read<CartScreenBloc>().add(
                          DeleteCartEvent(
                              context: context,
                              productId: product.productId!,
                              count: 0),
                        );
                  }
                },
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
