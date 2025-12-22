import 'package:flutter/material.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';

class ClearingCartOverlay extends StatelessWidget {
  const ClearingCartOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: getMarginOrPadding(all: 20),
          padding: getMarginOrPadding(all: 24),
          decoration: BoxDecoration(
            color: UiConstants.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка загрузки
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: UiConstants.pink2Color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      UiConstants.pink2Color,
                    ),
                    strokeWidth: 3,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Заголовок
              Text(
                'Очищаем корзину',
                style: UiConstants.textStyle1.copyWith(
                  color: UiConstants.darkBlueColor,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8),

              // Описание
              Text(
                'Удаляем все товары...',
                style: UiConstants.textStyle3.copyWith(
                  color: UiConstants.darkBlueColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
