import 'package:inlek/constants/extensions.dart';
import 'package:inlek/features/data/models/category_model.dart';
import 'package:inlek/features/data/models/product_prices_model.dart';
import 'package:inlek/features/data/models/product_totals_model.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.productId,
    super.mnn,
    super.mnnLat,
    required super.name,
    super.description,
    super.code,
    super.dose,
    super.form,
    super.brand,
    required super.image,
    super.recipe,
    super.isRecipe,
    super.isAlcohol,
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
    super.stockCount,
    super.quantity,
    super.promocodesJson,
    super.requiredQuantity,
    super.availability,
    super.prices,
    super.totals,
    super.instruction,
    super.otherPharmacy,
    super.categoriesJson,
    super.availableSomewhere,
    super.requestedQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> data) {
    Map<String, dynamic> json = data["product_info"] ?? data;
    json = json["product_charachters"] ?? json;

    var price = extractOption(data['options'], 'price') ??
        data['price'] ??
        json['price'] ??
        json["product_price_from"] ??
        json["product_price_"];
    if (price != null) {
      price = double.tryParse(price.toString());
    }

    var priceOld = extractOption(data['options'], 'price_old') ??
        data['price_old'] ??
        json['price_old'] ??
        json["product_price_from_old"] ??
        json["product_price_old"];
    if (priceOld != null) {
      priceOld = double.tryParse(priceOld.toString());
    }
    var discount =
        json["product_price_from_percent"] ?? json["product_price_percent"];
    if (discount != null) {
      discount = int.tryParse(discount.toString());
    }

    var stockCountRaw = data['stock_count'] ?? json['stock_count'];
    int? stockCount;

    if (stockCountRaw != null) {
      if (stockCountRaw is int) {
        stockCount = stockCountRaw;
      } else if (stockCountRaw is double) {
        stockCount = stockCountRaw.floor(); // округление до меньшего int
      } else if (stockCountRaw is String) {
        // Пробуем как double, потом округляем
        final parsedDouble = double.tryParse(stockCountRaw);
        if (parsedDouble != null) {
          stockCount = parsedDouble.round();
        } else {
          stockCount = int.tryParse(
              stockCountRaw); // fallback, если это строка типа "15"
        }
      }
    }

    int? count = int.tryParse((json["count"] ??
                data['count'] ??
                json["stock_count"] ??
                data["stock_count"])
            ?.toString() ??
        "0");

    return ProductModel(
      productId: json["product_id"] ??
          (json["id"] is String ? int.tryParse(json["id"]) : json["id"]) ??
          data['product_id'],
      otherPharmacy: json['other_pharmacy'],
      mnn: json["mnn"],
      mnnLat: json["mnn_lat"],
      name: json["product_title"] ??
          json['pagetitle'] ??
          json['name'] ??
          json['title'],
      description: json["product_description"],
      code: json["code"],
      dose: json["dose"],
      form: json["form"],
      brand: json["brand"],
      image: ((json["image"] ??
                  json["image_url_handle"] ??
                  json['options']?['image']) ??
              data['picture'] ??
              '')
          .trim(),
      recipe: json["recipe"],
      isRecipe: json["is_recipe"] == "true" ? true : false,
      isAlcohol: json["is_alcohol"] == "yes" ? true : false,
      country: json["country"],
      delivery: TypeReceivingExtension.fromTitle(json["delivery"]),
      price: price,
      oldPrice: priceOld,
      discount: discount,
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
      count: count,
      requiredQuantity: json['required_quantity'],
      availability: data['availability'] ?? json["availability"],
      pagetitle: json["pagetitle"] ?? json['name'],
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
      stockCount: stockCount,
      quantity: data['quantity'],
      promocodesJson: [],
      prices: data["prices"] != null
          ? ProductPricesModel.fromJson(data["prices"])
          : null,
      totals: data["product_totals"] != null
          ? ProductTotalsModel.fromJson(data["product_totals"])
          : null,
      instruction: json['instruction'],
      categoriesJson: data['categories_json'] != null
          ? (data['categories_json'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList()
          : null,
      availableSomewhere: data['is_available'],
      requestedQuantity: data['requested_quantity'],
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
            "is_recipe": isRecipe,
            "is_alcohol": isAlcohol,
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
            'required_quantity': requiredQuantity,
            'availability': availability,
            'pagetitle': pagetitle,
          },
          'brand_products': brandProducts,
          'related_products': relatedProducts,
          'similar_products': similarProducts,
          'quantity': quantity,
          'promocodes_json': [],
          "prices": (prices as ProductPricesModel?)?.toJson(),
          "product_totals": (totals as ProductTotalsModel?)?.toJson(),
        },
        'categories_json':
            categoriesJson?.map((e) => (e as CategoryModel).toJson()).toList(),
      };

  static dynamic extractOption(dynamic source, String key) {
    if (source is Map) return source[key];
    if (source is List && source.isNotEmpty) return source.first[key];
    return null;
  }
}

class PromocodeModel extends PromocodeEntity {
  const PromocodeModel({
    super.productId,
    super.end,
    super.begin,
    super.usages,
    required super.promocode,
    super.minAmount,
    required super.promotionId,
    required super.promocodePercent,
  });

  factory PromocodeModel.fromJson(Map<String, dynamic> json) {
    return PromocodeModel(
      productId: json['product_id'],
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
      begin: json['begin'] != null ? DateTime.tryParse(json['begin']) : null,
      usages: json['usages'],
      promocode: json['promocode'] ?? json['promocode_name'],
      minAmount: json['min_amount'],
      promotionId: json['promotion_id'] ?? json['promocode_id'],
      promocodePercent: json['promocode_percent'] ?? json['discount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'end': end?.toIso8601String(),
        'begin': begin?.toIso8601String(),
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
