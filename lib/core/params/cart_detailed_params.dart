import 'package:inlek/constants/enums.dart';

class CartDetailedParams {
  final int? pharmacyId;
  final DeliveryZoneType deliveryZone;
  final String promocodes;

  CartDetailedParams({
    this.pharmacyId,
    this.deliveryZone = DeliveryZoneType.none,
    this.promocodes = "",
  });
}
