import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_info_item.dart';

class OrderInfoList extends StatelessWidget {
  const OrderInfoList(
      {super.key, required this.order, this.pharmacy, this.address});

  final OrderEntity? order;
  final PharmacyEntity? pharmacy;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        OrderInfoItem(
            imagePath: Paths.documentIconPath,
            title: 'Номер заказа',
            subtitle: '${order?.orderId}'),
        SizedBox(height: 8.dp),
        OrderInfoItem(
          imagePath: Paths.clockIconPath,
          title: 'Время заказа',
          subtitle: Utils.formatDateTime(order?.createdAt),
        ),
        SizedBox(height: 8.dp),
        OrderInfoItem(
            imagePath: Paths.boxIconPath,
            title: 'Способ получения',
            subtitle: order?.typeReceipt == TypeReceiving.pickup
                ? 'Самовывоз'
                : 'Доставка'),
        if (order?.typeReceipt == TypeReceiving.delivery)
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: OrderInfoItem(
                imagePath: Paths.pointIconPath,
                title: 'Адрес',
                subtitle: address ?? 'пр-кт Независимости, д.1'),
          )
        else
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: OrderInfoItem(
                imagePath: Paths.pointIconPath,
                title: 'Аптека',
                subtitle: pharmacy?.address ??
                    'Аптека №36 InLek ОДО ДКМ-ФАРМ, Минский р-н, аг. Сеница, ул. Зеленая, 1, к. 5 (с/м Гиппо)'),
          ),
        if (order?.typeReceipt == TypeReceiving.delivery)
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: OrderInfoItem(
                imagePath: Paths.cardIconPath,
                title: 'Способ оплаты',
                subtitle: order?.paymentType == PaymentType.courier
                    ? 'Курьеру'
                    : 'Онлайн'),
          ),
      ],
    );
  }
}
