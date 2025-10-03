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
  const OrderInfoList({
    super.key,
    required this.order,
    this.pharmacy,
    this.address,
  });

  final OrderEntity? order;
  final PharmacyEntity? pharmacy;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        // Номер заказа
        OrderInfoItem(
          imagePath: Paths.documentIconPath,
          title: 'Номер заказа',
          subtitle: '${order?.orderId}',
        ),
        SizedBox(height: 8),

        // Время заказа
        OrderInfoItem(
          imagePath: Paths.clockIconPath,
          title: 'Время заказа',
          subtitle: Utils.formatDateTime(order?.createdAt),
        ),
        SizedBox(height: 8),

        // Способ получения
        OrderInfoItem(
            imagePath: Paths.boxIconPath,
            title: 'Способ получения',
            subtitle: order?.typeReceipt?.title),

        // Адрес доставки или аптеки
        Padding(
          padding: getMarginOrPadding(top: 8),
          child: OrderInfoItem(
            imagePath: Paths.pointIconPath,
            title: order?.typeReceipt == TypeReceiving.delivery
                ? 'Адрес доставки'
                : 'Аптека',
            subtitle: order?.typeReceipt == TypeReceiving.delivery
                ? order?.fullDeliveryAddress
                : pharmacy?.address ??
                    [order?.pharmacyName, order?.address].join(', '),
          ),
        ),

        // Способ оплаты
        if (order?.typeReceipt == TypeReceiving.delivery)
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: OrderInfoItem(
              imagePath: Paths.cardIconPath,
              title: 'Способ оплаты',
              subtitle: order?.paymentType?.title ?? order?.paymentTitle,
            ),
          ),

        // Комментарий к заказу
        if ((order?.comment?.isNotEmpty ?? false))
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: OrderInfoItem(
              imagePath: Paths.documentIconPath,
              title: 'Комментарий',
              subtitle: order?.comment,
            ),
          ),

        // Цены
        SizedBox(height: 8),
        OrderInfoItem(
          imagePath: Paths.cardIconPath,
          title: 'Стоимость товаров',
          subtitle:
              '${order?.summary?.productsPrice ?? order?.sumPrices ?? 0} BYN',
        ),
        if ((order?.summary?.promocodesDiscount ?? 0) != 0)
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: OrderInfoItem(
              imagePath: Paths.cardIconPath,
              title: 'Скидка по промокодам',
              subtitle: '${order?.summary?.promocodesDiscount ?? 0} BYN',
            ),
          ),
        if (order?.typeReceipt == TypeReceiving.delivery &&
            (order?.summary?.deliveryPrice ?? order?.deliverySum ?? 0) != 0)
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: OrderInfoItem(
              imagePath: Paths.cardIconPath,
              title: 'Стоимость доставки',
              subtitle:
                  '${order?.summary?.deliveryPrice ?? order?.deliverySum ?? 0} BYN',
            ),
          ),
        SizedBox(height: 8),
        OrderInfoItem(
          imagePath: Paths.cardIconPath,
          title: 'Итого',
          subtitle: '${order?.summary?.totalPrice ?? order?.totalSum ?? 0} BYN',
        ),
      ],
    );
  }

  /// Форматируем полный адрес
  String _formatFullAddress(OrderEntity? order) {
    if (order == null) return '';
    return [
      order.deliveryCity,
      order.deliveryStreet,
      if (order.deliveryHouse?.isNotEmpty ?? false) 'д. ${order.deliveryHouse}',
      if (order.deliveryEntrance?.isNotEmpty ?? false)
        'подъезд ${order.deliveryEntrance}',
      if (order.deliveryFloor?.isNotEmpty ?? false)
        'этаж ${order.deliveryFloor}',
      if (order.deliveryApartment?.isNotEmpty ?? false)
        'кв. ${order.deliveryApartment}',
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }
}
