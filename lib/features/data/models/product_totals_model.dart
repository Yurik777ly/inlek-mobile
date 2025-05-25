import 'package:inlek/features/domain/entities/product_totals_entity.dart';

class ProductTotalsModel extends ProductTotalsEntity {
  const ProductTotalsModel({
    super.total,
    super.totalOld,
    super.finalTotal,
    super.finalTotalWithPromos,
    super.totalDiscountOnlyPromos,
    super.totalDiscountWithPromos,
    super.totalDiscountWithoutPromos,
  });

  factory ProductTotalsModel.fromJson(Map<String, dynamic> json) {
    return ProductTotalsModel(
      total: json["total"]?.toDouble(),
      totalOld: json["total_old"]?.toDouble(),
      finalTotal: json["final_total"]?.toDouble(),
      finalTotalWithPromos: json["final_total_with_promos"]?.toDouble(),
      totalDiscountOnlyPromos: json["total_discount_only_promos"]?.toDouble(),
      totalDiscountWithPromos: json["total_discount_with_promos"]?.toDouble(),
      totalDiscountWithoutPromos:
          json["total_discount_without_promos"]?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "total": total,
        "total_old": totalOld,
        "final_total": finalTotal,
        "final_total_with_promos": finalTotalWithPromos,
        "total_discount_only_promos": totalDiscountOnlyPromos,
        "total_discount_with_promos": totalDiscountWithPromos,
        "total_discount_without_promos": totalDiscountWithoutPromos,
      };

  @override
  ProductTotalsModel copyWith({
    double? total,
    double? totalOld,
    double? finalTotal,
    double? finalTotalWithPromos,
    double? totalDiscountOnlyPromos,
    double? totalDiscountWithPromos,
    double? totalDiscountWithoutPromos,
  }) {
    return ProductTotalsModel(
      total: total ?? this.total,
      totalOld: totalOld ?? this.totalOld,
      finalTotal: finalTotal ?? this.finalTotal,
      finalTotalWithPromos: finalTotalWithPromos ?? this.finalTotalWithPromos,
      totalDiscountOnlyPromos:
          totalDiscountOnlyPromos ?? this.totalDiscountOnlyPromos,
      totalDiscountWithPromos:
          totalDiscountWithPromos ?? this.totalDiscountWithPromos,
      totalDiscountWithoutPromos:
          totalDiscountWithoutPromos ?? this.totalDiscountWithoutPromos,
    );
  }
}
