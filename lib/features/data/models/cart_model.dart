import 'package:inlek/features/data/models/cart_detail_model.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';

import 'product_model.dart';

class CartModel extends CartEntity {
  const CartModel({
    super.cart,
    super.products,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cart:
          json["cart"] != null ? CartDetailModel.fromJson(json["cart"]) : null,
      products: json["product_info"] != null
          ? (json["product_info"] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        "cart": (cart as CartDetailModel?)?.toJson(),
        "product_info":
            products?.map((e) => (e as ProductModel?)?.toJson()).toList(),
      };
}
