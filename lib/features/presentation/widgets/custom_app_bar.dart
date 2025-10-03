import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';
import 'package:inlek/features/presentation/widgets/filter_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    this.controller,
    this.showLocationChip = false,
    this.showBack = false,
    this.title,
    this.action,
    this.contentPadding,
    this.backgroundColor,
    this.hintText,
    this.isShowFilterButton = false,
    this.onTapFilterButton,
    this.onChangedField,
    this.onTapField,
    this.onTapBack,
    this.onTapAction,
    this.screenContext,
  });

  final BuildContext? screenContext;
  final TextEditingController? controller;
  final bool showLocationChip;
  final bool showBack;
  final String? title;
  final Widget? action;
  final EdgeInsets? contentPadding;
  final Color? backgroundColor;
  final String? hintText;
  final bool isShowFilterButton;
  final Function()? onTapFilterButton;
  final Function(String value)? onChangedField;
  final Function()? onTapField;
  final Function()? onTapBack;
  final Function()? onTapAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? UiConstants.whiteColor,
      padding: contentPadding ??
          getMarginOrPadding(top: 8, bottom: 8, right: 20, left: 20),
      child: Column(
        children: [
          if (title != null || action != null || controller == null)
            Padding(
              padding: getMarginOrPadding(bottom: controller != null ? 16 : 0),
              child: Row(
                children: [
                  if (showBack)
                    Padding(
                      padding: getMarginOrPadding(right: 4),
                      child: GestureDetector(
                        onTap: onTapBack ?? () => Navigator.pop(context),
                        child: SvgPicture.asset(Paths.arrowBackIconPath,
                            color: UiConstants.darkBlue2Color.withOpacity(.6),
                            width: 24,
                            height: 24),
                      ),
                    ),
                  Expanded(
                    child: Skeleton.keep(
                      child: Text(
                        title ?? '',
                        style: showBack
                            ? UiConstants.textStyle5
                            : UiConstants.textStyle1
                                .copyWith(color: UiConstants.darkBlueColor),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: onTapAction,
                      child: Skeleton.ignore(child: action ?? Container()))
                ],
              ),
            ),
          if (controller != null)
            Row(
              children: [
                if (showLocationChip)
                  Skeleton.replace(
                    child: Padding(
                      padding: getMarginOrPadding(right: 8),
                      child: SvgPicture.asset(Paths.locationIconPath,
                          width: 24, height: 24),
                    ),
                  ),
                if (showBack && title == null && action == null)
                  Padding(
                    padding: getMarginOrPadding(right: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(Paths.arrowBackIconPath,
                          color: UiConstants.darkBlue2Color.withOpacity(.6),
                          width: 24,
                          height: 24),
                    ),
                  ),
                Expanded(
                  child: Skeleton.ignorePointer(
                    child: Skeleton.shade(
                      child: AppTextFieldWidget(
                          hintText: hintText ?? 'Искать препараты',
                          fillColor: UiConstants.white2Color,
                          controller: controller ?? TextEditingController(),
                          prefixWidget: Skeleton.ignore(
                            child: SvgPicture.asset(Paths.searchIconPath),
                          ),
                          suffixWidget: controller!.text.isNotEmpty
                              ? Skeleton.ignore(
                                  child: GestureDetector(
                                    onTap: () {
                                      controller?.clear();
                                      onChangedField?.call("");
                                    },
                                    child:
                                        SvgPicture.asset(Paths.closeIconPath),
                                  ),
                                )
                              : null,
                          onChangedField: onChangedField,
                          onTap: onTapField),
                    ),
                  ),
                ),
                if (isShowFilterButton)
                  Padding(
                    padding: getMarginOrPadding(left: 8),
                    child: Skeleton.ignorePointer(
                      child: FilterButton(onTap: onTapFilterButton),
                    ),
                  )
              ],
            ),
        ],
      ),
    );
  }
}
