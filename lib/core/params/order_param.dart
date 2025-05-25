import 'package:equatable/equatable.dart';
import 'package:inlek/constants/enums.dart';

class OrderParam extends Equatable {
  final int? pharmacyId;
  final String? payment;
  final String delivery;
  final String lastName;
  final String firstName;
  final String email;
  final String phone;
  final String city;
  final String address;
  final String? entrance;
  final String? floor;
  final String? apartment;
  final String? intercom;
  final String? comment;
  final Set<int> ids;
  final List<String> promocodes;
  final DeliveryZoneType? deliveryZone;

  const OrderParam({
    this.pharmacyId,
    this.payment,
    required this.delivery,
    required this.lastName,
    required this.firstName,
    required this.email,
    required this.phone,
    required this.city,
    required this.address,
    this.entrance,
    this.floor,
    this.apartment,
    this.intercom,
    this.comment,
    required this.ids,
    required this.promocodes,
    this.deliveryZone,
  });

  @override
  List<Object?> get props => [
        pharmacyId,
        payment,
        delivery,
        lastName,
        firstName,
        email,
        phone,
        city,
        address,
        entrance,
        floor,
        apartment,
        intercom,
        comment,
        ids,
        promocodes,
        deliveryZone,
      ];

  Map<String, dynamic> toJson() {
    final map = {
      'pharmacy_id': pharmacyId,
      'payment': payment,
      'delivery': delivery,
      'last_name': lastName,
      'first_name': firstName,
      'email': email,
      'phone': phone,
      'city': city,
      'address': address,
      'entrance': entrance,
      'floor': floor,
      'apartment': apartment,
      'intercom': intercom,
      'comment': comment,
      'ids': ids.toList(),
      'promocodes': promocodes,
      'delivery_zone': deliveryZone?.name,
    };

    map.removeWhere((key, value) => value == null);
    return map;
  }

  OrderParam copyWith({
    int? pharmacyId,
    String? payment,
    String? delivery,
    String? lastName,
    String? firstName,
    String? email,
    String? phone,
    String? city,
    String? address,
    String? entrance,
    String? floor,
    String? apartment,
    String? intercom,
    String? comment,
    Set<int>? ids,
    List<String>? promocodes,
    DeliveryZoneType? deliveryZone,
  }) {
    return OrderParam(
      pharmacyId: pharmacyId ?? this.pharmacyId,
      payment: payment ?? this.payment,
      delivery: delivery ?? this.delivery,
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      entrance: entrance ?? this.entrance,
      floor: floor ?? this.floor,
      apartment: apartment ?? this.apartment,
      intercom: intercom ?? this.intercom,
      comment: comment ?? this.comment,
      ids: ids ?? this.ids,
      promocodes: promocodes ?? this.promocodes,
      deliveryZone: deliveryZone ?? this.deliveryZone,
    );
  }
}
