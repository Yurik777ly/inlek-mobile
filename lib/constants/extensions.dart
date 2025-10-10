import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/main.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

extension DpExtensionDouble on double {
  double get dp {
    final context = navigatorKey.currentContext;
    if (context == null) return this;
    final scale = View.of(context).display.devicePixelRatio;
    return this / scale * 3.5;
  }
}

extension DpExtensionInt on int {
  double get dp {
    final context = navigatorKey.currentContext;
    if (context == null) return toDouble();
    final scale = View.of(context).display.devicePixelRatio;
    return this / scale * 3.5;
  }
}

extension EmptyPadding on num {
  SizedBox get ph => SizedBox(height: toDouble());

  SizedBox get pw => SizedBox(width: toDouble());
}

extension StringExtensions on String? {
  String orDash() {
    return (this == null || this!.isEmpty) ? '-' : this!;
  }
}

extension OrderStatusExtension on OrderStatus {
  static const Map<OrderStatus, String> titles = {
    OrderStatus.courier: 'У курьера',
    OrderStatus.readyToIssue: 'Готов к выдаче',
    OrderStatus.reserved: 'Зарезервирован',
    OrderStatus.canceled: 'Отменен',
    OrderStatus.received: 'Получен',
    OrderStatus.collected: 'Собран',
    OrderStatus.processing: 'В обработке',
    OrderStatus.awaitingPayment: 'Ожидает оплаты',
  };

  String get title => titles[this] ?? 'Неизвестный статус';

  static OrderStatus fromId(int id) {
    switch (id) {
      case 1:
        return OrderStatus.processing;
      case 2:
        return OrderStatus.processing;
      case 3:
        return OrderStatus.readyToIssue;
      case 4:
        return OrderStatus.reserved;
      case 5:
        return OrderStatus.received;
      case 6:
        return OrderStatus.collected;
      case 7:
        return OrderStatus.courier;
      case 8:
        return OrderStatus.canceled;
      case 10:
        return OrderStatus.awaitingPayment;
      default:
        return OrderStatus.processing;
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'В обработке':
        return OrderStatus.processing;
      case 'Готов к выдаче':
        return OrderStatus.readyToIssue;
      case 'Зарезервирован':
        return OrderStatus.reserved;
      case 'Получен':
        return OrderStatus.received;
      case 'Укомплектован':
        return OrderStatus.collected;
      case 'Передан курьеру':
        return OrderStatus.courier;
      case 'Отменен':
        return OrderStatus.canceled;
      case 'Ожидает оплаты':
        return OrderStatus.awaitingPayment;
      default:
        return OrderStatus.processing;
    }
  }

  static OrderStatus? fromTitle(String? title) {
    return titles.entries
        .firstWhere(
          (entry) => entry.value == title,
          orElse: () =>
              const MapEntry(OrderStatus.processing, ''), // обработка ошибки
        )
        .key;
  }
}

extension TypeReceivingExtension on TypeReceiving {
  static const Map<TypeReceiving, String> titles = {
    TypeReceiving.all: 'Все',
    TypeReceiving.delivery: 'Доставка',
    TypeReceiving.pickup: 'Самовывоз',
  };

  String get title => titles[this] ?? 'Неизвестный способ получения';

  static TypeReceiving? fromTitle(String? title) {
    switch (title) {
      case 'Самовывоз':
        return TypeReceiving.pickup;
      case 'delivery':
        return TypeReceiving.delivery;
      case 'Доставка':
        return TypeReceiving.delivery;
      case 'self':
        return TypeReceiving.pickup;
    }
    return null;
  }
}

extension PaymentTypeExtension on PaymentType {
  static const Map<PaymentType, String> titles = {
    PaymentType.courier: 'Курьеру',
    PaymentType.cash: 'Курьеру',
    PaymentType.oplati: 'Онлайн (ОПЛАТИ)',
    PaymentType.bepaid: 'Онлайн (Bepaid)',
    PaymentType.erip: 'Онлайн (ЕРИП)',
  };

  String get title => titles[this] ?? 'Неизвестный способ оплаты';

  static PaymentType? fromTitle(String? title) {
    switch (title) {
      case 'cash':
        return PaymentType.cash;
      case 'Курьеру':
        return PaymentType.courier;
      case 'bepaid':
        return PaymentType.bepaid;
      case 'oplati':
        return PaymentType.oplati;
      case 'erip':
        return PaymentType.erip;
    }
    return null;
  }
}

