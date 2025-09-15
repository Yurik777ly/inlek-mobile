enum LoginScreenType { login, accountExists }

enum SelectRegionScreenType { signUp, reset, main }

enum PasswordScreenType { signUp, reset }

enum ProductChipType { hit, seasonalOffer, stock, nova }

enum TypeReceiving { all, delivery, pickup }

enum PaymentType { courier, oplati, bepaid, erip, cash }

enum PharmacyProductsAvailability { partially, fully }

enum ProductsListScreenType { cart, pharmacy, order }

enum CartOrProductType { cart, product }

enum OrderStatus {
  courier, // У курьера
  readyToIssue, // Готов к выдаче
  reserved, // Зарезервирован
  canceled, // Отменен
  received, // Получен
  collected, // Собран
  processing, // В обработке
  awaitingPayment // Ожидает оплаты
}

enum DeliveryZoneType { green, yellow, none }

enum ProductSortType { popularity, priceDecrease, priceIncrease }

enum GenderType { male, female }

enum MapScreenType { product, courierDeliveryZones, cart, order }

enum ShareUrlType { product, banner, article, news, sale }
