import 'dart:convert';

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
    final deliveryInfo = json['delivery_info'];
    final paymentInfo = json['payment_info'];

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

    fullDeliveryAddress = deliveryParts
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(', ');

    final products = _parseOrderProducts(json, data);

    return OrderModel(
      orderId: data['order_id'] ?? data['id'],
      address: data['address'],
      fullDeliveryAddress: data['full_delivery_address'] ??
          (deliveryInfo is Map ? deliveryInfo['address'] : null) ??
          fullDeliveryAddress,
      pharmacyId: data['pharmacy_id'],
      pharmacyName: data['pharmacy_name'],
      customerId: data['customer_id'],
      createdAt: data['created_at'] != null
          ? _parseOrderDateTime(data['created_at'])
          : null,
      updatedAt: data['updated_at'] != null
          ? _parseOrderDateTime(data['updated_at'])
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
      paymentTitle: data['payment_title'] ??
          (paymentInfo is Map ? paymentInfo['method_title'] : null),
      paymentCaption: data['payment_caption'],
      sumPrices: _parseOrderDouble(
        data['sum_prices'] ?? data['prices_sum'] ?? data['products_price'],
      ),
      sumPricesOld: _parseOrderDouble(data['sum_prices_old']),
      sumPricesSalesOld: _parseOrderDouble(data['sum_prices_sales_old']),
      deliverySum: _parseOrderDouble(data['delivery_sum']),
      totalSum: _parseOrderDouble(
        data['total_sum'] ?? data['amount'],
      ),
      isPaid: data['is_paid'] == true,
      products: products,
      paymentType: PaymentTypeExtension.fromTitle(
        data['payment_method'] ??
            data['payment_type'] ??
            (paymentInfo is Map ? paymentInfo['method'] : null) ??
            (paymentInfo is Map ? paymentInfo['method_title'] : null),
      ),
      typeReceipt: TypeReceivingExtension.fromTitle(
        data['delivery_method_title'] ??
            data['delivery_method'] ??
            (deliveryInfo is Map ? deliveryInfo['method_title'] : null) ??
            (deliveryInfo is Map ? deliveryInfo['method'] : null),
      ),
      pharmacy: _parsePharmacy(data['pharmacy']) ?? _pharmacyFromOrderFields(data),
      link: data['payment_link'] ??
          json['additional']?['payment_link'] ??
          (paymentInfo is Map ? paymentInfo['payment_link'] : null),
      summary: _parseSummary(json, data),
      additional: json['additional'] != null
          ? OrderAdditionalEntity(
              comment: json['additional']['comment'],
              hasDiscount: json['additional']['has_discount'],
              hasPromocodes: json['additional']['has_promocodes'],
            )
          : null,
    );
  }

  static double? _parseOrderDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static OrderSummaryEntity? _parseSummary(
    Map<String, dynamic> json,
    Map<String, dynamic> data,
  ) {
    final rawSummary =
        json['summary'] is Map ? Map<String, dynamic>.from(json['summary']) : null;

    final productsPrice = _parseOrderDouble(
          rawSummary?['products_price'] ??
              data['sum_prices'] ??
              data['prices_sum'],
        ) ??
        _parseOrderDouble(data['amount']);

    final totalPrice = _parseOrderDouble(
          rawSummary?['total_price'] ?? data['total_sum'],
        ) ??
        _parseOrderDouble(data['amount']);

    if (productsPrice == null && totalPrice == null) {
      return null;
    }

    return OrderSummaryEntity(
      productsPrice: productsPrice,
      productsPriceOld: _parseOrderDouble(
        rawSummary?['products_price_old'] ?? data['sum_prices_old'],
      ),
      discountPercent: _parseOrderDouble(rawSummary?['discount_percent']),
      discountAmount: _parseOrderDouble(rawSummary?['discount_amount']),
      promocodesDiscount: _parseOrderDouble(rawSummary?['promocodes_discount']),
      deliveryPrice: _parseOrderDouble(
        rawSummary?['delivery_price'] ?? data['delivery_sum'],
      ),
      totalPrice: totalPrice,
    );
  }

  static List<ProductModel>? _parseOrderProducts(
    Map<String, dynamic> json,
    Map<String, dynamic> data,
  ) {
    dynamic raw = data['order_products_json'] ?? json['products'];
    if (raw == null) {
      return null;
    }

    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }

    if (raw is! List) {
      return null;
    }

    final products = <ProductModel>[];
    for (final item in raw) {
      if (item is! Map) {
        continue;
      }

      try {
        products.add(
          ProductModel.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (_) {
        continue;
      }
    }

    return products.isEmpty ? null : products;
  }

  /// API отдаёт минское wall-clock время без таймзоны; ISO с offset/Z — legacy.
  static DateTime _parseOrderDateTime(dynamic raw) {
    final value = raw.toString().trim();

    if (value.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(value)) {
      return DateTime.parse(value).toLocal();
    }

    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?',
    ).firstMatch(value);
    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
        int.parse(match.group(6) ?? '0'),
      );
    }

    return DateTime.parse(value);
  }

  static PharmacyModel? _pharmacyFromOrderFields(Map<String, dynamic> data) {
    final pharmacyId = data['pharmacy_id'];
    if (pharmacyId == null) {
      return null;
    }

    final id = int.tryParse(pharmacyId.toString());
    if (id == null || id <= 0) {
      return null;
    }

    final name = data['pharmacy_name']?.toString() ?? '';
    final address = data['address']?.toString() ?? '';
    if (name.isEmpty && address.isEmpty) {
      return null;
    }

    return PharmacyModel(
      pharmacyId: id,
      pharmacyName: name,
      address: address,
      coordinates: '',
      schedule: '',
    );
  }

  static PharmacyModel? _parsePharmacy(dynamic raw) {
    if (raw == null) {
      return null;
    }

    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map) {
        return PharmacyModel.fromJson(Map<String, dynamic>.from(first));
      }
      return null;
    }

    if (raw is Map) {
      return PharmacyModel.fromJson(Map<String, dynamic>.from(raw));
    }

    return null;
  }
}
