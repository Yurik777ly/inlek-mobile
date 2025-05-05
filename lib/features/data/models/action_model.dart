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
  });

  factory ActionModel.fromRawJson(String str) =>
      ActionModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? action = json;
    List<dynamic>? products = json['action_products'];
    if (json.containsKey('action')) {
      action = action['action'];
      products = action?['action_products'];
    }
    return ActionModel(
      actionId: action?["action_id"],
      pageTitle: action?["pagetitle"],
      alias: action?["alias"],
      discount: action?["discount"],
      endActionDate: action?["end_action_date"] != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss')
              .tryParse(action?["end_action_date"])
          : null,
      createDttm: action?["create_dttm"] != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(action?["create_dttm"])
          : null,
      image: action?["image"],
      image1400300: action?["image_1400_300"],
      image960400: action?["image_960_400"],
      goodsIds: action?["goods_ids"],
      actionProducts: products != null
          ? products.map((e) => ProductModel.fromJson(e)).toList()
          : [],
    );
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
      };
}
