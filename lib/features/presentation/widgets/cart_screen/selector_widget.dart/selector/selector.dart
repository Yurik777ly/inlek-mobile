import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/selector_widget.dart/selector/selector_chip.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Selector extends StatefulWidget {
  const Selector({
    super.key,
    required this.titlesList,
    this.unavailableList = const [],
    required this.onTap,
    required this.selectedIndex,
  });

  final List<String> titlesList;
  final List<String> unavailableList;
  final Function(int index) onTap;
  final int selectedIndex;

  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  @override
  Widget build(BuildContext context) {
    return Skeleton.leaf(
      child: Container(
        decoration: BoxDecoration(
          color: UiConstants.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: getMarginOrPadding(left: 4, right: 4),
        child: Row(
          children: List.generate(
            widget.titlesList.length,
            (index) => SelectorChip(
                text: widget.titlesList[index],
                selected: widget.selectedIndex == index,
                isUnavailable:
                    widget.unavailableList.contains(widget.titlesList[index]),
                index: index,
                onTap: widget.onTap),
          ),
        ),
      ),
    );
  }
}
