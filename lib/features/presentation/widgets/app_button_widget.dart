import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppButtonWidget extends StatefulWidget {
  final bool isActive;
  final bool isLoading;
  final String? text;
  final Widget? textWidget;
  final VoidCallback? onTap;
  final bool isExpanded;
  final double? borderRadius;
  final bool isFilled;
  final bool showBorder;
  final Color? textColor;
  final Color? backgroundColor;
  final AlignmentGeometry alignment;
  final Duration debounceDuration;

  const AppButtonWidget({
    super.key,
    this.isActive = true,
    this.isLoading = false,
    this.text,
    this.textWidget,
    this.onTap,
    this.isExpanded = true,
    this.borderRadius,
    this.isFilled = true,
    this.showBorder = false,
    this.textColor,
    this.backgroundColor,
    this.alignment = Alignment.center,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AppButtonWidget> createState() => _AppButtonWidgetState();
}

class _AppButtonWidgetState extends State<AppButtonWidget> {
  Timer? _debounceTimer;
  bool _isProcessing = false;

  void _handleTap() {
    if (_isProcessing || !widget.isActive) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });

    setState(() {
      _isProcessing = true;
    });

    widget.onTap?.call();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Skeleton.ignorePointer(
      child: SizedBox(
        width: widget.isExpanded ? double.infinity : null,
        child: ElevatedButton(
          onPressed: (widget.isActive && !_isProcessing) ? _handleTap : null,
          style: ElevatedButton.styleFrom(
              elevation: 0,
              disabledForegroundColor:
                  UiConstants.darkBlue2Color.withOpacity(.6),
              foregroundColor: widget.textColor ??
                  (widget.isFilled
                      ? UiConstants.whiteColor
                      : UiConstants.darkBlueColor),
              disabledBackgroundColor:
                  UiConstants.oliveGreenColor.withOpacity(.05),
              backgroundColor: widget.isFilled
                  ? widget.backgroundColor ?? UiConstants.purpleColor
                  : UiConstants.whiteColor,
              fixedSize: Size(double.infinity, double.infinity),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 30.r),
                  side: widget.showBorder
                      ? BorderSide(color: UiConstants.purpleColor)
                      : BorderSide.none),
              alignment: widget.alignment),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 13.5),
            child: (widget.isLoading || _isProcessing)
                ? Center(
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                          color: UiConstants.pink2Color),
                    ),
                  )
                : widget.textWidget ??
                    Text(
                      widget.text ?? '',
                      style: UiConstants.textStyle3.copyWith(height: 1),
                    ),
          ),
        ),
      ),
    );
  }
}
