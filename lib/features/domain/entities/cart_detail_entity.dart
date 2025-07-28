import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';

class CartDetailEntity extends Equatable {
  final int? cartId;
  final int? userId;
  final String? appliedPromocodes;
  final DateTime? cartCreatedAt;
  final DateTime? cartUpdatedAt;
  final Map<String, dynamic>? totals;
  final CartPharmacyEntity? pharmacy;

  const CartDetailEntity({
    this.cartId,
    this.userId,
    this.appliedPromocodes,
    this.cartCreatedAt,
    this.cartUpdatedAt,
    this.totals,
    this.pharmacy,
  });

  @override
  List<Object?> get props => [
        cartId,
        userId,
        appliedPromocodes,
        cartCreatedAt,
        cartUpdatedAt,
        totals,
        pharmacy,
      ];
}
