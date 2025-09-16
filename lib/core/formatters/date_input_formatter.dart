import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue previousValue,
    TextEditingValue nextValue,
  ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    // Удаляем все, кроме цифр
    inputText = inputText.replaceAll(RegExp(r'[^0-9]'), '');

    // Ограничиваем длину ввода до 8 символов
    if (inputText.length > 8) {
      inputText = inputText.substring(0, 8);
    }

    var bufferString = StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      if (i == 2 || i == 4) {
        bufferString.write(' / ');
      }
      bufferString.write(inputText[i]);
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
    String cleanPreviousText = previousText.replaceAll(RegExp(r'[^0-9]'), '');
    String cleanFormattedText = formattedText.replaceAll(RegExp(r'[^0-9]'), '');

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
