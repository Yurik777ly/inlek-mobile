import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/launch_url_utils.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/about_us_screen/about_us_block_template.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_info_item.dart';

class BookCommentsBlock extends StatelessWidget {
  const BookCommentsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return AboutUsBlockTemplate(
      title: 'Книга замечаний и предложений',
      textStyle: UiConstants.textStyle2,
      children: [
        OrderInfoItem(
          imagePath: Paths.phoneIconPath,
          title: 'Телефон',
          subtitle: '+375 (17) 393-36-19',
          showArrow: false,
          onTap: () => LaunchUrlUtils.makePhoneCall('+375 (17) 393-36-19'),
        ),
        SizedBox(height: 8.dp),
        OrderInfoItem(
            imagePath: Paths.pointIconPath,
            title: 'Адрес',
            subtitle:
                'Аптека 34 ОДО "ДКМ-ФАРМ"г. Минск, тр-т. Долгиновский, д. 178, пом.178-102 - 178-107, 178-109, 178-112 - 178-114'),
        SizedBox(height: 8.dp),
        OrderInfoItem(
          imagePath: Paths.mailIconPath,
          title: 'Дополнительная информация',
          subtitleWidget: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      'Лицо, уполномоченное рассматривать обращения покупателейо нарушении их прав, предусмотренных законодательствомо защите прав потребителей:\n\nСоленик Н.М. ',
                  style: UiConstants.textStyle8
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                TextSpan(
                  text: '+375 (29) 635-27-65',
                  style: UiConstants.textStyle8
                      .copyWith(color: UiConstants.darkBlueColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        LaunchUrlUtils.makePhoneCall('+375 (29) 635-27-65'),
                ),
                TextSpan(
                  text: ', ',
                  style: UiConstants.textStyle8
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                TextSpan(
                  text: 'pharm-i@inlek.by',
                  style: UiConstants.textStyle8
                      .copyWith(color: UiConstants.darkBlueColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        LaunchUrlUtils.sendEmail(toEmail: 'pharm-i@inlek.by'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
