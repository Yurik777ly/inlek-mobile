import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class InstructionWidget extends StatelessWidget {
  const InstructionWidget({super.key, required this.instruction});

  final String instruction;

  @override
  Widget build(BuildContext context) {
    return Skeleton.replace(
      child: GestureDetector(
        onTap: () async {
          final String instructionUrl =
              '${dotenv.env['PUBLIC_URL']!}$instruction';
          if (await canLaunchUrl(Uri.parse(instructionUrl))) {
            await launchUrl(Uri.parse(instructionUrl),
                mode: LaunchMode.externalApplication);
          } else {
            throw "Не удалось открыть $instructionUrl";
          }
        },
        child: Card(
          shadowColor: Colors.transparent,
          color: Colors.transparent,
          margin: EdgeInsets.zero,
          child: Container(
            padding: getMarginOrPadding(all: 8),
            decoration: BoxDecoration(
              color: UiConstants.pink3Color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: getMarginOrPadding(all: 4),
                  decoration: BoxDecoration(
                      color: UiConstants.whiteColor.withOpacity(.4),
                      shape: BoxShape.circle),
                  child: SvgPicture.asset(Paths.document2IconPath,
                      color: UiConstants.pink2Color),
                ),
                SizedBox(width: 8),
                Text(
                  'Инструкция',
                  style: UiConstants.textStyle3.copyWith(
                      color: UiConstants.darkBlueColor,
                      fontWeight: FontWeight.w800),
                ),
                Spacer(),
                Text(
                  'Читать',
                  style: UiConstants.textStyle3.copyWith(
                      color: UiConstants.darkBlue2Color,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dashed,
                      decorationThickness: 2,
                      decorationColor: UiConstants.darkBlue2Color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
