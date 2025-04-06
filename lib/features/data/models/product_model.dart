import 'package:inlek/features/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    super.productId,
    super.mnn,
    super.mnnLat,
    super.name,
    super.description,
    super.code,
    super.dose,
    super.form,
    super.brand,
    super.image,
    super.recipe,
    super.country,
    super.delivery,
    super.price,
    super.oldPrice,
    super.discount,
    super.parent,
    super.termin,
    super.temperature,
    super.releaseForm,
    super.productInsert,
    super.productSticker,
    super.productRegister,
    super.productTrademark,
    super.productDateRegister,
    super.productTimeRegister,
    super.count,
    super.pagetitle,
    super.brandProducts,
    super.relatedProducts,
    super.similarProducts,
    super.quantity,
    super.promocodesJson,
  });

  @override
  factory ProductModel.fromJson(Map<String, dynamic> data) {
    Map<String, dynamic> json = data["product_info"] ?? data;
    json = json["product_charachters"] ?? json;
    return ProductModel(
      productId: json["product_id"] ?? json["id"],
      mnn: json["mnn"],
      mnnLat: json["mnn_lat"],
      name: json["product_title"],
      description: json["product_description"],
      code: json["code"],
      dose: json["dose"],
      form: json["form"],
      brand: json["brand"],
      image: json["image"],
      recipe: json["recipe"],
      country: json["country"],
      delivery: json["delivery"],
      price: json['price'] is double
          ? json['price']
          : double.tryParse(json["product_price_from"] ?? ''),
      oldPrice: double.tryParse(
        (json["product_price_from_old"] ?? ''),
      ),
      discount: int.tryParse(
        (json["product_price_from_percent"] ?? ''),
      ),
      parent: json["parent"],
      termin: json["termin"],
      temperature: json["temperature"],
      releaseForm: json["release_form"],
      productInsert: json["product_insert"],
      productSticker: json["product_sticker"],
      productRegister: json["product_register"],
      productTrademark: json["product_trademark"],
      productDateRegister: json["product_date_register"],
      productTimeRegister: json["product_time_register"],
      count: json["count"],
      pagetitle: json["pagetitle"],
      brandProducts: data['brand_products'] != null
          ? (data['brand_products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : [],
      relatedProducts: data['related_products'] != null
          ? (data['related_products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : [],
      similarProducts: data['similar_products'] != null
          ? (data['similar_products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : [],
      quantity: data['quantity'],
      promocodesJson: data['promocodes_json'] != null
          ? (data['promocodes_json'] as List)
              .map((e) => PromocodeModel.fromJson(
                    (e as Map<String, dynamic>)
                      ..addAll({'product_id': json["product_id"]}),
                  ) as PromocodeEntity)
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "product_info": {
          "product_id": productId,
          "product_charachters": {
            "mnn": mnn,
            "mnn_lat": mnnLat,
            "product_title": name,
            "product_description": description,
            "code": code,
            "dose": dose,
            "form": form,
            "brand": brand,
            "image": image,
            "recipe": recipe,
            "country": country,
            "delivery": delivery,
            "product_price_from": price,
            "product_price_from_old": oldPrice,
            "product_price_from_percent": discount,
            "parent": parent,
            "termin": termin,
            "temperature": temperature,
            "release_form": releaseForm,
            "product_insert": productInsert,
            "product_sticker": productSticker,
            "product_register": productRegister,
            "product_trademark": productTrademark,
            "product_date_register": productDateRegister,
            "product_time_register": productTimeRegister,
            'count': count,
            'pagetitle': pagetitle,
          },
          'brand_products': brandProducts,
          'related_products': relatedProducts,
          'similar_products': similarProducts,
          'quantity': quantity,
          'promocodes_json': promocodesJson
              ?.map((e) => (e as PromocodeModel).toJson())
              .toList(),
        }
      };
}

class PromocodeModel extends PromocodeEntity {
  const PromocodeModel({
    required super.productId,
    required super.end,
    required super.begin,
    required super.usages,
    required super.promocode,
    required super.minAmount,
    required super.promotionId,
    required super.promocodePercent,
  });

  factory PromocodeModel.fromJson(Map<String, dynamic> json) {
    return PromocodeModel(
      productId: json['product_id'],
      end: DateTime.parse(json['end']),
      begin: DateTime.parse(json['begin']),
      usages: json['usages'],
      promocode: json['promocode'],
      minAmount: json['min_amount'],
      promotionId: json['promotion_id'],
      promocodePercent: json['promocode_percent'],
    );
  }

  Map<String, dynamic> toJson() => {
        'end': end.toIso8601String(),
        'begin': begin.toIso8601String(),
        'usages': usages,
        'promocode': promocode,
        'min_amount': minAmount,
        'promotion_id': promotionId,
        'promocode_percent': promocodePercent,
      };
}

class PropertiesModel extends PropertiesEntity {
  const PropertiesModel({
    required super.brand,
    required super.country,
    required super.releaseForm,
  });

  factory PropertiesModel.fromJson(Map<String, dynamic> json) =>
      PropertiesModel(
        brand: json["brand"] == null ? null : json["brand"]["value"],
        country: json["country"] == null ? null : json["country"]["value"],
        releaseForm:
            json["release_form"] == null ? null : json["release_form"]["value"],
      );

  @override
  PropertiesModel copyWith({
    String? brand,
    String? country,
    String? releaseForm,
  }) =>
      PropertiesModel(
        brand: brand ?? this.brand,
        country: country ?? this.country,
        releaseForm: releaseForm ?? this.releaseForm,
      );

  @override
  List<Object?> get props => [brand, country, releaseForm];
}
