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
    return OrderModel(
      orderId: json['order_id'],
      address: json['address'],
      fullDeliveryAddress: json['full_delivery_address'], // 👈
      pharmacyId: json['pharmacy_id'],
      pharmacyName: json['pharmacy_name'],
      customerId: json['customer_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] + 'Z').toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      phone: json['phone'],
      name: json['name'],
      email: json['email'],
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null,
      currency: json['currency'],
      statusId: json['status_id'],
      status: json['status_id'] != null
          ? OrderStatusExtension.fromId(json['status_id'])
          : null,
      comment: json['comment'],
      agree: json['agree'] == "true",
      deliveryId: json['delivery_id'],
      deliveryTitle: json['delivery_title'],
      deliveryPrice: json['delivery_price'] != null
          ? double.tryParse(json['delivery_price'].toString())
          : null,
      deliveryCity: json['delivery_city'],
      deliveryStreet: json['delivery_street'],
      deliveryHouse: json['delivery_house'],
      deliveryEntrance: json['delivery_entrance'],
      deliveryFloor: json['delivery_floor'],
      deliveryApartment: json['delivery_apartment'],
      deliveryComment: json['delivery_comment'],
      paymentId: json['payment_id'],
      paymentTitle: json['payment_title'],
      paymentCaption: json['payment_caption'],
      sumPrices: json['sum_prices'] != null
          ? double.tryParse(json['sum_prices'].toString())
          : null,
      sumPricesOld: json['sum_prices_old'] != null
          ? double.tryParse(json['sum_prices_old'].toString())
          : null,
      sumPricesSalesOld: json['sum_prices_sales_old'] != null
          ? double.tryParse(json['sum_prices_sales_old'].toString())
          : null,
      deliverySum: json['delivery_sum'] != null
          ? double.tryParse(json['delivery_sum'].toString())
          : null,
      totalSum: json['total_sum'] != null
          ? double.tryParse(json['total_sum'].toString())
          : null,
      isPaid: json['is_paid'] == true,
      products: json['order_products_json'] != null
          ? (json['order_products_json'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : null,
      paymentType: PaymentTypeExtension.fromTitle(
          json['payment_method_title'] ?? json['payment_method']),
      typeReceipt: TypeReceivingExtension.fromTitle(
          json['delivery_method_title'] ?? json['delivery_method']),
      pharmacy: json['pharmacy'] != null
          ? PharmacyModel.fromJson(json['pharmacy'][0])
          : null,
      link: json['link'],
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
