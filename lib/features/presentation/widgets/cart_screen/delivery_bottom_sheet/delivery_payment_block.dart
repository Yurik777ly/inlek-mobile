import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/delivery_bottom_sheet/delivery_payment_block_item.dart';

class DeliveryPaymentBlock extends StatefulWidget {
  const DeliveryPaymentBlock({
    super.key,
    required this.screenContext,
    required this.changedOnlineMethodTap,
  });

  final BuildContext screenContext;
  final Function() changedOnlineMethodTap;

  @override
  State<DeliveryPaymentBlock> createState() => _DeliveryPaymentBlockState();
}

class _DeliveryPaymentBlockState extends State<DeliveryPaymentBlock> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartScreenBloc, CartScreenState>(
      bloc: widget.screenContext.read<CartScreenBloc>(),
      builder: (context, state) {
        final cartBloc = widget.screenContext.read<CartScreenBloc>();
        final paymentType = cartBloc.state.paymentType;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3. Способ оплаты',
              style: UiConstants.textStyle5
                  .copyWith(color: UiConstants.darkBlueColor),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: DeliveryPaymentBlockItem(
                    imagePath: Paths.courierIconPath,
                    title: 'Курьеру',
                    subtitle: 'Картой или наличными',
                    isChecked: paymentType == PaymentType.courier,
                    onTap: () {
                      cartBloc.add(
                        ChangePaymentTypeEvent(PaymentType.courier),
                      );
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: DeliveryPaymentBlockItem(
                      imagePath: Paths.cardIconPath,
                      title: 'Онлайн',
                      titleWidget: paymentType == PaymentType.bepaid
                          ? Image.asset(Paths.eripIconPath, height: 50)
                          : paymentType == PaymentType.oplati
                              ? SvgPicture.asset(Paths.oplatiIconPath)
                              : null,
                      isChecked: [PaymentType.bepaid, PaymentType.oplati]
                          .contains(paymentType),
                      onTap: () {
                        setState(() {});
                        widget.changedOnlineMethodTap();
                      },
                      changedOnlineMethodTap: widget.changedOnlineMethodTap),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
