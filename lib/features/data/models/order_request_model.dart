import 'package:inlek/features/data/models/product_model.dart';
import 'package:inlek/features/domain/entities/order_request_entity.dart';

class OrderRequestModel extends OrderRequestEntity {
  const OrderRequestModel({
    required super.delivery,
    required super.lastName,
    required super.firstName,
    required super.phone,
    super.email,
    required super.city,
    required super.address,
    super.entrance,
    super.floor,
    super.apartment,
    super.intercom,
    super.comment,
    super.products,
  });

  factory OrderRequestModel.fromJson(Map<String, dynamic> json) {
    return OrderRequestModel(
      delivery: json['delivery'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      phone: json['phone'],
      email: json['email'],
      city: json['city'],
      address: json['address'],
      entrance: json['entrance'],
      floor: json['floor'],
      apartment: json['apartment'],
      intercom: json['intercom'],
      comment: json['comment'],
      products: json['products'] != null
          ? (json['products'] as List)
              .map((e) => ProductModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery': delivery,
      'last_name': lastName,
      'first_name': firstName,
      'phone': phone,
      'email': email,
      'city': city,
      'address': address,
      'entrance': entrance,
      'floor': floor,
      'apartment': apartment,
      'intercom': intercom,
      'comment': comment,
      'products': products?.map((e) => (e as ProductModel).toJson()).toList(),
    };
  }
}
