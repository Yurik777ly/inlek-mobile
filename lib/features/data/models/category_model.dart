import 'dart:convert';

import 'package:inlek/features/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.categoryId,
    super.pageTitle,
    super.alias,
    super.image,
  });

  factory CategoryModel.fromRawJson(String str) =>
      CategoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        categoryId: json["category_id"] ?? int.tryParse(json["id"]?.toString() ?? ''),
        pageTitle: json["pagetitle"] ?? json['name'] ?? json['category_name'],
        alias: json["alias"],
        image: json["image"] ?? json["category_image"],
      );

  Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "pagetitle": pageTitle,
        "alias": alias,
        "image": image,
      };
}
