import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class ActionEntity extends Equatable {
  final int? actionId;
  final String? pageTitle;
  final String? alias;
  final String? discount;
  final DateTime? endActionDate;
  final DateTime? createDttm;
  final String? image;
  final String? image1400300;
  final String? image960400;
  final String? goodsIds;
  final List<ProductEntity>? actionProducts;
  final String? content;

  const ActionEntity({
    this.actionId,
    this.pageTitle,
    this.alias,
    this.discount,
    this.endActionDate,
    this.createDttm,
    this.image,
    this.image1400300,
    this.image960400,
    this.goodsIds,
    this.actionProducts,
    this.content,
  });

  @override
  List<Object?> get props => [
        actionId,
        pageTitle,
        alias,
        discount,
        endActionDate,
        createDttm,
        image,
        image1400300,
        image960400,
        goodsIds,
        actionProducts,
        content,
      ];
}
