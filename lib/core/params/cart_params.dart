import 'package:equatable/equatable.dart';

class CartParams extends Equatable {
  final String productId;
  final String quantity;

  const CartParams({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}
