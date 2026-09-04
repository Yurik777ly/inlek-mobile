import 'dart:convert';

import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:intl/intl.dart';

class ActionModel extends ActionEntity {
  const ActionModel({
    super.actionId,
    super.pageTitle,
    super.alias,
    super.discount,
    super.endActionDate,
    super.createDttm,
    super.image,
    super.image1400300,
    super.image960400,
    super.goodsIds,
    super.actionProducts,
    super.content,
  });

  factory ActionModel.fromRawJson(String str) =>
      ActionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? action = json;
    dynamic products = json['action_products'];
    if (json.containsKey('action')) {
      action = json['action'] is Map
          ? Map<String, dynamic>.from(json['action'] as Map)
          : null;
      products = action?['action_products'] ?? json['products'];
    }
    return ActionModel(
      actionId: action?["action_id"],
      pageTitle: action?["pagetitle"],
      alias: action?["alias"],
      discount: action?["discount"],
      endActionDate: _parseActionDate(action?["end_action_date"]),
      createDttm: _parseActionDate(action?["create_dttm"]),
      image: action?["image"],
      image1400300: action?["image_1400_300"],
      image960400: action?["image_960_400"],
      goodsIds: action?["goods_ids"],
      actionProducts: _parseActionProducts(products),
      content: action?["content"],
    );
  }

  static DateTime? _parseActionDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(value.toString());
  }

  static List<ProductModel> _parseActionProducts(dynamic products) {
    if (products == null) {
      return [];
    }

    if (products is String) {
      try {
        products = json.decode(products);
      } catch (_) {
        return [];
      }
    }

    if (products is! List) {
      return [];
    }

    final parsedProducts = <ProductModel>[];

    for (final item in products) {
      if (item is! Map) {
        continue;
      }

      final normalized = _normalizeActionProduct(
        Map<String, dynamic>.from(item),
      );
      if (normalized == null) {
        continue;
      }

      try {
        parsedProducts.add(ProductModel.fromJson(normalized));
      } catch (_) {
        continue;
      }
    }

    return parsedProducts;
  }

  static Map<String, dynamic>? _normalizeActionProduct(
    Map<String, dynamic> map,
  ) {
    if (map['product_charachters'] != null) {
      return map;
    }

    if (map['info'] is Map) {
      return {
        ...map,
        'product_charachters': map['info'],
      };
    }

    if (map['product_id'] != null) {
      return map;
    }

    return null;
  }

  Map<String, dynamic> toJson() => {
        "action_id": actionId,
        "pagetitle": pageTitle,
        "alias": alias,
        "discount": discount,
        "end_action_date": endActionDate,
        "create_dttm": createDttm,
        "image": image,
        "image_1400_300": image1400300,
        "image_960_400": image960400,
        "goods_ids": goodsIds,
        "action_products": actionProducts,
        "content": content,
      };
}
