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

  factory ActionModel.fromJson(Map<String, dynamic> json) => ActionModel(
        actionId: json["action_id"],
        pageTitle: json["pagetitle"],
        alias: json["alias"],
        discount: json["discount"],
        endActionDate: json["end_action_date"] != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss')
                .tryParse(json["end_action_date"])
            : null,
        createDttm: json["create_dttm"] != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(json["create_dttm"])
            : null,
        image: json["image"],
        image1400300: json["image_1400_300"],
        image960400: json["image_960_400"],
        goodsIds: json["goods_ids"],
        actionProducts: json['action_products'] != null
            ? (json['action_products'] as List)
                .map((e) => ProductModel.fromJson(e))
                .toList()
            : [],
      );

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
