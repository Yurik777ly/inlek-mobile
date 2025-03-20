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
        return TypeReceiving.delivery;
      default:
        return TypeReceiving.pickup;
    }
  }
}

extension PaymentTypeExtension on PaymentType {
  static const Map<PaymentType, String> titles = {
    PaymentType.courier: 'Курьеру',
    PaymentType.online: 'Онлайн',
  };

  String get title => titles[this] ?? 'Неизвестный способ оплаты';

  static PaymentType? fromTitle(String? title) {
    return title == titles[PaymentType.online]
        ? PaymentType.online
        : PaymentType.courier;
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
