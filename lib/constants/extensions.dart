import 'package:inlek/constants/enums.dart';

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
    PaymentType.oplati: 'Онлайн',
    PaymentType.bepaid: 'Онлайн',
  };

  String get title => titles[this] ?? 'Неизвестный способ оплаты';

  static PaymentType? fromTitle(String? title) {
    switch (title) {
      case 'cash':
        return PaymentType.courier;
      case 'Курьеру':
        return PaymentType.courier;
      case 'bepaid':
        return PaymentType.bepaid;
      case 'oplati':
        return PaymentType.oplati;
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
    if (this == DeliveryZoneType.none) return 0;
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
