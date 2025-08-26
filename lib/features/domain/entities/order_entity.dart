import 'package:equatable/equatable.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class OrderSummaryEntity extends Equatable {
  final double? productsPrice;
  final double? productsPriceOld;
  final double? discountPercent;
  final double? discountAmount;
  final double? promocodesDiscount;
  final double? deliveryPrice;
  final double? totalPrice;

  const OrderSummaryEntity({
    this.productsPrice,
    this.productsPriceOld,
    this.discountPercent,
    this.discountAmount,
    this.promocodesDiscount,
    this.deliveryPrice,
    this.totalPrice,
  });

  @override
  List<Object?> get props => [
        productsPrice,
        productsPriceOld,
        discountPercent,
        discountAmount,
        promocodesDiscount,
        deliveryPrice,
        totalPrice,
      ];
}

class OrderAdditionalEntity extends Equatable {
  final String? comment;
  final bool? hasDiscount;
  final bool? hasPromocodes;

  const OrderAdditionalEntity({
    this.comment,
    this.hasDiscount,
    this.hasPromocodes,
  });

  @override
  List<Object?> get props => [
        comment,
        hasDiscount,
        hasPromocodes,
      ];
}

class OrderEntity extends Equatable {
  final int? orderId;
  final String? address;
  final String? fullDeliveryAddress; // 👈 новое поле
  final int? pharmacyId;
  final String? pharmacyName;
  final int? customerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? phone;
  final String? name;
  final String? email;
  final double? amount;
  final String? currency;
  final int? statusId;
  final OrderStatus? status;
  final String? comment;
  final bool? agree;
  final String? deliveryId;
  final String? deliveryTitle;
  final double? deliveryPrice;
  final String? deliveryCity;
  final String? deliveryStreet;
  final String? deliveryHouse;
  final String? deliveryEntrance;
  final String? deliveryFloor;
  final String? deliveryApartment;
  final String? deliveryComment;
  final String? paymentId;
  final String? paymentTitle;
  final String? paymentCaption;
  final double? sumPrices;
  final double? sumPricesOld;
  final double? sumPricesSalesOld;
  final double? deliverySum;
  final double? totalSum;
  final bool? isPaid;
  final List<ProductEntity>? products;
  final PaymentType? paymentType;
  final TypeReceiving? typeReceipt;
  final PharmacyEntity? pharmacy;
  final String? link;

  final OrderSummaryEntity? summary; // 👈 новое поле
  final OrderAdditionalEntity? additional; // 👈 новое поле

  const OrderEntity({
    this.orderId,
    this.address,
    this.fullDeliveryAddress,
    this.pharmacyId,
    this.pharmacyName,
    this.customerId,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.name,
    this.email,
    this.amount,
    this.currency,
    this.statusId,
    this.status,
    this.comment,
    this.agree,
    this.deliveryId,
    this.deliveryTitle,
    this.deliveryPrice,
    this.deliveryCity,
    this.deliveryStreet,
    this.deliveryHouse,
    this.deliveryEntrance,
    this.deliveryFloor,
    this.deliveryApartment,
    this.deliveryComment,
    this.paymentId,
    this.paymentTitle,
    this.paymentCaption,
    this.sumPrices,
    this.sumPricesOld,
    this.sumPricesSalesOld,
    this.deliverySum,
    this.totalSum,
    this.isPaid,
    this.products,
    this.paymentType,
    this.typeReceipt,
    this.pharmacy,
    this.link,
    this.summary,
    this.additional,
  });

  @override
  List<Object?> get props => [
        orderId,
        address,
        fullDeliveryAddress,
        pharmacyId,
        pharmacyName,
        customerId,
        createdAt,
        updatedAt,
        phone,
        name,
        email,
        amount,
        currency,
        statusId,
        status,
        comment,
        agree,
        deliveryId,
        deliveryTitle,
        deliveryPrice,
        deliveryCity,
        deliveryStreet,
        deliveryHouse,
        deliveryEntrance,
        deliveryFloor,
        deliveryApartment,
        deliveryComment,
        paymentId,
        paymentTitle,
        paymentCaption,
        sumPrices,
        sumPricesOld,
        sumPricesSalesOld,
        deliverySum,
        totalSum,
        isPaid,
        products,
        paymentType,
        typeReceipt,
        pharmacy,
        link,
        summary,
        additional,
      ];
}
