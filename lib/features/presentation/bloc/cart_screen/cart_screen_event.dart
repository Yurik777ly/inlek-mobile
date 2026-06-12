part of 'cart_screen_bloc.dart';

abstract class CartScreenEvent extends Equatable {
  const CartScreenEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends CartScreenEvent {
  const InitEvent();
}

class LoadCartDataEvent extends CartScreenEvent {
  final bool isFirstLoading;
  const LoadCartDataEvent({this.isFirstLoading = false});
}

class AddCartEvent extends CartScreenEvent {
  final BuildContext? context;
  final int productId;
  final int? count;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;
  const AddCartEvent(
      {this.context,
      required this.productId,
      this.count,
      this.onSuccess,
      this.onError});
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

class PickAllProductsEvent extends CartScreenEvent {
  final bool force;

  const PickAllProductsEvent({this.force = false});
}

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
  final int pharmacyId;
  const SelectPharmacy(this.pharmacyId);
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
  final BuildContext screenContext;
  final BuildContext? sheetContext;
  final Function()? callback;
  const CreateOrderEvent({
    required this.screenContext,
    this.sheetContext,
    this.callback,
  });

  @override
  List<Object?> get props => [sheetContext];
}

class UpdateDeliveryPriceEvent extends CartScreenEvent {
  final GeoObject? address;
  const UpdateDeliveryPriceEvent({this.address});
}

class ChangeAvailableDeliveryEvent extends CartScreenEvent {
  final CityEntity? city;
  const ChangeAvailableDeliveryEvent({this.city});
}

class UpdateLocalCartDataEvent extends CartScreenEvent {
  final int productId;
  final int quantity;
  final bool wasFirstTimeAdded;
  final bool wasCartEmpty;
  final VoidCallback? onSuccess;

  const UpdateLocalCartDataEvent({
    required this.productId,
    required this.quantity,
    required this.wasFirstTimeAdded,
    required this.wasCartEmpty,
    this.onSuccess,
  });

  @override
  List<Object?> get props =>
      [productId, quantity, wasFirstTimeAdded, wasCartEmpty];
}

class UpdateLocalCartDeleteEvent extends CartScreenEvent {
  final int productId;
  final int newQuantity;
  final bool isCartEmptyAfterRemoval;

  const UpdateLocalCartDeleteEvent({
    required this.productId,
    required this.newQuantity,
    required this.isCartEmptyAfterRemoval,
  });

  @override
  List<Object?> get props => [productId, newQuantity, isCartEmptyAfterRemoval];
}

class SetRepeatingOrderEvent extends CartScreenEvent {
  final bool isRepeatingOrder;
  const SetRepeatingOrderEvent(this.isRepeatingOrder);

  @override
  List<Object?> get props => [isRepeatingOrder];
}

class SetClearingCartEvent extends CartScreenEvent {
  final bool isClearingCart;
  const SetClearingCartEvent(this.isClearingCart);

  @override
  List<Object?> get props => [isClearingCart];
}
