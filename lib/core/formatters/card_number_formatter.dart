import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue previousValue,
    TextEditingValue nextValue,
  ) {
    var inputText = nextValue.text;

    // Ограничение длины ввода до 16 символов без пробелов
    if (inputText.replaceAll(' ', '').length > 16) {
      return previousValue;
    }

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write(' ');
      }
    }

    var string = bufferString.toString();

    // Вычисляем правильную позицию курсора
    int cursorPosition = _calculateCursorPosition(
      previousValue.text,
      nextValue.text,
      string,
      nextValue.selection.baseOffset,
    );

    return nextValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: cursorPosition,
      ),
    );
  }

  int _calculateCursorPosition(
    String previousText,
    String nextText,
    String formattedText,
    int originalCursorPosition,
  ) {
    // Удаляем все символы форматирования из текстов для сравнения
    String cleanPreviousText = previousText.replaceAll(' ', '');
    String cleanFormattedText = formattedText.replaceAll(' ', '');

    // Если текст стал короче (удаление)
    if (cleanFormattedText.length < cleanPreviousText.length) {
      // Находим количество цифр до позиции курсора в оригинальном тексте
      int digitsBeforeCursor = 0;
      for (int i = 0; i < originalCursorPosition && i < nextText.length; i++) {
        if (nextText[i].contains(RegExp(r'[0-9]'))) {
          digitsBeforeCursor++;
        }
      }

      // Находим соответствующую позицию в отформатированном тексте
      int digitsCount = 0;
      for (int i = 0; i < formattedText.length; i++) {
        if (formattedText[i].contains(RegExp(r'[0-9]'))) {
          digitsCount++;
          if (digitsCount == digitsBeforeCursor) {
            return i + 1;
          }
        }
      }

      // Если не нашли точную позицию, возвращаем конец
      return formattedText.length;
    }

    // Если текст стал длиннее (добавление)
    if (cleanFormattedText.length > cleanPreviousText.length) {
      // Находим количество цифр до позиции курсора в оригинальном тексте
      int digitsBeforeCursor = 0;
      for (int i = 0; i < originalCursorPosition && i < nextText.length; i++) {
        if (nextText[i].contains(RegExp(r'[0-9]'))) {
          digitsBeforeCursor++;
        }
      }

      // Находим соответствующую позицию в отформатированном тексте
      int digitsCount = 0;
      for (int i = 0; i < formattedText.length; i++) {
        if (formattedText[i].contains(RegExp(r'[0-9]'))) {
          digitsCount++;
          if (digitsCount == digitsBeforeCursor) {
            return i + 1;
          }
        }
      }
    }

    // Если длина не изменилась, пытаемся сохранить относительную позицию
    if (cleanFormattedText.length == cleanPreviousText.length) {
      // Находим количество цифр до позиции курсора в оригинальном тексте
      int digitsBeforeCursor = 0;
      for (int i = 0; i < originalCursorPosition && i < nextText.length; i++) {
        if (nextText[i].contains(RegExp(r'[0-9]'))) {
          digitsBeforeCursor++;
        }
      }

      // Находим соответствующую позицию в отформатированном тексте
      int digitsCount = 0;
      for (int i = 0; i < formattedText.length; i++) {
        if (formattedText[i].contains(RegExp(r'[0-9]'))) {
          digitsCount++;
          if (digitsCount == digitsBeforeCursor) {
            return i + 1;
          }
        }
      }
    }

    // По умолчанию курсор в конце
    return formattedText.length;
  }
}
