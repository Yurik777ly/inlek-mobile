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
import 'package:inlek/core/error/failure.dart';
import 'package:inlek/core/params/cart_detailed_params.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/core/params/order_param.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/city_model.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';
import 'package:inlek/features/domain/entities/city_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/usecases/cart/add_cart.dart';
import 'package:inlek/features/domain/usecases/cart/clear_cart.dart';
import 'package:inlek/features/domain/usecases/cart/delete_cart.dart';
import 'package:inlek/features/domain/usecases/cart/get_cart.dart';
import 'package:inlek/features/domain/usecases/orders/create_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Timer? _addCartDebounceTimer;
  Timer? _deleteCartDebounceTimer;
  // Incrementing token for deduplicating concurrent load requests
  int _loadDataRequestId = 0;

  CartScreenBloc({
    required this.getCartUC,
    required this.addCartUC,
    required this.deleteCartUC,
    required this.clearCartUC,
    required this.createOrderUC,
    required this.sharedPreferences,
    required this.courierZoneManager,
  }) : super(CartScreenState()) {
    debugPrint('CartScreenBloc created: $hashCode');
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
    on<ChangeAvailableDeliveryEvent>(_onChangeAvailableDelivery);
    on<UpdateLocalCartDataEvent>(_onUpdateLocalCartData);
    on<UpdateLocalCartDeleteEvent>(_onUpdateLocalCartDelete);
    on<SetRepeatingOrderEvent>(_onSetRepeatingOrder);
    on<SetClearingCartEvent>(_onSetClearingCart);

    on<ScrollUpListEvent>((_, __) => controller.animateTo(0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeOut));
  }

  Future<void> _inInit(InitEvent event, Emitter<CartScreenState> emit) async {
    int? savedPharmacyId =
        sharedPreferences.getInt(SharedPreferencesKeys.pharmacyId);
    final savedAddressString =
        sharedPreferences.getString(SharedPreferencesKeys.savedAddress);
    //final savedCartTypeString =
    //    sharedPreferences.getString(SharedPreferencesKeys.cartType);

    if (savedAddressString != null) {
      try {
        selectedAddress =
            GeoObjectSerialization.fromJsonString(savedAddressString);
      } catch (_) {}
    }

    // Восстанавливаем тип корзины из SharedPreferences
    /*TypeReceiving? savedCartType;
    if (savedCartTypeString != null) {
      try {
        savedCartType = TypeReceiving.values.firstWhere(
          (type) => type.name == savedCartTypeString,
        );
      } catch (_) {
        // Если не удалось найти тип, используем значение по умолчанию
        savedCartType = null;
      }
    }*/

    emit(state.copyWith(
      selectedPharmacyId: savedPharmacyId,
      //cartType: savedCartType ?? TypeReceiving.delivery,
    ));
    add(LoadCartDataEvent(isFirstLoading: true));
  }

  Future<void> _onLoadData(
    LoadCartDataEvent event,
    Emitter<CartScreenState> emit,
  ) async {
    // Bump request id to invalidate all previous pending requests
    final int requestId = ++_loadDataRequestId;
    add(UpdateDeliveryPriceEvent());

    final failureOrCart = await getCartUC(
      CartDetailedParams(
          pharmacyId: state.cartType == TypeReceiving.pickup
              ? state.selectedPharmacyId
              : UiConstants.deliveryPharmacyId,
          promocodes:
              state.selectedPromoCodes.map((e) => e.promocode).join('|'),
          deliveryZone: state.deliveryZone),
    );

    // If a newer request was started, ignore this response
    if (requestId != _loadDataRequestId) {
      return;
    }

    failureOrCart.fold(
      (_) => emit(state.copyWith(
          isLoading: false, errorText: 'Ошибка загрузки данных')),
      (cartData) {
        emit(state.copyWith(
            isLoading: false,
            isLoadingPharmacy: false,
            isRepeatingOrder: false,
            isClearingCart: false,
            cartData: cartData,
            cartType: !state.isAvailableDelivery
                ? TypeReceiving.pickup
                : cartData.products.isEmpty
                    ? TypeReceiving.delivery
                    : null,
            errorText: null,
            isAllProductsChecked: cartData.products.isEmpty ? false : null));
        // После загрузки данных пересчитываем состояние чекбоксов
        _recalculateSelectionsAfterLoad(cartData, emit);
      },
    );
    if (requestId == 1 && event.isFirstLoading) {
      add(PickAllProductsEvent(force: true));
    }
    print('Тип корзины: ${state.cartType.title}');
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

  // Пересчитывает selectedProductIds и isAllProductsChecked на основе актуальных данных корзины
  void _recalculateSelectionsAfterLoad(
      CartEntity cartData, Emitter<CartScreenState> emit) {
    // Оставляем в selectedProductIds только те id, которые присутствуют и доступны
    final availableProductIds = cartData.products
        .where((e) => e.availability != 'absent')
        .map((e) => e.productId)
        .toSet();

    final updatedSelected = state.selectedProductIds
        .where((id) => availableProductIds.contains(id))
        .toSet();

    final updatedIsAllChecked = availableProductIds.isNotEmpty &&
        availableProductIds.every((id) => updatedSelected.contains(id));

    emit(state.copyWith(
      selectedProductIds: updatedSelected,
      isAllProductsChecked: updatedIsAllChecked,
    ));
  }

  // Функция для удаления товара с дебаунс таймером
  Future<void> _onDeleteCart(
      DeleteCartEvent event, Emitter<CartScreenState> emit) async {
    add(UpdateDeliveryPriceEvent());

    // Сбрасываем предыдущий таймер удаления, если событие повторяется
    _deleteCartDebounceTimer?.cancel();

    // Устанавливаем дебаунс таймер на 300ms
    _deleteCartDebounceTimer =
        Timer(const Duration(milliseconds: 300), () async {
      // Выполняем логику удаления товара из корзины
      ProductEntity? product = state.cartData?.products
          .firstWhereOrNull((e) => e.productId == event.productId);
      if (product == null) return;

      int newQuantity = product.availability == 'absent'
          ? 0
          : event.count ?? (product.quantity ?? 0) - 1;

      final currentProducts = state.cartData?.products ?? [];
      final updatedProducts = List<ProductEntity>.from(currentProducts);

      if (newQuantity > 0) {
        final productIndex = updatedProducts.indexOf(product);
        updatedProducts[productIndex] = product.copyWith(quantity: newQuantity);
      } else {
        updatedProducts.remove(product);
      }

      // Check if cart becomes empty after this operation
      bool isCartEmptyAfterRemoval = updatedProducts.isEmpty;

      // Выполняем API запрос БЕЗ локального обновления состояния
      final result = await deleteCartUC(CartParams(
          productId: event.productId.toString(),
          quantity: newQuantity.toString()));

      await result.fold<Future<void>>(
        (_) async {
          _handleCartUpdateError(emit, updatedProducts, product, event.context);
        },
        (_) async {
          // При успешном ответе отправляем событие для обновления локального состояния
          add(UpdateLocalCartDeleteEvent(
            productId: event.productId,
            newQuantity: newQuantity,
            isCartEmptyAfterRemoval: isCartEmptyAfterRemoval,
          ));
        },
      );
    });
  }

  // Функция для добавления товара с дебаунс таймером
  Future<void> _onAddCart(
      AddCartEvent event, Emitter<CartScreenState> emit) async {
    add(UpdateDeliveryPriceEvent());

    // Сбрасываем предыдущий таймер добавления, если событие повторяется
    _addCartDebounceTimer?.cancel();

    // Устанавливаем дебаунс таймер на 300ms
    _addCartDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final currentProducts = state.cartData?.products ?? [];
      final productIndex =
          currentProducts.indexWhere((e) => e.productId == event.productId);

      int newQuantity = 1;
      bool wasFirstTimeAdded = productIndex == -1;
      bool wasCartEmpty = currentProducts.isEmpty;

      if (!wasFirstTimeAdded) {
        ProductEntity product = currentProducts[productIndex];
        newQuantity = event.count ?? (product.quantity ?? 0) + 1;
      }

      // Выполняем API запрос БЕЗ локального обновления состояния
      final failureOrCart = await addCartUC(CartParams(
          productId: event.productId.toString(),
          quantity: newQuantity.toString()));

      await failureOrCart.fold<Future<void>>(
        (failure) async {
          // При ошибке показываем диалог
          final navigatorContext = event.context ?? UiConstants.homeContext;

          String errorMessage;
          if (failure is OutOfStockFailure) {
            errorMessage = 'Больше нет в наличии';
          } else {
            errorMessage = 'Ошибка добавления товара в корзину';
          }

          if (navigatorContext != null) {
            Utils.showCustomDialog(
              screenContext: navigatorContext,
              text: errorMessage,
              action: (ctx) {
                if (Navigator.canPop(ctx)) Navigator.of(ctx).pop();
              },
            );
          } else {
            debugPrint("Не удалось показать диалог: context null");
          }

          // Вызываем колбэк при ошибке
          event.onError?.call();
        },
        (_) async {
          // При успешном ответе отправляем событие для обновления локального состояния
          add(UpdateLocalCartDataEvent(
            productId: event.productId,
            quantity: newQuantity,
            wasFirstTimeAdded: wasFirstTimeAdded,
            wasCartEmpty: wasCartEmpty,
            onSuccess: event.onSuccess,
          ));
        },
      );
    });
  }

  Future<void> _onClearCart(
      ClearProductsEvent event, Emitter<CartScreenState> emit) async {
    // Устанавливаем флаг очистки корзины
    emit(state.copyWith(isClearingCart: true));
    
    add(UpdateDeliveryPriceEvent());
    final failureOrCart = await clearCartUC();
    failureOrCart.fold(
      (_) {
        // Сбрасываем флаг при ошибке
        emit(state.copyWith(isClearingCart: false));
        Utils.showCustomDialog(
            screenContext: event.context,
            text: 'Ошибка очистки корзины',
            action: (context) => Navigator.of(context).pop());
      },
      (_) {
        // Set cartType to delivery when clearing cart
        /*emit(state.copyWith(
            cartType:
                state.isAvailableDelivery ? TypeReceiving.delivery : null));*/
        add(LoadCartDataEvent(isFirstLoading: true));
      },
    );
  }

  void _onPickAllProducts(
      PickAllProductsEvent event, Emitter<CartScreenState> emit) {
    add(UpdateDeliveryPriceEvent());
    Set<int> selectedProductIds = state.isAllProductsChecked && !event.force
        ? {}
        : (state.cartData?.products ?? [])
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
    // Сохраняем тип корзины в SharedPreferences
    /* await sharedPreferences.setString(
        SharedPreferencesKeys.cartType, event.cartType.name);*/

    // Create a new list of products with isLoading set to true
    final updatedProducts = state.cartData?.products
        .map((product) => product.copyWith(isLoading: true))
        .toList();

    // Update the state with the new products list
    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        cartType: event.cartType,
        isLoadingPharmacy: true));

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
    // Create a new list of products with isLoading set to true
    final updatedProducts = state.cartData?.products
        .map((product) => product.copyWith(isLoading: true))
        .toList();

    // Update the state with the new products list
    emit(state.copyWith(
        selectedPharmacyId: event.pharmacyId,
        cartData: state.cartData?.copyWith(products: updatedProducts),
        isLoadingPharmacy: true));

    if (event.pharmacyId != -1) {
      sharedPreferences.setInt(
          SharedPreferencesKeys.pharmacyId, event.pharmacyId);
    }

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
          payment: state.paymentType == PaymentType.courier
              ? 'cash'
              : state.paymentType.name,
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
          pharmacyId: state.selectedPharmacyId ?? 0,
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
        event.callback?.call();
        // сохраняем адрес при успешном оформлении доставки
        if (state.cartType == TypeReceiving.delivery) {
          sharedPreferences.setString(SharedPreferencesKeys.savedAddress,
              json.encode(selectedAddress?.toJsonString()));

          sharedPreferences.setString(
              SharedPreferencesKeys.savedApartment, flatController.text);
          sharedPreferences.setString(
              SharedPreferencesKeys.savedEntrance, entranceController.text);
          sharedPreferences.setString(
              SharedPreferencesKeys.savedFloor, floorController.text);
          sharedPreferences.setString(
              SharedPreferencesKeys.savedIntercom, doorPhoneController.text);
        }

        /*if (order?.link != null) {
          if (await canLaunchUrl(Uri.parse(order!.link!))) {
            await launchUrl(Uri.parse(order.link!),
                mode: LaunchMode.externalApplication);
          } else {
            throw "Не удалось открыть ${order.link!}";
          }
        }*/
        BottomSheetManager.showThanksForOrderSheet(event.screenContext, order!);
      },
    );
    // скрываем лоадер на кнопке
    emit(state.copyWith(isOrderCompleting: false, selectedPromoCodes: []));
  }

  Future _onChangeAvailableDelivery(
      ChangeAvailableDeliveryEvent event, Emitter<CartScreenState> emit) async {
    CityEntity? city = event.city;
    city ??= (() {
      try {
        final json = sharedPreferences.getString(SharedPreferencesKeys.city);
        return json == null ? null : CityModel.fromJson(jsonDecode(json));
      } catch (_) {
        return null;
      }
    })();

    // удаляем аптеку из памяти
    await sharedPreferences.remove(SharedPreferencesKeys.pharmacyId);

    final updatedProducts = state.cartData?.products
        .map((product) => product.copyWith(isLoading: true))
        .toList();

    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        isAvailableDelivery: city?.isDeliveryAvailable,
        cartType: city?.isDeliveryAvailable == true
            ? state.cartType
            : TypeReceiving.pickup,
        selectedPharmacyId: -1,
        isLoadingPharmacy: true));

    add(LoadCartDataEvent(isFirstLoading: true));
  }

  void _onUpdateLocalCartData(
      UpdateLocalCartDataEvent event, Emitter<CartScreenState> emit) {
    final currentProducts = state.cartData?.products ?? [];
    final productIndex =
        currentProducts.indexWhere((e) => e.productId == event.productId);

    final updatedProducts = List<ProductEntity>.from(currentProducts);

    if (!event.wasFirstTimeAdded && productIndex != -1) {
      ProductEntity product = updatedProducts[productIndex];
      updatedProducts[productIndex] =
          product.copyWith(quantity: event.quantity);
    } else {
      updatedProducts.add(
          ProductEntity(productId: event.productId, quantity: event.quantity));
    }

    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        isLoading: false));

    // If cart was empty and this is the first product, set cartType to delivery
    if (event.wasCartEmpty && event.wasFirstTimeAdded) {
      emit(state.copyWith(
          cartType: state.isAvailableDelivery ? TypeReceiving.delivery : null));
    }

    // Загружаем актуальные данные корзины для синхронизации
    if (!isClosed) {
      add(LoadCartDataEvent());
    }

    // Вызываем колбэк при успешном добавлении
    event.onSuccess?.call();
  }

  void _onUpdateLocalCartDelete(
      UpdateLocalCartDeleteEvent event, Emitter<CartScreenState> emit) {
    final currentProducts = state.cartData?.products ?? [];
    final updatedProducts = List<ProductEntity>.from(currentProducts);
    Set<int> updatedSelectedProductIds = Set.from(state.selectedProductIds);

    final productIndex =
        updatedProducts.indexWhere((e) => e.productId == event.productId);

    if (productIndex != -1) {
      if (event.newQuantity > 0) {
        final product = updatedProducts[productIndex];
        updatedProducts[productIndex] =
            product.copyWith(quantity: event.newQuantity);
      } else {
        updatedProducts.removeAt(productIndex);
        updatedSelectedProductIds.remove(event.productId);
      }
    }

    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        selectedProductIds: updatedSelectedProductIds,
        cartType: event.isCartEmptyAfterRemoval && state.isAvailableDelivery
            ? TypeReceiving.delivery
            : state.cartType));

    // Загружаем актуальные данные корзины для синхронизации
    if (!isClosed) {
      add(LoadCartDataEvent());
    }
  }

  void _onSetRepeatingOrder(
      SetRepeatingOrderEvent event, Emitter<CartScreenState> emit) {
    emit(state.copyWith(isRepeatingOrder: event.isRepeatingOrder));
  }

  void _onSetClearingCart(
      SetClearingCartEvent event, Emitter<CartScreenState> emit) {
    emit(state.copyWith(isClearingCart: event.isClearingCart));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _addCartDebounceTimer?.cancel();
    _deleteCartDebounceTimer?.cancel();
    controller.dispose();
    fNameController.dispose();
    sNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    streetHomeController.dispose();
    entranceController.dispose();
    floorController.dispose();
    flatController.dispose();
    doorPhoneController.dispose();
    commentController.dispose();
    promocodeController.dispose();
    return super.close();
  }
}
