import 'dart:convert';

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
    super.pivot,
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
      price: double.tryParse(json["product_price_from"] ?? ''),
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
      pivot: data['pivot'] != null ? PivotModel.fromJson(data['pivot']) : null,
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
          'pivot': pivot,
        }
      };
}

class PivotModel extends PivotEntity {
  const PivotModel({
    required super.cartId,
    required super.evoSiteContentId,
    required super.quantity,
  });

  factory PivotModel.fromRawJson(String str) =>
      PivotModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PivotModel.fromJson(Map<String, dynamic> json) => PivotModel(
        cartId: json["cart_id"],
        evoSiteContentId: json["evo_site_content_id"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "cart_id": cartId,
        "evo_site_content_id": evoSiteContentId,
        "quantity": quantity,
      };
}
