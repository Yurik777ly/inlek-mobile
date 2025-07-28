part of 'cart_screen_bloc.dart';

class CartScreenState extends Equatable {
  final bool isLoading;
  final bool isOrderCompleting;
  final String? errorText;
  final String? promocodeErrorText;
  final CartEntity? cartData;
  final Set<int> selectedProductIds;
  final bool isAllProductsChecked;
  final List<PharmacyEntity> pharmacies;
  final int? selectedPharmacyId;
  final bool isShowPharmaciesWorkingNow;
  final bool isShowPharmaciesProductsInStock;
  final List<PromocodeEntity> selectedPromoCodes;
  final TypeReceiving cartType;
  final PaymentType paymentType;
  final DeliveryZoneType deliveryZone;
  final int deliveryPayment;

  const CartScreenState({
    this.isLoading = true,
    this.isOrderCompleting = false,
    this.errorText,
    this.promocodeErrorText,
    this.cartData,
    this.selectedProductIds = const {},
    this.isAllProductsChecked = false,
    this.pharmacies = const [],
    this.selectedPharmacyId,
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
    bool? isOrderCompleting,
    String? errorText,
    String? promocodeErrorText,
    CartEntity? cartData,
    Set<int>? selectedProductIds,
    bool? isAllProductsChecked,
    List<PharmacyEntity>? pharmacies,
    int? selectedPharmacyId,
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
      isOrderCompleting: isOrderCompleting ?? this.isOrderCompleting,
      errorText: errorText,
      promocodeErrorText: promocodeErrorText,
      cartData: cartData ?? this.cartData,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      isAllProductsChecked: isAllProductsChecked ?? this.isAllProductsChecked,
      pharmacies: pharmacies ?? this.pharmacies,
      selectedPharmacyId: selectedPharmacyId ?? this.selectedPharmacyId,
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
        isOrderCompleting,
        errorText,
        promocodeErrorText,
        cartData,
        selectedProductIds,
        isAllProductsChecked,
        pharmacies,
        selectedPharmacyId,
        isShowPharmaciesWorkingNow,
        isShowPharmaciesProductsInStock,
        selectedPromoCodes,
        cartType,
        paymentType,
        deliveryZone,
        deliveryPayment,
      ];
}
