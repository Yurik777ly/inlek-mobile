import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/core/courier_zone_manager.dart';
import 'package:inlek/core/params/cart_detailed_params.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/core/params/order_param.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/cart_pharmacies_model.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/usecases/cart/add_cart.dart';
import 'package:inlek/features/domain/usecases/cart/clear_cart.dart';
import 'package:inlek/features/domain/usecases/cart/delete_cart.dart';
import 'package:inlek/features/domain/usecases/cart/get_cart.dart';
import 'package:inlek/features/domain/usecases/orders/create_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

part 'cart_screen_event.dart';
part 'cart_screen_state.dart';

class CartScreenBloc extends Bloc<CartScreenEvent, CartScreenState> {
  final GetCartUC getCartUC;
  final AddCartUC addCartUC;
  final DeleteCartUC deleteCartUC;
  final ClearCartUC clearCartUC;
  final CreateOrderUC createOrderUC;
  final CourierZoneManager courierZoneManager;

  final SharedPreferences sharedPreferences;

  final ScrollController controller = ScrollController();
  final TextEditingController fNameController = TextEditingController(text: '');
  final TextEditingController sNameController = TextEditingController(text: '');
  final TextEditingController phoneController = TextEditingController(text: '');
  final TextEditingController emailController = TextEditingController(text: '');
  final TextEditingController cityController = TextEditingController(text: '');
  final TextEditingController streetHomeController =
      TextEditingController(text: '');
  final TextEditingController entranceController =
      TextEditingController(text: '');
  final TextEditingController floorController = TextEditingController(text: '');
  final TextEditingController flatController = TextEditingController(text: '');
  final TextEditingController doorPhoneController =
      TextEditingController(text: '');
  final TextEditingController commentController =
      TextEditingController(text: '');

  final TextEditingController promocodeController = TextEditingController();

  GeoObject? selectedAddress;

  Timer? _debounceTimer;
  Timer? _refreshCartTimer;

  CartScreenBloc({
    required this.getCartUC,
    required this.addCartUC,
    required this.deleteCartUC,
    required this.clearCartUC,
    required this.createOrderUC,
    required this.sharedPreferences,
    required this.courierZoneManager,
  }) : super(CartScreenState()) {
    on<InitEvent>(_inInit);
    on<LoadCartDataEvent>(_onLoadData);
    on<AddCartEvent>(_onAddCart);
    on<DeleteCartEvent>(_onDeleteCart);
    on<ClearProductsEvent>(_onClearCart);
    on<ToggleSelectionEvent>(_onToggleSelection);
    on<ToggleShowPharmaciesWorkingNowEvent>(_toggleShowPharmaciesWorkingNow);
    on<ToggleShowPharmaciesProductsInStockEvent>(
        _toggleShowPharmaciesProductsInStock);
    on<PickAllProductsEvent>(_onPickAllProducts);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<AddPromoCodeEvent>(_onAddPromoCode);
    on<DeletePromoCodeEvent>(_onDeletePromoCode);
    on<ChangePromocodeFieldEvent>(_onChangePromocodeField);
    on<ChangeCartTypeEvent>(_onChangeCartType);
    on<ChangePaymentTypeEvent>(_onChangePaymentType);
    on<SelectPharmacy>(_onSelectPharmacy);
    on<CreateOrderEvent>(_onCreateOrder);
    on<UpdateDeliveryPriceEvent>(_onUpdateDeliveryPrice);

    on<ScrollUpListEvent>((_, __) => controller.animateTo(0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeOut));
  }

  Future<void> _inInit(InitEvent event, Emitter<CartScreenState> emit) async {
    CartPharmacyEntity? savedPharmacy;
    final savedPharmacyJson =
        sharedPreferences.getString(SharedPreferencesKeys.pharmacy);
    if (savedPharmacyJson != null) {
      savedPharmacy =
          CartPharmacyModel.fromJson(json.decode(savedPharmacyJson));

      emit(state.copyWith(selectedPharmacy: savedPharmacy));
    }
    add(LoadCartDataEvent(isFirstLoading: true));
  }

