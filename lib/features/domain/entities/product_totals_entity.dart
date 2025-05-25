import 'package:equatable/equatable.dart';

class ProductTotalsEntity extends Equatable {
  final double? total;
  final double? totalOld;
  final double? finalTotal;
  final double? finalTotalWithPromos;
  final double? totalDiscountOnlyPromos;
  final double? totalDiscountWithPromos;
  final double? totalDiscountWithoutPromos;

  const ProductTotalsEntity({
    this.total,
    this.totalOld,
    this.finalTotal,
    this.finalTotalWithPromos,
    this.totalDiscountOnlyPromos,
    this.totalDiscountWithPromos,
    this.totalDiscountWithoutPromos,
  });

  ProductTotalsEntity copyWith({
    double? total,
    double? totalOld,
    double? finalTotal,
    double? finalTotalWithPromos,
    double? totalDiscountOnlyPromos,
    double? totalDiscountWithPromos,
    double? totalDiscountWithoutPromos,
  }) {
    return ProductTotalsEntity(
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

  @override
  List<Object?> get props => [
        total,
        totalOld,
        finalTotal,
        finalTotalWithPromos,
        totalDiscountOnlyPromos,
        totalDiscountWithPromos,
        totalDiscountWithoutPromos,
      ];
}
