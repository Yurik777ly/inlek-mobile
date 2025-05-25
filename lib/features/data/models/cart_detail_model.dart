import 'package:inlek/features/domain/entities/cart_detail_entity.dart';

class CartDetailModel extends CartDetailEntity {
  const CartDetailModel({
    super.cartId,
    super.userId,
    super.appliedPromocodes,
    super.cartCreatedAt,
    super.cartUpdatedAt,
    super.totals,
    super.pharmacy,
  });

  factory CartDetailModel.fromJson(Map<String, dynamic> json) {
    return CartDetailModel(
      cartId: json["cart_id"],
      userId: json["user_id"],
      appliedPromocodes: json["applied_promocodes"],
      cartCreatedAt: json["cart_created_at"] != null
          ? DateTime.parse(json["cart_created_at"])
          : null,
      cartUpdatedAt: json["cart_updated_at"] != null
          ? DateTime.parse(json["cart_updated_at"])
          : null,
      totals: json["totals"],
      pharmacy: json["pharmacy"],
    );
  }

  Map<String, dynamic> toJson() => {
        "cart_id": cartId,
        "user_id": userId,
        "applied_promocodes": appliedPromocodes,
        "cart_created_at": cartCreatedAt?.toIso8601String(),
        "cart_updated_at": cartUpdatedAt?.toIso8601String(),
        "totals": totals,
        "pharmacy": pharmacy,
      };
}
