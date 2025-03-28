import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';

class OrderRequestEntity extends Equatable {
  final String delivery;
  final String lastName;
  final String firstName;
  final String phone;
  final String? email;
  final String city;
  final String address;
  final String? entrance;
  final String? floor;
  final String? apartment;
  final String? intercom;
  final String? comment;
  final List<ProductEntity>? products;

  const OrderRequestEntity({
    required this.delivery,
    required this.lastName,
    required this.firstName,
    required this.phone,
    this.email,
    required this.city,
    required this.address,
    this.entrance,
    this.floor,
    this.apartment,
    this.intercom,
    this.comment,
    this.products,
  });

  @override
  List<Object?> get props => [
        delivery,
        lastName,
        firstName,
        phone,
        email,
        city,
        address,
        entrance,
        floor,
        apartment,
        intercom,
        comment,
        products,
      ];
}
