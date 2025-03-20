import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/about_us_screen/about_us_block_template.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_info_item.dart';

class SocialNetworkBlock extends StatelessWidget {
  const SocialNetworkBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return AboutUsBlockTemplate(
      title: 'Социальные сети',
      children: [
        OrderInfoItem(
            imagePath: Paths.instaIconPath,
            title: 'Instagram',
            subtitle: '@inlek_apteka',
            onTap: () {},
            imageBackgroundColor: UiConstants.purple3Color,
            imageForegroundColor: UiConstants.purpleColor),
        SizedBox(height: 8.h),
        OrderInfoItem(
            imagePath: Paths.tiktokIconPath,
            title: 'Tik Tok',
            subtitle: '@inlek_apteka',
            onTap: () => print(11),
            imageBackgroundColor: UiConstants.purple3Color,
            imageForegroundColor: UiConstants.purpleColor),
      ],
    );
  }
}
