import 'package:flutter/material.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_banner_item.dart';

class ProductBannerWidget extends StatelessWidget {
  const ProductBannerWidget(
      {super.key, required this.pageController, required this.product});

  final PageController pageController;
  final ProductEntity? product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          height: 260,
          child: PageView.builder(
            controller: pageController,
            itemCount: 1,
            itemBuilder: (context, index) =>
                ProductBannerItem(product: product),
          ),
        ),

        /*  Skeleton.ignore(
          child: Align(
            alignment: AlignmentDirectional.center,
            child: Padding(
              padding: getMarginOrPadding(top: 8),
              child: SmoothPageIndicator(
                controller: pageController,
                count: 1,
                axisDirection: Axis.horizontal,
                effect: WormEffect(
                    spacing: 4,
                    dotWidth: 6,
                    dotHeight: 6,
                    dotColor: UiConstants.white4Color,
                    activeDotColor: UiConstants.darkBlueColor.withOpacity(.6)),
                onDotClicked: (index) => pageController.animateToPage(index,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.linear),
              ),
            ),
          ),
        )*/
      ],
    );
  }
}
