import 'package:equatable/equatable.dart';

abstract class BaseProductEntity extends Equatable {
  final int productId;
  final String name;
  final String image;

  const BaseProductEntity({
    required this.productId,
    required this.name,
    required this.image,
  });

  @override
  List<Object?> get props => [productId, name, image];

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'name': name,
        'image': image,
      };
}
