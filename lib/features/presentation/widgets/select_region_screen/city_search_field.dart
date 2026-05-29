import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:searchfield/searchfield.dart';

typedef SuggestionFetcher = Future<List<String>> Function(String query);

class CitySearchField extends StatelessWidget {
  const CitySearchField({
    super.key,
    this.value,
    required this.controller,
    this.suggestions,
    this.suggestionFetcher,
    this.suggestionObjects,
    this.hintText,
    this.title,
    this.onSuggestionTap,
    this.onChangeField,
    this.hasSearchWidget = true,
    this.validator,
    this.fillColor = UiConstants.white2Color,
    this.prefixIcon,
    this.minFetcherLength = 3,
    this.focusNode,
  }) : assert(
          suggestions != null ||
              (suggestionFetcher != null && suggestionObjects != null),
          'Either suggestions or suggestionFetcher and suggestionObjects must be provided',
        );

  final String? value;
  final TextEditingController controller;
  final List<String>? suggestions;
  final SuggestionFetcher? suggestionFetcher;
  final List<dynamic>? suggestionObjects;
  final String? hintText;
  final String? title;
  final Function(dynamic)? onSuggestionTap;
  final Function(String)? onChangeField;
  final bool hasSearchWidget;
  final String? Function(String?)? validator;
  final String? prefixIcon;
  final int minFetcherLength;
  final Color fillColor;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final FocusNode localFocusNode = focusNode ?? FocusNode();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: getMarginOrPadding(bottom: 4),
            child: Text(
              title!,
              style: UiConstants.textStyle3
                  .copyWith(color: UiConstants.darkBlueColor),
            ),
          ),

        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return SearchField<String>(
              validator: validator,
              focusNode: localFocusNode,
              controller: controller,

              suggestionItemDecoration: BoxDecoration(
                border: Border.all(style: BorderStyle.none),
              ),

              maxSuggestionBoxHeight: 124,
              hint: hintText ?? 'Не указано',

              suggestions: (suggestions ?? const [])
                  .map(
                    (item) => SearchFieldListItem<String>(
                      item,
                      item: item,
                      child: Text(
                        item,
                        style: UiConstants.textStyle3.copyWith(
                          color: UiConstants.darkBlueColor,
                        ),
                      ),
                    ),
                  )
                  .toList(),

              // ✅ FIXED SearchInputDecoration (только поддерживаемые поля)
              searchInputDecoration: SearchInputDecoration(
                searchStyle: UiConstants.textStyle3.copyWith(
                  color: UiConstants.darkBlueColor,
                ),

                decoration: InputDecoration(
                  filled: true,
                  fillColor: fillColor,
                  counterText: '',

                  contentPadding: getMarginOrPadding(
                    left: 16,
                    right: 16,
                    top: 10,
                    bottom: 10,
                  ),

                  hintStyle: UiConstants.textStyle3.copyWith(
                    color: UiConstants.darkBlue2Color.withOpacity(.6),
                    height: 1,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),

                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      width: 3,
                      color: UiConstants.purple2Color.withOpacity(.2),
                    ),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      width: 3,
                      color: UiConstants.pinkColor,
                    ),
                  ),

                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      width: 3,
                      color: UiConstants.pinkColor,
                    ),
                  ),

                  prefixIcon: prefixIcon != null
                      ? Padding(
                          padding: getMarginOrPadding(right: 12, left: 16),
                          child: SvgPicture.asset(
                            prefixIcon!,
                            colorFilter: ColorFilter.mode(
                              UiConstants.darkBlue2Color.withOpacity(.6),
                              BlendMode.srcIn,
                            ),
                            height: 24,
                            width: 24,
                          ),
                        )
                      : null,

                  suffixIcon: value.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.clear();
                            onChangeField?.call('');
                          },
                          child: Padding(
                            padding: getMarginOrPadding(right: 16, left: 12),
                            child: SvgPicture.asset(
                              Paths.close2IconPath,
                              colorFilter: ColorFilter.mode(
                                UiConstants.darkBlue2Color.withOpacity(.6),
                                BlendMode.srcIn,
                              ),
                              height: 24,
                              width: 24,
                            ),
                          ),
                        )
                      : null,
                ),
              ),

              suggestionsDecoration: SuggestionDecoration(
                color: UiConstants.whiteColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),

              onSearchTextChanged: (String query) async {
                if (suggestionFetcher != null) {
                  if (query.trim().length < minFetcherLength) {
                    return <SearchFieldListItem<String>>[];
                  }

                  final fetched =
                      await suggestionFetcher!.call(query.trim());

                  return fetched
                      .map(
                        (region) => SearchFieldListItem<String>(
                          region,
                          item: region,
                          child: Text(
                            region,
                            style: UiConstants.textStyle3.copyWith(
                              color: UiConstants.darkBlueColor,
                            ),
                          ),
                        ),
                      )
                      .toList();
                }

                final base = suggestions ?? const <String>[];

                final filtered = query.isEmpty
                    ? base
                    : base
                        .where((s) => s
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();

                return filtered
                    .map(
                      (region) => SearchFieldListItem<String>(
                        region,
                        item: region,
                        child: Text(
                          region,
                          style: UiConstants.textStyle3.copyWith(
                            color: UiConstants.redColor,
                          ),
                        ),
                      ),
                    )
                    .toList();
              },

              onSuggestionTap: (SearchFieldListItem<String> item) {
                onSuggestionTap?.call(item.item);
              },

              onTapOutside: (p0) {
                FocusScope.of(context).unfocus();
                localFocusNode.unfocus();
              },

              suggestionState: Suggestion.expand,
            );
          },
        ),
      ],
    );
  }
}