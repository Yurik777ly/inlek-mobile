part of 'cart_screen_bloc.dart';

class CartScreenState extends Equatable {
  final bool isLoading;
  final String? errorText;
  final String? promocodeErrorText;
  final CartEntity? cartData;
  final Set<int> selectedProductIds;
  final bool isAllProductsChecked;
  final List<PharmacyEntity> pharmacies;
  final PharmacyEntity? selectedPharmacy;
  final bool isShowPharmaciesWorkingNow;
  final bool isShowPharmaciesProductsInStock;

  final List<PromocodeEntity> selectedPromoCodes;
  final TypeReceiving cartType;
  final PaymentType paymentType;
  final DeliveryZoneType deliveryZone;
  final int deliveryPayment;

  const CartScreenState({
    this.isLoading = true,
    this.errorText,
    this.promocodeErrorText,
    this.cartData,
    this.selectedProductIds = const {},
    this.isAllProductsChecked = false,
    this.pharmacies = const [],
    this.selectedPharmacy,
    this.isShowPharmaciesWorkingNow = false,
    this.isShowPharmaciesProductsInStock = false,
    this.selectedPromoCodes = const [],
    this.cartType = TypeReceiving.delivery,
    this.paymentType = PaymentType.courier,
    this.deliveryZone = DeliveryZoneType.none,
    this.deliveryPayment = 0,
  });

  CartScreenState copyWith({
    bool? isLoading,
    String? errorText,
    String? promocodeErrorText,
    CartEntity? cartData,
    Set<int>? selectedProductIds,
    bool? isAllProductsChecked,
    List<PharmacyEntity>? pharmacies,
    PharmacyEntity? selectedPharmacy,
    bool? isShowPharmaciesWorkingNow,
    bool? isShowPharmaciesProductsInStock,
    List<PromocodeEntity>? selectedPromoCodes,
    TypeReceiving? cartType,
    PaymentType? paymentType,
    DeliveryZoneType? deliveryZone,
    int? deliveryPayment,
    GeoObject? address,
  }) {
    return CartScreenState(
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText,
      promocodeErrorText: promocodeErrorText,
      cartData: cartData ?? this.cartData,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      isAllProductsChecked: isAllProductsChecked ?? this.isAllProductsChecked,
      pharmacies: pharmacies ?? this.pharmacies,
      selectedPharmacy: selectedPharmacy ?? this.selectedPharmacy,
      isShowPharmaciesWorkingNow:
          isShowPharmaciesWorkingNow ?? this.isShowPharmaciesWorkingNow,
      isShowPharmaciesProductsInStock: isShowPharmaciesProductsInStock ??
          this.isShowPharmaciesProductsInStock,
      selectedPromoCodes: selectedPromoCodes ?? this.selectedPromoCodes,
      cartType: cartType ?? this.cartType,
      paymentType: paymentType ?? this.paymentType,
      deliveryZone: deliveryZone ?? this.deliveryZone,
      deliveryPayment: deliveryPayment ?? this.deliveryPayment,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorText,
        promocodeErrorText,
        cartData,
        selectedProductIds,
        isAllProductsChecked,
        pharmacies,
        selectedPharmacy,
        isShowPharmaciesWorkingNow,
        isShowPharmaciesProductsInStock,
        selectedPromoCodes,
        cartType,
        paymentType,
        deliveryZone,
        deliveryPayment,
      ];
}
