import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/formatters/custom_phone_input_formatter.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';

class DeliveryCustomerBlock extends StatelessWidget {
  const DeliveryCustomerBlock({super.key, required this.screenContext});

  final BuildContext screenContext;

  @override
  Widget build(BuildContext context) {
    final cartBloc = screenContext.read<CartScreenBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Получатель',
          style:
              UiConstants.textStyle5.copyWith(color: UiConstants.darkBlueColor),
        ),
        SizedBox(height: 8.dp),
        Container(
          padding: getMarginOrPadding(all: 16),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              AppTextFieldWidget(
                  title: 'Имя',
                  hintText: 'Введите имя',
                  controller: cartBloc.fNameController,
                  validator: Utils.nameValidate),
              SizedBox(height: 24.dp),
              AppTextFieldWidget(
                  title: 'Фамилия',
                  hintText: 'Введите фамилию',
                  controller: cartBloc.sNameController,
                  validator: Utils.nameValidate),
              SizedBox(height: 24.dp),
              AppTextFieldWidget(
                  title: 'Телефон',
                  hintText: '+375 (00) 000-00-00',
                  controller: cartBloc.phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CustomPhoneInputFormatter()
                  ],
                  validator: Utils.validatePhone),
              SizedBox(height: 24.dp),
              AppTextFieldWidget(
                  title: 'Email',
                  description: 'Обязательно при оплате онлайн в приложении',
                  hintText: 'Введите Email',
                  controller: cartBloc.emailController,
                  validator: cartBloc.state.paymentType == PaymentType.courier
                      ? null
                      : Utils.emailValidate),
              if (cartBloc.state.cartType == TypeReceiving.pickup)
                Padding(
                  padding: getMarginOrPadding(top: 24),
                  child: AppTextFieldWidget(
                      title: 'Комментарий к заказу',
                      hintText: 'Укажите, что необходимо учесть при доставке',
                      controller: cartBloc.commentController,
                      minLines: 4),
                )
            ],
          ),
        ),
      ],
    );
  }
}