extension ProductSortTypeExtension on ProductSortType {
  String get apiValue {
    switch (this) {
      case ProductSortType.popularity:
        return 'popularity';
      case ProductSortType.priceDecrease:
        return 'price_desc';
      case ProductSortType.priceIncrease:
        return 'price_asc';
    }
  }

  String get displayName {
    switch (this) {
      case ProductSortType.popularity:
        return 'По популярности';
      case ProductSortType.priceDecrease:
        return 'По убыванию цены';
      case ProductSortType.priceIncrease:
        return 'По возрастанию цены';
    }
  }
}

extension ProductChipTypeExtension on ProductChipType {
  static ProductChipType fromString(String value) {
    switch (value) {
      case 'hit':
        return ProductChipType.hit;
      case 'new':
        return ProductChipType.nova;
      case 'season':
        return ProductChipType.seasonalOffer;
      case 'action':
        return ProductChipType.stock;

      default:
        return ProductChipType.stock;
    }
  }
}

extension DeliveryZonePriceExtension on DeliveryZoneType {
  static const Map<DeliveryZoneType, double> zonePrices = {
    DeliveryZoneType.green: 0, // Бесплатная доставка для зелёной зоны
    DeliveryZoneType.yellow: 8, // Стоимость доставки для жёлтой зоны
    DeliveryZoneType.none: -1, // Для неизвестных зон, например, не определить
  };

  double get price {
    return zonePrices[this] ?? -1;
  }

  /// Метод, который пробрасывает цену по зоне
  int getPrice(double totalPrice) {
    if (this == DeliveryZoneType.yellow) {
      return 8;
    } else {
      if (totalPrice < 40) {
        return 8;
      } else {
        return 0;
      }
    }
  }
}

extension GeoObjectSerialization on GeoObject {
  /// Преобразует GeoObject в JSON-строку
  String toJsonString() {
    final map = {
      'metaDataProperty': {
        'geocoderMetaData': {
          'address': {
            'formatted': metaDataProperty?.geocoderMetaData?.address?.formatted,
            'components':
                metaDataProperty?.geocoderMetaData?.address?.components
                    ?.map((component) => {
                          'kind': {'name': component.kind?.name},
                          'name': component.name,
                          'comparedObjects': component.comparedObjects
                              .map((object) => object is KindResponse
                                  ? {'name': object.name}
                                  : object is String
                                      ? object
                                      : '')
                              .toList(),
                        })
                    .toList(),
          },
        },
      },
      'point': point != null
          ? {
              'latitude': point?.latitude,
              'longitude': point?.longitude,
            }
          : null,
    };
    return json.encode(map);
  }

  /// Создает GeoObject из JSON-строки
  static GeoObject fromJsonString(String jsonString) {
    print(jsonString);
    final innerJson =
        json.decode(jsonString) as String; // распаковать двойную строку
    print(innerJson);
    final map = json.decode(innerJson) as Map<String, dynamic>;

    final addressMap = map['metaDataProperty']?['geocoderMetaData']?['address'];

    final components =
        (addressMap?['components'] as List<dynamic>?)?.map((component) {
      final kindName = component['kind']?['name'] as String?;
      final comparedObjects = (component['comparedObjects'] as List<dynamic>?)
          ?.map((object) {
            if (object is Map<String, dynamic> && object.containsKey('name')) {
              return Component(name: object['name']);
            } else if (object is String) {
              return object;
            }
            return null;
          })
          .whereType<dynamic>()
          .toList();

      return Component(
        kind: kindName != null
            ? KindResponse.values.firstWhereOrNull((e) => e.name == kindName)
            : null,
        name: component['name'],
      );
    }).toList();

    final address = Address(
      formatted: addressMap?['formatted'],
      components: components,
    );

    final pointMap = map['point'];

    return GeoObject(
      metaDataProperty: GeoObjectMetaDataProperty(
        geocoderMetaData: GeocoderMetaData(address: address),
      ),
      point: pointMap != null
          ? Point(
              point: (
                lat: pointMap['latitude'] as double,
                lon: pointMap['longitude'] as double,
              ),
            )
          : null,
    );
  }
}
