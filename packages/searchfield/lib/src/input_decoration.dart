import 'package:flutter/material.dart';

class SearchInputDecoration {
  final InputDecoration decoration;

  final TextCapitalization textCapitalization;
  final TextStyle? searchStyle;

  final Color cursorColor;
  final Color? cursorErrorColor;
  final double? cursorHeight;
  final double cursorWidth;
  final bool? cursorOpacityAnimates;
  final Radius? cursorRadius;
  final Brightness? keyboardAppearance;

  const SearchInputDecoration({
    this.decoration = const InputDecoration(),
    this.textCapitalization = TextCapitalization.none,
    this.searchStyle,
    this.cursorColor = Colors.black,
    this.cursorErrorColor,
    this.cursorHeight,
    this.cursorWidth = 2.0,
    this.cursorOpacityAnimates,
    this.cursorRadius,
    this.keyboardAppearance,
  });

  /// 🔥 SAFE COPY (НЕ используем InputDecoration.copyWith напрямую)
  SearchInputDecoration copyWith({
    InputDecoration? decoration,
    TextCapitalization? textCapitalization,
    TextStyle? searchStyle,
    Color? cursorColor,
    Color? cursorErrorColor,
    double? cursorHeight,
    double? cursorWidth,
    bool? cursorOpacityAnimates,
    Radius? cursorRadius,
    Brightness? keyboardAppearance,
  }) {
    return SearchInputDecoration(
      decoration: decoration ?? this.decoration,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      searchStyle: searchStyle ?? this.searchStyle,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorErrorColor: cursorErrorColor ?? this.cursorErrorColor,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorOpacityAnimates:
          cursorOpacityAnimates ?? this.cursorOpacityAnimates,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
    );
  }
}