part of 'cart_screen_bloc.dart';

class CartScreenState extends Equatable {
  final bool isLoading;
  final String? errorText;
  final String? promocodeErrorText;
  final CartEntity? cartData;
  final Set<int> selectedProductIds;
  final bool isAllProductsChecked;
  final List<ProductPharmacyEntity> pharmacies;
  final ProductPharmacyEntity? selectedPharmacy;
  final bool isShowPharmaciesWorkingNow;
  final bool isShowPharmaciesProductsInStock;
  final List<PromocodeEntity> availablePromoCodes;
  final List<PromocodeEntity> selectedPromoCodes;
  final TypeReceiving cartType;
  final PaymentType paymentType;

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
    this.availablePromoCodes = const [],
    this.cartType = TypeReceiving.delivery,
    this.paymentType = PaymentType.courier,
  });

  CartScreenState copyWith({
    bool? isLoading,
    String? errorText,
    String? promocodeErrorText,
    CartEntity? cartData,
    Set<int>? selectedProductIds,
    bool? isAllProductsChecked,
    List<ProductPharmacyEntity>? pharmacies,
    ProductPharmacyEntity? selectedPharmacy,
    bool? isShowPharmaciesWorkingNow,
    bool? isShowPharmaciesProductsInStock,
    List<PromocodeEntity>? availablePromoCodes,
    List<PromocodeEntity>? selectedPromoCodes,
    TypeReceiving? cartType,
    PaymentType? paymentType,
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
      availablePromoCodes: availablePromoCodes ?? this.availablePromoCodes,
      cartType: cartType ?? this.cartType,
      paymentType: paymentType ?? this.paymentType,
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
        availablePromoCodes,
        cartType,
        paymentType,
      ];
}
