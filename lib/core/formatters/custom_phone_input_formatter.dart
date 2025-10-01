import 'package:flutter/services.dart';

class CustomPhoneInputFormatter extends TextInputFormatter {
  // Группы цифр: + 3 2 3 2 2 => всего 12 цифр
  static const int _maxDigits = 12;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue previousValue,
    TextEditingValue nextValue,
  ) {
    // Если курсор в самом начале, отдаём как есть (поведение как у форматтера даты)
    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    // Оставляем только цифры и ограничиваем длину
    String digitsOnly = nextValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > _maxDigits) {
      digitsOnly = digitsOnly.substring(0, _maxDigits);
    }

    // Формируем строку по маске: '+### (##) ###-##-##'
    final String formatted = _formatPhone(digitsOnly);

    // Стабильная позиция курсора при удалении/вставке
    final int cursorOffset = _calculateCursorPosition(
      previousValue.text,
      nextValue.text,
      formatted,
      nextValue.selection.baseOffset,
    );

    return nextValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
      composing: TextRange.empty,
    );
  }

  String _formatPhone(String digits) {
    if (digits.isEmpty) {
      return '+'; // начинаем всегда с '+'
    }

    final StringBuffer buffer = StringBuffer('+');

    int index = 0;

    // Страна: 3 цифры
    final int countryCount = digits.length >= 3 ? 3 : digits.length;
    if (countryCount > 0) {
      buffer.write(digits.substring(index, index + countryCount));
      index += countryCount;
    }

    // Код: 2 цифры, показываем открывающую скобку, как только начался код
    if (index < digits.length) {
      buffer.write(' (');
      final int codeCount =
          (digits.length - index) >= 2 ? 2 : (digits.length - index);
      if (codeCount > 0) {
        buffer.write(digits.substring(index, index + codeCount));
        index += codeCount;
      }
      if (codeCount == 2) {
        buffer.write(') ');
      }
    }

    // Номер: 3 цифры
    if (index < digits.length) {
      final int part1Count =
          (digits.length - index) >= 3 ? 3 : (digits.length - index);
      buffer.write(digits.substring(index, index + part1Count));
      index += part1Count;
      if (part1Count == 3 && index < digits.length) {
        buffer.write('-');
      }
    }

    // Номер: 2 цифры
    if (index < digits.length) {
      final int part2Count =
          (digits.length - index) >= 2 ? 2 : (digits.length - index);
      buffer.write(digits.substring(index, index + part2Count));
      index += part2Count;
      if (part2Count == 2 && index < digits.length) {
        buffer.write('-');
      }
    }

    // Номер: последние 2 цифры
    if (index < digits.length) {
      final int part3Count =
          (digits.length - index) >= 2 ? 2 : (digits.length - index);
      buffer.write(digits.substring(index, index + part3Count));
      index += part3Count;
    }

    return buffer.toString();
  }

  int _calculateCursorPosition(
    String previousText,
    String nextText,
    String formattedText,
    int originalCursorPosition,
  ) {
    // Сравниваем по количеству цифр, игнорируя форматирующие символы
    final String cleanPrevious = previousText.replaceAll(RegExp(r'[^0-9]'), '');
    final String cleanFormatted =
        formattedText.replaceAll(RegExp(r'[^0-9]'), '');

    // Подсчитываем, сколько цифр было слева от курсора в исходном nextText
    int digitsBeforeCursor = 0;
    for (int i = 0; i < originalCursorPosition && i < nextText.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(nextText[i])) {
        digitsBeforeCursor++;
      }
    }

    // Если количество цифр уменьшилось (удаление)
    if (cleanFormatted.length < cleanPrevious.length) {
      return _mapDigitsToFormattedPosition(formattedText, digitsBeforeCursor);
    }

    // Если количество цифр увеличилось (вставка)
    if (cleanFormatted.length > cleanPrevious.length) {
      return _mapDigitsToFormattedPosition(formattedText, digitsBeforeCursor);
    }

    // Если количество цифр не изменилось — сохраняем относительную позицию
    return _mapDigitsToFormattedPosition(formattedText, digitsBeforeCursor);
  }

  int _mapDigitsToFormattedPosition(
      String formattedText, int digitsBeforeCursor) {
    if (digitsBeforeCursor <= 0) {
      // Курсор после '+'
      final int plusIndex = formattedText.indexOf('+');
      return plusIndex >= 0 ? plusIndex + 1 : 0;
    }

    int digitsCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(formattedText[i])) {
        digitsCount++;
        if (digitsCount == digitsBeforeCursor) {
          return i + 1;
        }
      }
    }
    return formattedText.length;
  }
}
