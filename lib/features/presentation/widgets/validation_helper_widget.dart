import 'package:flutter/material.dart';
import 'package:inlek/constants/ui_constants.dart';

/// Универсальный виджет для улучшения UX валидации форм
/// Автоматически скроллит к незаполненным полям и показывает уведомления
class ValidationHelper {
  static void showValidationError(
    BuildContext context, {
    required List<String> emptyFields,
    required VoidCallback onShowFields,
  }) {
    if (emptyFields.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content:
                Text('Заполните обязательные поля: ${emptyFields.join(', ')}'),
            backgroundColor: UiConstants.pink2Color,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Показать',
              textColor: UiConstants.whiteColor,
              onPressed: onShowFields,
            ),
          ),
        );
    }
  }

  static void scrollToField(
    BuildContext context,
    GlobalKey key, {
    ScrollController? scrollController,
    double bottomOffset = 100,
  }) {
    // Проверяем, что ключ все еще привязан к виджету
    if (key.currentContext == null) {
      print('Warning: GlobalKey is not attached to any widget');
      return;
    }

    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final availableHeight = screenHeight - keyboardHeight - bottomOffset;

      if (scrollController != null) {
        scrollController.animateTo(
          scrollController.offset + (position.dy - availableHeight),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    } else {
      print('Warning: RenderBox is null for GlobalKey');
    }
  }

  static void scrollToFirstEmptyField(
    BuildContext context,
    List<GlobalKey> fieldKeys,
    List<bool Function()> validationChecks,
    ScrollController? scrollController,
  ) {
    // Находим первое пустое поле
    int? firstEmptyFieldIndex;
    for (int i = 0; i < fieldKeys.length && i < validationChecks.length; i++) {
      if (validationChecks[i]()) {
        firstEmptyFieldIndex = i;
        break;
      }
    }

    // Если нашли пустое поле, пытаемся скроллить к нему
    if (firstEmptyFieldIndex != null) {
      final targetKey = fieldKeys[firstEmptyFieldIndex];

      // Проверяем, что ключ все еще привязан к виджету
      if (targetKey.currentContext != null) {
        // Пытаемся использовать ensureVisible как более надежный метод
        try {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.1, // Позиционируем в верхней части экрана
          );
          return; // Успешно скроллили, выходим
        } catch (e) {
          // Если ensureVisible не сработал, используем наш метод
          print('ensureVisible failed, using custom scroll: $e');
          scrollToField(context, targetKey, scrollController: scrollController);
          return;
        }
      } else {
        // Если ключ не привязан, ищем первое привязанное поле
        print(
            'Warning: Target field key is not attached, looking for alternative');

        // Ищем первое поле, которое привязано к виджету
        for (int i = 0; i < fieldKeys.length; i++) {
          if (fieldKeys[i].currentContext != null) {
            try {
              Scrollable.ensureVisible(
                fieldKeys[i].currentContext!,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: 0.1,
              );
              print('Scrolled to alternative field at index $i');
              return;
            } catch (e) {
              print('Failed to scroll to alternative field at index $i: $e');
              continue;
            }
          }
        }

        // Если ничего не найдено, просто скроллим к началу
        print('No attached fields found, scrolling to top');
        if (scrollController != null) {
          scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }
}

/// Обертка для полей формы, которая предотвращает пересоздание виджетов
/// Использует RepaintBoundary и KeepAlive для сохранения состояния
class FormFieldWrapper extends StatefulWidget {
  final Widget child;
  final GlobalKey? fieldKey;
  final bool keepAlive;

  const FormFieldWrapper({
    super.key,
    required this.child,
    this.fieldKey,
    this.keepAlive = true,
  });

  @override
  State<FormFieldWrapper> createState() => _FormFieldWrapperState();
}

class _FormFieldWrapperState extends State<FormFieldWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Обязательно для AutomaticKeepAliveClientMixin

    return RepaintBoundary(
      child: Container(
        key: widget.fieldKey,
        child: widget.child,
      ),
    );
  }
}

/// Оптимизированный виджет для полей формы с автоматическим сохранением состояния
class OptimizedFormField extends StatelessWidget {
  final Widget child;
  final GlobalKey? fieldKey;
  final bool keepAlive;

  const OptimizedFormField({
    super.key,
    required this.child,
    this.fieldKey,
    this.keepAlive = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormFieldWrapper(
      fieldKey: fieldKey,
      keepAlive: keepAlive,
      child: child,
    );
  }
}
