import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/cart_detail_entity.dart';

import 'product_entity.dart';

class CartEntity extends Equatable {
  final CartDetailEntity? cart;
  final List<ProductEntity>? products;

  const CartEntity({
    this.cart,
    this.products,
  });

  CartEntity copyWith({
    CartDetailEntity? cart,
    List<ProductEntity>? products,
  }) {
    return CartEntity(
      cart: cart ?? this.cart,
      products: products ?? this.products,
    );
  }

  @override
  List<Object?> get props => [cart, products];
}
