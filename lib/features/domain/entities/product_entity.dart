import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int? productId;
  final String? mnn;
  final String? mnnLat;
  final String? name;
  final String? description;
  final String? code;
  final String? dose;
  final String? form;
  final String? brand;
  final String? image;
  final String? recipe;
  final String? country;
  final String? delivery;
  final double? price;
  final double? oldPrice;
  final int? discount;
  final int? parent;
  final String? termin;
  final String? temperature;
  final String? releaseForm;
  final String? productInsert;
  final String? productSticker;
  final String? productRegister;
  final String? productTrademark;
  final String? productDateRegister;
  final String? productTimeRegister;
  final int? count;
  final String? pagetitle;
  final List<ProductEntity>? brandProducts;
  final List<ProductEntity>? relatedProducts;
  final List<ProductEntity>? similarProducts;
  final int? quantity;
  final List<PromocodeEntity>? promocodesJson;

  const ProductEntity({
    this.productId,
    this.mnn,
    this.mnnLat,
    this.name,
    this.description,
    this.code,
    this.dose,
    this.form,
    this.brand,
    this.image,
    this.recipe,
    this.country,
    this.delivery,
    this.price,
    this.oldPrice,
    this.discount,
    this.parent,
    this.termin,
    this.temperature,
    this.releaseForm,
    this.productInsert,
    this.productSticker,
    this.productRegister,
    this.productTrademark,
    this.productDateRegister,
    this.productTimeRegister,
    this.count,
    this.pagetitle,
    this.brandProducts,
    this.relatedProducts,
    this.similarProducts,
    this.quantity,
    this.promocodesJson,
  });

  // Метод для копирования объекта с возможностью изменения полей
  ProductEntity copyWith({
    int? productId,
    String? mnn,
    String? mnnLat,
    String? name,
    String? description,
    String? code,
    String? dose,
    String? form,
    String? brand,
    String? image,
    String? recipe,
    String? country,
    String? delivery,
    double? price,
    double? oldPrice,
    int? discount,
    int? parent,
    String? termin,
    String? temperature,
    String? releaseForm,
    String? productInsert,
    String? productSticker,
    String? productRegister,
    String? productTrademark,
    String? productDateRegister,
    String? productTimeRegister,
    int? count,
    String? pagetitle,
    List<ProductEntity>? brandProducts,
    List<ProductEntity>? relatedProducts,
    List<ProductEntity>? similarProducts,
    int? quantity,
    List<PromocodeEntity>? promocodesJson,
  }) {
    return ProductEntity(
      productId: productId ?? this.productId,
      mnn: mnn ?? this.mnn,
      mnnLat: mnnLat ?? this.mnnLat,
      name: name ?? this.name,
      description: description ?? this.description,
      code: code ?? this.code,
      dose: dose ?? this.dose,
      form: form ?? this.form,
      brand: brand ?? this.brand,
      image: image ?? this.image,
      recipe: recipe ?? this.recipe,
      country: country ?? this.country,
      delivery: delivery ?? this.delivery,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      discount: discount ?? this.discount,
      parent: parent ?? this.parent,
      termin: termin ?? this.termin,
      temperature: temperature ?? this.temperature,
      releaseForm: releaseForm ?? this.releaseForm,
      productInsert: productInsert ?? this.productInsert,
      productSticker: productSticker ?? this.productSticker,
      productRegister: productRegister ?? this.productRegister,
      productTrademark: productTrademark ?? this.productTrademark,
      productDateRegister: productDateRegister ?? this.productDateRegister,
      productTimeRegister: productTimeRegister ?? this.productTimeRegister,
      count: count ?? this.count,
      pagetitle: pagetitle ?? this.pagetitle,
      brandProducts: brandProducts ?? this.brandProducts,
      relatedProducts: relatedProducts ?? this.relatedProducts,
      similarProducts: similarProducts ?? this.similarProducts,
      quantity: quantity ?? this.quantity,
      promocodesJson: promocodesJson ?? this.promocodesJson,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        mnn,
        mnnLat,
        name,
        description,
        code,
        dose,
        form,
        brand,
        image,
        recipe,
        country,
        delivery,
        price,
        oldPrice,
        discount,
        parent,
        termin,
        temperature,
        releaseForm,
        productInsert,
        productSticker,
        productRegister,
        productTrademark,
        productDateRegister,
        productTimeRegister,
        count,
        pagetitle,
        brandProducts,
        relatedProducts,
        similarProducts,
        quantity,
        promocodesJson,
      ];
}

class PromocodeEntity {
  final int productId;
  final DateTime end;
  final DateTime begin;
  final int usages;
  final String promocode;
  final int minAmount;
  final int promotionId;
  final int promocodePercent;

  const PromocodeEntity({
    required this.productId,
    required this.end,
    required this.begin,
    required this.usages,
    required this.promocode,
    required this.minAmount,
    required this.promotionId,
    required this.promocodePercent,
  });
}
