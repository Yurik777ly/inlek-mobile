import 'dart:convert';

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
    super.analogProducts,
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
    super.pharmaciesCount,
    super.requestedQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> data) {
    final json = _resolveProductCharacters(data);

    var price = extractOption(data['options'], 'price') ??
        data['price'] ??
        data['product_price_from'] ??
        json['price'] ??
        json["product_price_from"] ??
        json["product_price_"];
    if (price != null) {
      price = double.tryParse(price.toString());
    }

    var priceOld = extractOption(data['options'], 'price_old') ??
        data['price_old'] ??
        data['product_price_from_old'] ??
        json['price_old'] ??
        json["product_price_from_old"] ??
        json["product_price_old"];
    if (priceOld != null) {
      priceOld = double.tryParse(priceOld.toString());
    }
    var discount = data['product_price_from_percent'] ??
        json["product_price_from_percent"] ??
        json["product_price_percent"];
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

    final productId = _parseInt(
      data['product_id'] ??
          json['product_id'] ??
          json['id'] ??
          _optionValue(data['options'], 'product_id'),
    );

    if (productId == null) {
      throw const FormatException('product_id is missing in product JSON');
    }

    return ProductModel(
      productId: productId,
      otherPharmacy: _parseInt(json['other_pharmacy']),
      mnn: _asString(json['mnn']),
      mnnLat: _asString(json['mnn_lat']),
      name: _asString(
            data['product_title'] ??
                json['product_title'] ??
                json['pagetitle'] ??
                json['name'] ??
                json['title'],
          ) ??
          '',
      description: _asString(json['product_description']),
      code: _asString(json['code']),
      dose: _asString(json['dose']),
      form: _asString(json['form']),
      brand: _asString(json['brand']),
      image: _asString(
            json['image'] ??
                json['image_url_handle'] ??
                extractOption(data['options'], 'image') ??
                _optionValue(json['options'], 'image') ??
                data['picture'],
          ) ??
          '',
      recipe: _asString(json['recipe']),
      isRecipe: _parseBool(json['is_recipe']),
      isAlcohol: _parseAlcohol(json['is_alcohol']),
      country: _asString(json['country']),
      delivery: TypeReceivingExtension.fromTitle(_asString(json['delivery'])),
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
      pagetitle: _asString(json['pagetitle'] ?? json['name']),
      brandProducts: _parseNestedProducts(data['brand_products']),
      relatedProducts: _parseNestedProducts(data['related_products']),
      similarProducts: _parseNestedProducts(data['similar_products']),
      analogProducts: _parseNestedProducts(data['analog_products']),
      stockCount: stockCount,
      quantity: data['quantity'] ?? data['count'],
      promocodesJson: [],
      prices: data["prices"] != null
          ? ProductPricesModel.fromJson(data["prices"])
          : null,
      totals: data["product_totals"] != null
          ? ProductTotalsModel.fromJson(data["product_totals"])
          : null,
      instruction: _asString(json['instruction'] ?? data['instruction']),
      categoriesJson: _parseCategories(data['categories_json']),
      availableSomewhere: _parseInt(
        data['is_available'] ?? json['is_available'] ?? data['available_somewhere'],
      ),
      pharmaciesCount: _parseInt(
        data['pharmacies_count'] ?? json['pharmacies_count'],
      ),
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
          'analog_products': analogProducts,
          'quantity': quantity,
          'promocodes_json': [],
          "prices": (prices as ProductPricesModel?)?.toJson(),
          "product_totals": (totals as ProductTotalsModel?)?.toJson(),
        },
        'categories_json':
            categoriesJson?.map((e) => (e as CategoryModel).toJson()).toList(),
      };

  static dynamic extractOption(dynamic source, String key) {
    if (source is String) {
      try {
        final decoded = jsonDecode(source);
        return _optionValue(decoded, key);
      } catch (_) {
        return null;
      }
    }

    return _optionValue(source, key);
  }

  static dynamic _optionValue(dynamic source, String key) {
    if (source is Map) return source[key];
    if (source is List && source.isNotEmpty) {
      final first = source.first;
      if (first is Map) return first[key];
    }
    return null;
  }

  static Map<String, dynamic> _resolveProductCharacters(
      Map<String, dynamic> data) {
    dynamic root = data['product_info'] ?? data;

    if (root is String) {
      root = jsonDecode(root);
    }

    if (root is! Map) {
      return data;
    }

    final rootMap = Map<String, dynamic>.from(root);
    dynamic characters = rootMap['product_charachters'] ?? rootMap;

    if (characters is String) {
      characters = jsonDecode(characters);
    }

    if (characters is Map) {
      return Map<String, dynamic>.from(characters);
    }

    return rootMap;
  }

  static List<ProductModel> _parseNestedProducts(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is String) {
      final decoded = jsonDecode(value);
      return _parseNestedProducts(decoded);
    }

    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<CategoryModel>? _parseCategories(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return _parseCategories(jsonDecode(value));
    }

    if (value is! List) {
      return null;
    }

    return value
        .whereType<Map>()
        .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return value.trim();
    }

    return value.toString();
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().toLowerCase();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'да';
  }

  static bool _parseAlcohol(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().toLowerCase();

    return normalized == 'yes' ||
        normalized == 'true' ||
        normalized == '1' ||
        normalized == 'да';
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
