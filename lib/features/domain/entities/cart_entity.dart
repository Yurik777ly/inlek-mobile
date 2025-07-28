import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/cart_detail_entity.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class CartEntity extends Equatable {
  final int? userId;
  final CartPharmacyEntity? pharmacy;
  final CartDetailEntity? cart;
  final List<ProductEntity> products;
  final List<PromocodeEntity> allPromocodes;
  final String enteredPromocodes;

  const CartEntity({
    this.userId,
    this.pharmacy,
    this.cart,
    this.products = const [],
    this.allPromocodes = const [],
    this.enteredPromocodes = "",
  });

  CartEntity copyWith({
    int? userId,
    CartPharmacyEntity? pharmacy,
    CartDetailEntity? cart,
    List<ProductEntity>? products,
    List<PromocodeEntity>? allPromocodes,
    String? enteredPromocodes,
  }) {
    return CartEntity(
      userId: userId ?? this.userId,
      pharmacy: pharmacy ?? this.pharmacy,
      cart: cart ?? this.cart,
      products: products ?? this.products,
      allPromocodes: allPromocodes ?? this.allPromocodes,
      enteredPromocodes: enteredPromocodes ?? this.enteredPromocodes,
    );
  }

  @override
  List<Object?> get props =>
      [userId, pharmacy, cart, products, allPromocodes, enteredPromocodes];
}
