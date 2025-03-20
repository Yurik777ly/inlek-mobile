import 'package:inlek/features/domain/entities/cart_detail_entity.dart';

class CartDetailModel extends CartDetailEntity {
  const CartDetailModel({
    super.id,
    super.userId,
    super.promo,
    super.createdAt,
    super.updatedAt,
  });

  factory CartDetailModel.fromJson(Map<String, dynamic> json) {
    return CartDetailModel(
      id: json["id"],
      userId: json["user_id"],
      promo: json["promo"],
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "promo": promo,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