  Future<void> _onLoadData(
    LoadCartDataEvent event,
    Emitter<CartScreenState> emit,
  ) async {
    add(UpdateDeliveryPriceEvent());

    final failureOrCart = await getCartUC(
      CartDetailedParams(
          pharmacyId: state.cartType == TypeReceiving.pickup
              ? state.selectedPharmacy?.pharmacyId
              : null,
          promocodes:
              state.selectedPromoCodes.map((e) => e.promocode).join('|'),
          deliveryZone: state.deliveryZone),
    );

    failureOrCart.fold(
      (_) => emit(state.copyWith(
          isLoading: false, errorText: 'Ошибка загрузки данных')),
      (cartData) {
        final oldProducts = state.cartData?.products ?? [];
        final newProducts = cartData.products ?? [];

        final fixedNewProducts = newProducts.map((product) {
          if (product.stockCount != null &&
              product.quantity != null &&
              product.quantity! > product.stockCount!) {
            return product.copyWith(
                quantity: product.stockCount, availability: 'full');
          }
          return product;
        }).toList();

        final mergedProducts = oldProducts.map((oldProduct) {
          final updated = fixedNewProducts.firstWhereOrNull(
            (newProduct) => newProduct.productId == oldProduct.productId,
          );

          ProductEntity resultProduct;

          if (oldProduct.isLoading && updated != null) {
            resultProduct = updated;
          } else {
            resultProduct = oldProduct;
          }

          return resultProduct;
        }).toList();

        // If the cart is empty, set cartType to delivery
        if (fixedNewProducts.isEmpty &&
            state.cartType != TypeReceiving.delivery) {
          emit(state.copyWith(
            isLoading: false,
            cartType: TypeReceiving.delivery,
            cartData: cartData.copyWith(products: []),
            errorText: null,
          ));
        } else {
          emit(state.copyWith(
              isLoading: false,
              cartData: cartData.copyWith(
                products:
                    event.isFirstLoading ? fixedNewProducts : mergedProducts,
              ),
              errorText: null));
        }
      },
    );

    add(PickAllProductsEvent(force: true));
  }

  void _toggleShowPharmaciesWorkingNow(
      ToggleShowPharmaciesWorkingNowEvent event,
      Emitter<CartScreenState> emit) {
    emit(state.copyWith(
        isShowPharmaciesWorkingNow: event.isShowPharmaciesWorkingNow));
  }

  void _toggleShowPharmaciesProductsInStock(
      ToggleShowPharmaciesProductsInStockEvent event,
      Emitter<CartScreenState> emit) {
    emit(state.copyWith(
        isShowPharmaciesProductsInStock:
            event.isShowPharmaciesProductsInStock));
  }

  void _onToggleSelection(
      ToggleSelectionEvent event, Emitter<CartScreenState> emit) {
    add(UpdateDeliveryPriceEvent());
    final selectedProductIds = Set<int>.from(state.selectedProductIds);
    event.isChecked == true
        ? selectedProductIds.add(event.productId)
        : selectedProductIds.remove(event.productId);
    emit(state.copyWith(
        selectedProductIds: selectedProductIds,
        isAllProductsChecked: _isAllProductsChecked(selectedProductIds)));
  }

  bool _isAllProductsChecked(Set<int> selectedProductIds) {
    return state.cartData?.products
            .where((e) => e.availability != 'absent')
            .every((e) => selectedProductIds.contains(e.productId)) ??
        false;
  }

