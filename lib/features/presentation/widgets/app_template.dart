import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/ui_constants.dart';

class AppTemplate extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget child;
  final bool hasBack;

  const AppTemplate({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    required this.child,
    this.hasBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.transparent),
      backgroundColor: UiConstants.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Paths.backgroundGradientIconPath),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16).add(
                  EdgeInsetsGeometry.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasBack)
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(
                          Paths.arrowBackIconPath,
                          width: 24,
                          height: 24,
                        ),
                      ),
                    Spacer(),
                    Text(
                      title,
                      style: UiConstants.textStyle1.copyWith(
                        color: UiConstants.whiteColor,
                      ),
                    ),
                    if (subtitle != null || subtitleWidget != null)
                      Padding(
                        padding: EdgeInsetsGeometry.only(top: 8),
                        child: subtitleWidget ??
                            Text(
                              subtitle ?? '',
                              style: UiConstants.textStyle2.copyWith(
                                color: UiConstants.whiteColor,
                              ),
                            ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: UiConstants.whiteColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
