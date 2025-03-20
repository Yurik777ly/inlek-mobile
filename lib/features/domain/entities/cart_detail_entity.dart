import 'package:equatable/equatable.dart';

class CartDetailEntity extends Equatable {
  final int? id;
  final int? userId;
  final String? promo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartDetailEntity({
    this.id,
    this.userId,
    this.promo,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, promo, createdAt, updatedAt];
}