  void _handleCartUpdateFailure(
      Emitter<CartScreenState> emit,
      List<ProductEntity> updatedProducts,
      BuildContext? context,
      String errorMessage) {
    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        isLoading: false));
    Utils.showCustomDialog(
        screenContext: context ?? UiConstants.homeContext!,
        text: errorMessage,
        action: (context) => Navigator.of(context).pop());
  }

  // Функция для удаления товара с задержкой
  Future<void> _onDeleteCart(
      DeleteCartEvent event, Emitter<CartScreenState> emit) async {
    add(UpdateDeliveryPriceEvent());
    // Эмитируем текущее состояние, чтобы UI обновился
    // emit(state.copyWith(isLoading: true));

    // Ожидаем 2 секунды, прежде чем выполнить запрос, но сбрасываем таймер, если событие повторяется
    _debounceTimer
        ?.cancel(); // Сбрасываем предыдущий таймер, если событие повторяется

    // Выполняем логику удаления товара из корзины
    ProductEntity? product = state.cartData?.products
        .firstWhereOrNull((e) => e.productId == event.productId);
    if (product == null) return;

    int newQuantity = product.availability == 'absent'
        ? 0
        : event.count ?? (product.quantity ?? 0) - 1;
    List<ProductEntity> updatedProducts =
        List.from(state.cartData?.products ?? []);
    Set<int> updatedSelectedProductIds = Set.from(state.selectedProductIds);

    bool wasLastProductRemoved = false;

    if (newQuantity > 0) {
      updatedProducts[updatedProducts.indexOf(product)] =
          product.copyWith(quantity: newQuantity);
    } else {
      updatedProducts.remove(product);
      updatedSelectedProductIds.remove(product.productId);
      wasLastProductRemoved = true;
    }

    // Check if cart becomes empty after this operation
    bool isCartEmptyAfterRemoval = updatedProducts.isEmpty;

    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        selectedProductIds: updatedSelectedProductIds,
        cartType:
            isCartEmptyAfterRemoval ? TypeReceiving.delivery : state.cartType));

    _debounceTimer = Timer(
        Duration(milliseconds: wasLastProductRemoved ? 0 : 300), () async {
      final result = await deleteCartUC(CartParams(
          productId: event.productId.toString(),
          quantity: newQuantity.toString()));
      result.fold(
        (_) => _handleCartUpdateError(
            emit, updatedProducts, product, event.context),
        (_) {
          //if (wasLastProductRemoved) {
          //  add(LoadCartDataEvent()); // Загружаем корзину только если товар был полностью удален
          //}
        },
      );
    });
  }

  // Функция для добавления товара с задержкой
  Future<void> _onAddCart(
      AddCartEvent event, Emitter<CartScreenState> emit) async {
    add(UpdateDeliveryPriceEvent());
    // Эмитируем текущее состояние, чтобы UI обновился
    //emit(state.copyWith(isLoading: true));

    // Ожидаем 2 секунды, прежде чем выполнить запрос, но сбрасываем таймер, если событие повторяется
    _debounceTimer
        ?.cancel(); // Сбрасываем предыдущий таймер, если событие повторяется

    int newQuantity = 1;

    final updatedProducts =
        List<ProductEntity>.from(state.cartData?.products ?? []);
    final productIndex =
        updatedProducts.indexWhere((e) => e.productId == event.productId);

    bool wasFirstTimeAdded = productIndex == -1; // Товар отсутствовал в корзине
    bool wasCartEmpty =
        (state.cartData?.products ?? []).isEmpty; // Корзина была пустая

    if (!wasFirstTimeAdded) {
      ProductEntity product = updatedProducts[productIndex];
      newQuantity = event.count ?? (product.quantity ?? 0) + 1;
      updatedProducts[productIndex] = product.copyWith(quantity: newQuantity);
    } else {
      updatedProducts.add(ProductEntity(
          productId: event.productId, quantity: newQuantity, isLoading: true));
    }

    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        isLoading: false));

    // If cart was empty and this is the first product, set cartType to delivery
    if (wasCartEmpty && wasFirstTimeAdded) {
      emit(state.copyWith(cartType: TypeReceiving.delivery));
    }

    _debounceTimer = Timer(
      Duration(milliseconds: wasFirstTimeAdded ? 0 : 300),
      () async {
        final failureOrCart = await addCartUC(CartParams(
            productId: event.productId.toString(),
            quantity: newQuantity.toString()));
        failureOrCart.fold(
          (_) => _handleCartUpdateFailure(emit, updatedProducts, event.context,
              'Ошибка добавления товара в корзину'),
          (_) async {
            if (wasFirstTimeAdded) {
              // Перезапускаем отложенное обновление корзины
              _refreshCartTimer?.cancel();
              _refreshCartTimer = Timer(
                Duration(seconds: 2),
                () {
                  if (!isClosed) {
                    add(LoadCartDataEvent());
                  }
                },
              );
            }
          },
        );
      },
    );

    add(PickAllProductsEvent(force: true));
  }

  Future<void> _onClearCart(
      ClearProductsEvent event, Emitter<CartScreenState> emit) async {
    add(UpdateDeliveryPriceEvent());
    final failureOrCart = await clearCartUC();
    failureOrCart.fold(
      (_) => Utils.showCustomDialog(
          screenContext: event.context,
          text: 'Ошибка очистки корзины',
          action: (context) => Navigator.of(context).pop()),
      (_) {
        // Set cartType to delivery when clearing cart
        emit(state.copyWith(cartType: TypeReceiving.delivery));
        add(LoadCartDataEvent(isFirstLoading: true));
      },
    );
  }

  void _onPickAllProducts(
      PickAllProductsEvent event, Emitter<CartScreenState> emit) {
    add(UpdateDeliveryPriceEvent());
    Set<int> selectedProductIds = state.isAllProductsChecked && !event.force
        ? {}
        : state.cartData!.products
            .where((e) => e.availability != 'absent')
            .map((e) => e.productId)
            .toSet();
    emit(state.copyWith(
        selectedProductIds: selectedProductIds,
        isAllProductsChecked:
            event.force ? true : !state.isAllProductsChecked));
  }

  void _handleCartUpdateError(
      Emitter<CartScreenState> emit,
      List<ProductEntity> updatedProducts,
      ProductEntity? product,
      BuildContext context) {
    if (product != null) {
      updatedProducts[updatedProducts.indexOf(product)] =
          product.copyWith(quantity: product.quantity);
    } else {
      updatedProducts.removeWhere((e) => e.productId == product?.productId);
    }
    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts)));
    Utils.showCustomDialog(
        screenContext: context,
        text: 'Ошибка обновления корзины',
        action: (context) => Navigator.of(context).pop());
  }

  void _onDeleteProduct(
      DeleteProductEvent event, Emitter<CartScreenState> emit) async {
    add(UpdateDeliveryPriceEvent());
    ProductEntity? product = state.cartData?.products
        .firstWhereOrNull((e) => e.productId == event.productId);
    if (product != null) {
      add(DeleteCartEvent(
          context: event.context,
          productId: product.productId,
          count: product.quantity));
    } else {
      //add(LoadCartDataEvent());
    }
  }

  void _onAddPromoCode(AddPromoCodeEvent event, Emitter<CartScreenState> emit) {
    PromocodeEntity? promo = state.cartData?.allPromocodes.firstWhereOrNull(
        (promo) =>
            promo.promocode.toLowerCase().trim() ==
            event.promo.toLowerCase().trim());
    if (promo == null) {
      emit(state.copyWith(promocodeErrorText: 'Невозможно применить промокод'));
    } else {
      final promocodeAlreadyUsed =
          state.cartData!.enteredPromocodes.contains(promo.promocode);
      if (promocodeAlreadyUsed) {
        emit(state.copyWith(promocodeErrorText: 'Промокод уже применен'));
      } else {
        promocodeController.clear();
        emit(state.copyWith(
            selectedPromoCodes: [...state.selectedPromoCodes, promo]));
        add(LoadCartDataEvent(isFirstLoading: true));
      }
    }
  }

  void _onChangePromocodeField(
      ChangePromocodeFieldEvent event, Emitter<CartScreenState> emit) {
    if (state.promocodeErrorText != null) {
      emit(state.copyWith(promocodeErrorText: null));
    }
  }

  void _onDeletePromoCode(
      DeletePromoCodeEvent event, Emitter<CartScreenState> emit) {
    emit(state.copyWith(
      selectedPromoCodes: List.from(state.selectedPromoCodes)
        ..remove(event.promo),
    ));
    add(LoadCartDataEvent(isFirstLoading: true));
  }

  void _onChangeCartType(
      ChangeCartTypeEvent event, Emitter<CartScreenState> emit) async {
    // Create a new list of products with isLoading set to true
    final updatedProducts = state.cartData?.products
        .map((product) => product.copyWith(isLoading: true))
        .toList();

    // Update the state with the new products list
    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        cartType: event.cartType));

    if ((updatedProducts ?? []).isNotEmpty) {
      add(LoadCartDataEvent(isFirstLoading: true));
    }
  }

  void _onChangePaymentType(
      ChangePaymentTypeEvent event, Emitter<CartScreenState> emit) async {
    emit(state.copyWith(paymentType: event.paymentType));
  }

  Future _onSelectPharmacy(
      SelectPharmacy event, Emitter<CartScreenState> emit) async {
    // сохраняем объект аптеки в prefs
    await sharedPreferences.setString(SharedPreferencesKeys.pharmacy,
        json.encode((event.pharmacy as CartPharmacyModel).toJson()));

    // Create a new list of products with isLoading set to true
    final updatedProducts = state.cartData?.products
        .map((product) => product.copyWith(isLoading: true))
        .toList();

    // Update the state with the new products list
    emit(state.copyWith(
      selectedPharmacy: event.pharmacy,
      cartData: state.cartData?.copyWith(products: updatedProducts),
    ));

    add(LoadCartDataEvent(isFirstLoading: true));
  }

  void _onUpdateDeliveryPrice(
      UpdateDeliveryPriceEvent event, Emitter<CartScreenState> emit) async {
    DeliveryZoneType deliveryZone = courierZoneManager.getZoneTypeByCoordinates(
        event.address?.point ?? selectedAddress?.point);
    emit(state.copyWith(isLoading: true));
    emit(state.copyWith(deliveryZone: deliveryZone, isLoading: false));

    final selectedProducts = state.cartData?.products
            .where((product) =>
                state.selectedProductIds.contains(product.productId))
            .toList() ??
        [];

    // Считаем сумму всех товаров
    final productsTotal = selectedProducts.fold<double>(
      0,
      (sum, product) => sum + (product.price ?? 0) * (product.quantity ?? 1),
    );

    // Итоговая сумма
    final totalPrice = productsTotal;
    // Получаем сообщение с ценой для зоны
    final priceMessage = deliveryZone.getPrice(totalPrice);

    emit(state.copyWith(deliveryPayment: priceMessage, address: event.address));
  }

  Future<void> _onCreateOrder(
      CreateOrderEvent event, Emitter<CartScreenState> emit) async {
    // показываем лоадер на кнопке
    emit(state.copyWith(isOrderCompleting: true));

    OrderParam params;
    if (state.cartType == TypeReceiving.delivery) {
      params = OrderParam(
          ids: state.selectedProductIds,
          promocodes: state.selectedPromoCodes.map((e) => e.promocode).toList(),
          pharmacyId: 0,
          delivery: 'delivery',
          payment: state.paymentType == PaymentType.bepaid
              ? 'bepaid'
              : state.paymentType == PaymentType.oplati
                  ? 'oplati'
                  : 'cash',
          lastName: fNameController.text,
          firstName: sNameController.text,
          email: emailController.text,
          phone: Utils.formatPhoneNumber(phoneController.text),
          city: cityController.text,
          address: streetHomeController.text,
          entrance: entranceController.text,
          apartment: flatController.text,
          floor: floorController.text,
          intercom: doorPhoneController.text,
          comment: commentController.text,
          deliveryZone: state.deliveryZone);
    } else {
      params = OrderParam(
          ids: state.selectedProductIds,
          promocodes: state.selectedPromoCodes.map((e) => e.promocode).toList(),
          pharmacyId: state.selectedPharmacy?.pharmacyId ?? 0,
          delivery: 'self',
          payment: 'cash',
          lastName: fNameController.text,
          firstName: sNameController.text,
          email: emailController.text,
          phone: Utils.formatPhoneNumber(phoneController.text),
          city: cityController.text,
          address: streetHomeController.text,
          comment: commentController.text);
    }
    final failureOrCart = await createOrderUC(params);

    add(LoadCartDataEvent(isFirstLoading: true));

    failureOrCart.fold(
      (_) => emit(state.copyWith(
          isLoading: false, errorText: 'Ошибка создания заказа')),
      (order) async {
        if (order?.link != null) {
          await BottomSheetManager.showThanksForOrderSheet(
              event.screenContext, order!);
          if (await canLaunchUrl(Uri.parse(order.link!))) {
            await launchUrl(Uri.parse(order.link!),
                mode: LaunchMode.externalApplication);
          } else {
            throw "Не удалось открыть ${order.link!}";
          }
        }
      },
    );
    // скрываем лоадер на кнопке
    emit(state.copyWith(isOrderCompleting: false));
  }
}
