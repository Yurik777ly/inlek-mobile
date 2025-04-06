part of 'cart_screen_bloc.dart';

abstract class CartScreenEvent extends Equatable {
  const CartScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartDataEvent extends CartScreenEvent {}

class LoadPharmaciesEvent extends CartScreenEvent {}

class AddCartEvent extends CartScreenEvent {
  final BuildContext context;
  final int productId;
  final int? count;
  const AddCartEvent(
      {required this.context, required this.productId, this.count});
}

class DeleteCartEvent extends CartScreenEvent {
  final BuildContext context;
  final int productId;
  final int? count;
  const DeleteCartEvent(
      {required this.context, required this.productId, this.count});
}

class ToggleSelectionEvent extends CartScreenEvent {
  final bool? isChecked;
  final int productId;
  const ToggleSelectionEvent(this.isChecked, this.productId);
}

class PickAllProductsEvent extends CartScreenEvent {}

class ClearProductsEvent extends CartScreenEvent {
  final BuildContext context;
  const ClearProductsEvent(this.context);
}

class DeleteProductEvent extends CartScreenEvent {
  final BuildContext context;
  final int? productId;
  const DeleteProductEvent(this.context, this.productId);
}

class DeletePromoCodeEvent extends CartScreenEvent {
  final PromocodeEntity promo;
  const DeletePromoCodeEvent({required this.promo});
}

class AddPromoCodeEvent extends CartScreenEvent {
  final String promo;
  const AddPromoCodeEvent({required this.promo});
}

class ChangePromocodeFieldEvent extends CartScreenEvent {}

class ChangeCartTypeEvent extends CartScreenEvent {
  final TypeReceiving cartType;
  const ChangeCartTypeEvent(this.cartType);
}

class ScrollUpListEvent extends CartScreenEvent {}

class ChangePaymentTypeEvent extends CartScreenEvent {
  final PaymentType paymentType;
  const ChangePaymentTypeEvent(this.paymentType);
}

class SelectPharmacy extends CartScreenEvent {
  final PharmacyEntity pharmacy;
  const SelectPharmacy(this.pharmacy);
}

class ToggleShowPharmaciesWorkingNowEvent extends CartScreenEvent {
  final bool? isShowPharmaciesWorkingNow;
  const ToggleShowPharmaciesWorkingNowEvent(this.isShowPharmaciesWorkingNow);

  @override
  List<Object?> get props => [isShowPharmaciesWorkingNow];
}

class ToggleShowPharmaciesProductsInStockEvent extends CartScreenEvent {
  final bool? isShowPharmaciesProductsInStock;
  const ToggleShowPharmaciesProductsInStockEvent(
      this.isShowPharmaciesProductsInStock);

  @override
  List<Object?> get props => [isShowPharmaciesProductsInStock];
}

class CreateOrderEvent extends CartScreenEvent {
  const CreateOrderEvent();

  @override
  List<Object?> get props => [];
}
