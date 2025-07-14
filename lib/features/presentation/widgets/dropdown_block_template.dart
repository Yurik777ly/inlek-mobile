import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/dropdown_block_item.dart';

class DropdownBlockTemplate extends StatefulWidget {
  const DropdownBlockTemplate({
    super.key,
    required this.title,
    required this.child,
    this.groupByFirstLetter = false,
    this.selectedItems,
    this.onChanged,
  });

  final String title;
  final dynamic child; // Widget или List<String>
  final bool groupByFirstLetter;
  final Set<String>? selectedItems;
  final void Function(String item, bool? isChecked)? onChanged;

  @override
  State<DropdownBlockTemplate> createState() => _DropdownBlockTemplateState();
}

class _DropdownBlockTemplateState extends State<DropdownBlockTemplate>
    with AutomaticKeepAliveClientMixin {
  bool isVisible = true;

  @override
  bool get wantKeepAlive => true;

  void _toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget content;
    if (widget.groupByFirstLetter && widget.child is List<String>) {
      final items = widget.child as List<String>;
      final selected = widget.selectedItems ?? {};
      final Map<String, List<String>> grouped = {};
      for (final m in items) {
        if (m.isEmpty) continue;
        final letter = m[0].toUpperCase();
        grouped.putIfAbsent(letter, () => []).add(m);
      }
      final sortedKeys = grouped.keys.toList()..sort();
      content = ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, groupIndex) {
          final letter = sortedKeys[groupIndex];
          final groupItems = grouped[letter]!;
          groupItems.sort();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: getMarginOrPadding(bottom: 8),
                child: Text(
                  letter,
                  style: UiConstants.textStyle3.copyWith(
                    color: UiConstants.darkBlueColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ...groupItems.map((item) => Padding(
                    padding: getMarginOrPadding(bottom: 8),
                    child: DropdownBlockItem(
                      text: item,
                      isChecked: selected.contains(item),
                      onChanged: (isChecked) =>
                          widget.onChanged?.call(item, isChecked),
                    ),
                  )),
            ],
          );
        },
        itemCount: sortedKeys.length,
      );
    } else {
      content = widget.child;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleVisibility,
          child: Row(
            children: [
              Text(
                widget.title,
                style: UiConstants.textStyle3.copyWith(
                  color: UiConstants.darkBlueColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4.w),
              AnimatedRotation(
                turns: isVisible ? 0.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: SvgPicture.asset(
                  Paths.dropdownArrowIconPath,
                  width: 24.w,
                  height: 24.w,
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isVisible
              ? RepaintBoundary(
                  child: Padding(
                    padding: getMarginOrPadding(top: 8),
                    child: content,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
