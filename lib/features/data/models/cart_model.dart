import 'package:inlek/features/data/models/cart_detail_model.dart';
import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';

class CartModel extends CartEntity {
  const CartModel({
    super.userId,
    super.pharmacyId,
    super.cart,
    super.products,
    super.allPromocodes,
    super.enteredPromocodes,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
        userId: json["user_id"],
        pharmacyId: json["pharmacy_id"],
        cart: json["cart"] != null
            ? CartDetailModel.fromJson(json["cart"])
            : null,
        products: json["cart"]?["products"] != null
            ? (json["cart"]["products"] as List)
                .map((e) => ProductModel.fromJson(e))
                .toList()
            : [],
        allPromocodes: json["cart"]?["all_promocodes"] != null
            ? (json["cart"]["all_promocodes"] as List)
                .map((e) => PromocodeModel.fromJson(e))
                .toList()
            : [],
        enteredPromocodes: json["cart"]["entered_promocodes"]);
  }

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "pharmacy_id": pharmacyId,
        "cart": (cart as CartDetailModel?)?.toJson(),
        "all_promocodes": (allPromocodes as PromocodeModel?)?.toJson(),
        "entered_promocodes": enteredPromocodes,
      };
}
