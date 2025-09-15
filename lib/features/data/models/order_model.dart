import 'package:inlek/constants/extensions.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    super.orderId,
    super.address,
    super.fullDeliveryAddress,
    super.pharmacyId,
    super.pharmacyName,
    super.customerId,
    super.createdAt,
    super.updatedAt,
    super.phone,
    super.name,
    super.email,
    super.amount,
    super.currency,
    super.statusId,
    super.status,
    super.comment,
    super.agree,
    super.deliveryId,
    super.deliveryTitle,
    super.deliveryPrice,
    super.deliveryCity,
    super.deliveryStreet,
    super.deliveryHouse,
    super.deliveryEntrance,
    super.deliveryFloor,
    super.deliveryApartment,
    super.deliveryIntercom,
    super.deliveryComment,
    super.paymentId,
    super.paymentTitle,
    super.paymentCaption,
    super.sumPrices,
    super.sumPricesOld,
    super.sumPricesSalesOld,
    super.deliverySum,
    super.totalSum,
    super.isPaid,
    super.products,
    super.paymentType,
    super.typeReceipt,
    super.pharmacy,
    super.link,
    super.summary,
    super.additional,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final data = json['order'] ?? json;

    String? fullDeliveryAddress;

    final deliveryParts = [
      data['delivery_city'],
      data['delivery_street'],
      data['delivery_house'],
      (data['delivery_entrance'] ?? '').isNotEmpty
          ? 'подъезд ${data['delivery_entrance']}'
          : null,
      (data['delivery_floor'] ?? '').isNotEmpty
          ? 'этаж ${data['delivery_floor']}'
          : null,
      (data['delivery_apartment'] ?? '').isNotEmpty
          ? 'кв. ${data['delivery_apartment']}'
          : null,
      (data['delivery_intercom'] ?? '').isNotEmpty
          ? 'домофон ${data['delivery_intercom']}'
          : null,
    ];

// Склеиваем непустые части через запятую
    fullDeliveryAddress = deliveryParts
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');

    return OrderModel(
      orderId: data['order_id'] ?? data['id'],
      address: data['address'],
      fullDeliveryAddress: data['full_delivery_address'] ??
          data['delivery_info']?['address'] ??
          fullDeliveryAddress,
      pharmacyId: data['pharmacy_id'],
      pharmacyName: data['pharmacy_name'],
      customerId: data['customer_id'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at']).toLocal()
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      phone: data['phone'],
      name: data['name'],
      email: data['email'],
      amount: data['amount'] != null
          ? double.tryParse(data['amount'].toString())
          : null,
      currency: data['currency'],
      statusId: data['status_id'],
      status: data['status_id'] != null
          ? OrderStatusExtension.fromId(data['status_id'])
          : null,
      comment: data['comment'],
      agree: data['agree'] == "true",
      deliveryId: data['delivery_id'],
      deliveryTitle: data['delivery_title'],
      deliveryPrice: data['delivery_price'] != null
          ? double.tryParse(data['delivery_price'].toString())
          : null,
      deliveryCity: data['delivery_city'],
      deliveryStreet: data['delivery_street'],
      deliveryHouse: data['delivery_house'],
      deliveryEntrance: data['delivery_entrance'],
      deliveryFloor: data['delivery_floor'],
      deliveryApartment: data['delivery_apartment'],
      deliveryIntercom: data['delivery_intercom'],
      deliveryComment: data['delivery_comment'],
      paymentId: data['payment_id'],
      paymentTitle: data['payment_title'],
      paymentCaption: data['payment_caption'],
      sumPrices: data['sum_prices'] != null
          ? double.tryParse(
              (data['sum_prices'] ?? data['products_price']).toString())
          : null,
      sumPricesOld: data['sum_prices_old'] != null
          ? double.tryParse(data['sum_prices_old'].toString())
          : null,
      sumPricesSalesOld: data['sum_prices_sales_old'] != null
          ? double.tryParse(data['sum_prices_sales_old'].toString())
          : null,
      deliverySum: data['delivery_sum'] != null
          ? double.tryParse(data['delivery_sum'].toString())
          : null,
      totalSum: data['total_sum'] != null
          ? double.tryParse(data['total_sum'].toString())
          : null,
      isPaid: data['is_paid'] == true,
      products: data['order_products_json'] != null
          ? (data['order_products_json'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : null,
      paymentType: PaymentTypeExtension.fromTitle(
          data['payment_method'] ?? data['payment_type']),
      typeReceipt: TypeReceivingExtension.fromTitle(
          data['delivery_method_title'] ?? data['delivery_method']),
      pharmacy: data['pharmacy'] != null
          ? PharmacyModel.fromJson(data['pharmacy'][0])
          : null,
      link: data['payment_link'] ?? json['additional']?['payment_link'],
      summary: json['summary'] != null
          ? OrderSummaryEntity(
              productsPrice:
                  (json['summary']['products_price'] as num?)?.toDouble(),
              productsPriceOld:
                  (json['summary']['products_price_old'] as num?)?.toDouble(),
              discountPercent:
                  (json['summary']['discount_percent'] as num?)?.toDouble(),
              discountAmount:
                  (json['summary']['discount_amount'] as num?)?.toDouble(),
              promocodesDiscount:
                  (json['summary']['promocodes_discount'] as num?)?.toDouble(),
              deliveryPrice:
                  (json['summary']['delivery_price'] as num?)?.toDouble(),
              totalPrice: (json['summary']['total_price'] as num?)?.toDouble(),
            )
          : null,
      additional: json['additional'] != null
          ? OrderAdditionalEntity(
              comment: json['additional']['comment'],
              hasDiscount: json['additional']['has_discount'],
              hasPromocodes: json['additional']['has_promocodes'],
            )
          : null,
    );
  }
}
