import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/core/params/order_param.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/usecases/cart/add_cart.dart';
import 'package:inlek/features/domain/usecases/cart/clear_cart.dart';
import 'package:inlek/features/domain/usecases/cart/delete_cart.dart';
import 'package:inlek/features/domain/usecases/cart/get_cart.dart';
import 'package:inlek/features/domain/usecases/content/get_pharmacies.dart';
import 'package:inlek/features/domain/usecases/orders/create_order.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

part 'cart_screen_event.dart';
part 'cart_screen_state.dart';

class CartScreenBloc extends Bloc<CartScreenEvent, CartScreenState> {
  final GetCartUC getCartUC;
  final AddCartUC addCartUC;
  final DeleteCartUC deleteCartUC;
  final ClearCartUC clearCartUC;
  final CreateOrderUC createOrderUC;
  final GetPharmaciesUC getPharmaciesUC;
  final SharedPreferences sharedPreferences;

  final ScrollController controller = ScrollController();
  final TextEditingController fNameController =
      TextEditingController(text: 'Иван');
  final TextEditingController sNameController =
      TextEditingController(text: 'Иванов');
  final TextEditingController phoneController =
      TextEditingController(text: '+375 (25) 222-33-49');
  final TextEditingController emailController =
      TextEditingController(text: 'penkin.333@mail.ru');
  final TextEditingController cityController =
      TextEditingController(text: 'Минск');
  final TextEditingController streetHomeController =
      TextEditingController(text: 'Заславская улица, 29, Минск, 220004');
  final TextEditingController entranceController =
      TextEditingController(text: '5');
  final TextEditingController floorController =
      TextEditingController(text: '20');
  final TextEditingController flatController =
      TextEditingController(text: '1029');
  final TextEditingController doorPhoneController =
      TextEditingController(text: '1029');
  final TextEditingController commentController =
      TextEditingController(text: 'Оставить возле двери');

  final TextEditingController promocodeController = TextEditingController();

  Timer? _debounceTimer;

  CartScreenBloc({
    required this.getCartUC,
    required this.addCartUC,
    required this.deleteCartUC,
    required this.clearCartUC,
    required this.createOrderUC,
    required this.getPharmaciesUC,
    required this.sharedPreferences,
  }) : super(CartScreenState()) {
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
    on<LoadPharmaciesEvent>(_onLoadPharmacies);
    on<ScrollUpListEvent>((_, __) => controller.animateTo(0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeOut));
  }

  Future<void> _onLoadData(
      LoadCartDataEvent event, Emitter<CartScreenState> emit) async {
    final failureOrCart = await getCartUC();

    failureOrCart.fold(
      (_) => emit(state.copyWith(
          isLoading: false, errorText: 'Ошибка загрузки данных')),
      (cartData) {
        // Сохранение старых значений quantity
        final oldQuantities = {
          for (var product in state.cartData?.products ?? [])
            product.productId: product.quantity
        };

        // Обновляем список продуктов, подставляя старые quantity
        final updatedProducts = (cartData.products ?? []).map((product) {
          return product.copyWith(
              quantity: oldQuantities[product.productId] ?? product.quantity);
        }).toList();

        // Обновляем список доступных промокодов
        List<PromocodeEntity> availablePromoCodes = updatedProducts
            .expand((product) => product.promocodesJson ?? [])
            .cast<PromocodeEntity>()
            .toList();

        // Фильтруем выбранные промокоды
        List<PromocodeEntity> updatedSelectedPromoCodes = state
            .selectedPromoCodes
            .where((selectedPromo) => availablePromoCodes.any(
                (availablePromo) =>
                    availablePromo.promotionId == selectedPromo.promotionId))
            .toList();

        emit(state.copyWith(
            isLoading: false,
            cartData: cartData.copyWith(products: updatedProducts),
            errorText: null,
            availablePromoCodes: availablePromoCodes,
            selectedPromoCodes: updatedSelectedPromoCodes));
      },
    );
  }

  Future<void> _onLoadPharmacies(
      LoadPharmaciesEvent event, Emitter<CartScreenState> emit) async {
    String city = sharedPreferences.getString(SharedPreferencesKeys.city) ?? '';
    final failureOrLoads = await getPharmaciesUC(city);

    failureOrLoads.fold(
      (_) {},
      (pharmacies) => emit(
        state.copyWith(pharmacies: pharmacies),
      ),
    );
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
            ?.every((e) => selectedProductIds.contains(e.productId)) ??
        false;
  }

  void _handleCartUpdateFailure(
      Emitter<CartScreenState> emit,
      List<ProductEntity> updatedProducts,
      BuildContext context,
      String errorMessage) {
    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        isLoading: false));
    Utils.showCustomDialog(
        screenContext: context,
        text: errorMessage,
        action: (context) => Navigator.of(context).pop());
  }

  // Функция для удаления товара с задержкой
  Future<void> _onDeleteCart(
      DeleteCartEvent event, Emitter<CartScreenState> emit) async {
    // Эмитируем текущее состояние, чтобы UI обновился
    emit(state.copyWith(isLoading: true));

    // Ожидаем 2 секунды, прежде чем выполнить запрос, но сбрасываем таймер, если событие повторяется
    _debounceTimer
        ?.cancel(); // Сбрасываем предыдущий таймер, если событие повторяется

    // Выполняем логику удаления товара из корзины
    ProductEntity? product = state.cartData?.products
        ?.firstWhereOrNull((e) => e.productId == event.productId);
    if (product == null) return;

    int newQuantity = event.count ?? (product.quantity ?? 0) - 1;
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

    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        selectedProductIds: updatedSelectedProductIds));
    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      final result = await deleteCartUC(CartParams(
          productId: event.productId.toString(),
          quantity: newQuantity.toString()));
      result.fold(
        (_) => _handleCartUpdateError(
            emit, updatedProducts, product, event.context),
        (_) {
          if (wasLastProductRemoved) {
            add(LoadCartDataEvent()); // Загружаем корзину только если товар был полностью удален
          }
        },
      );
    });
  }

  // Функция для добавления товара с задержкой
  Future<void> _onAddCart(
      AddCartEvent event, Emitter<CartScreenState> emit) async {
    // Эмитируем текущее состояние, чтобы UI обновился
    emit(state.copyWith(isLoading: true));

    // Ожидаем 2 секунды, прежде чем выполнить запрос, но сбрасываем таймер, если событие повторяется
    _debounceTimer
        ?.cancel(); // Сбрасываем предыдущий таймер, если событие повторяется

    int newQuantity = 1;

    final updatedProducts =
        List<ProductEntity>.from(state.cartData?.products ?? []);
    final productIndex =
        updatedProducts.indexWhere((e) => e.productId == event.productId);

    bool wasFirstTimeAdded = productIndex == -1; // Товар отсутствовал в корзине

    if (!wasFirstTimeAdded) {
      ProductEntity product = updatedProducts[productIndex];
      newQuantity = event.count ?? (product.quantity ?? 0) + 1;
      updatedProducts[productIndex] = product.copyWith(quantity: newQuantity);
    } else {
      updatedProducts.add(
          ProductEntity(productId: event.productId, quantity: newQuantity));
    }

    emit(state.copyWith(
        cartData: state.cartData?.copyWith(products: updatedProducts),
        isLoading: true));
    _debounceTimer = Timer(
      const Duration(seconds: 2),
      () async {
        final failureOrCart = await addCartUC(CartParams(
            productId: event.productId.toString(),
            quantity: newQuantity.toString()));
        failureOrCart.fold(
          (_) => _handleCartUpdateFailure(emit, updatedProducts, event.context,
              'Ошибка добавления товара в корзину'),
          (_) {
            if (wasFirstTimeAdded) {
              add(LoadCartDataEvent()); // Загружаем корзину только если товар добавлен впервые
            }
          },
        );
      },
    );
  }

  Future<void> _onClearCart(
      ClearProductsEvent event, Emitter<CartScreenState> emit) async {
    final failureOrCart = await clearCartUC();
    failureOrCart.fold(
      (_) => Utils.showCustomDialog(
          screenContext: event.context,
          text: 'Ошибка очистки корзины',
          action: (context) => Navigator.of(context).pop()),
      (_) => add(LoadCartDataEvent()),
    );
  }

  void _onPickAllProducts(
      PickAllProductsEvent event, Emitter<CartScreenState> emit) {
    Set<int> selectedProductIds = state.isAllProductsChecked
        ? {}
        : state.cartData!.products!.map((e) => e.productId!).toSet();
    emit(state.copyWith(
        selectedProductIds: selectedProductIds,
        isAllProductsChecked: selectedProductIds.isNotEmpty));
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
    ProductEntity? product = state.cartData?.products
        ?.firstWhereOrNull((e) => e.productId == event.productId);
    if (product != null) {
      add(DeleteCartEvent(
          context: event.context,
          productId: product.productId!,
          count: product.quantity));
    } else {
      add(LoadCartDataEvent());
    }
  }

  void _onAddPromoCode(AddPromoCodeEvent event, Emitter<CartScreenState> emit) {
    PromocodeEntity? promo = state.availablePromoCodes.firstWhereOrNull(
        (promo) =>
            promo.promocode.toLowerCase().trim() ==
            event.promo.toLowerCase().trim());
    if (promo != null) {
      //final now = DateTime.now();
      //if (now.isAfter(promo.begin) && now.isBefore(promo.end)) {
      if (!state.selectedPromoCodes.contains(promo)) {
        promocodeController.clear();
        emit(state.copyWith(
          selectedPromoCodes: List.from(state.selectedPromoCodes)..add(promo),
        ));
      } else {
        emit(state.copyWith(promocodeErrorText: 'Промокод уже применен'));
      }
      //} else {
      //  emit(state.copyWith(promocodeErrorText: 'Промокод истек'));
      //}
    } else {
      emit(state.copyWith(promocodeErrorText: 'Невозможно применить промокод'));
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
  }

  void _onChangeCartType(
      ChangeCartTypeEvent event, Emitter<CartScreenState> emit) async {
    emit(state.copyWith(cartType: event.cartType));
  }

  void _onChangePaymentType(
      ChangePaymentTypeEvent event, Emitter<CartScreenState> emit) async {
    emit(state.copyWith(paymentType: event.paymentType));
  }

  void _onSelectPharmacy(
      SelectPharmacy event, Emitter<CartScreenState> emit) async {
    emit(state.copyWith(selectedPharmacy: event.pharmacy));
  }

  Future<void> _onCreateOrder(
      CreateOrderEvent event, Emitter<CartScreenState> emit) async {
    OrderParam params;
    if (state.cartType == TypeReceiving.delivery) {
      params = OrderParam(
          ids: state.selectedProductIds,
          promocodes: state.selectedPromoCodes.map((e) => e.promocode).toList(),
          pharmacyId: 0,
          delivery: 'delivery',
          payment: state.paymentType == PaymentType.online ? 'bepaid' : 'cash',
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
          comment: commentController.text);
    } else {
      params = OrderParam(
          ids: state.selectedProductIds,
          promocodes: state.selectedPromoCodes.map((e) => e.promocode).toList(),
          pharmacyId: state.selectedPharmacy?.pharmacyId ?? 0,
          delivery: 'self',
          payment: state.paymentType == PaymentType.online ? 'bepaid' : 'cash',
          lastName: fNameController.text,
          firstName: sNameController.text,
          email: emailController.text,
          phone: Utils.formatPhoneNumber(phoneController.text),
          city: cityController.text,
          address: streetHomeController.text,
          comment: commentController.text);
    }
    final failureOrCart = await createOrderUC(params);

    failureOrCart.fold(
      (_) => emit(state.copyWith(
          isLoading: false, errorText: 'Ошибка создания заказа')),
      (link) async {
        if (link != null) {
          if (await canLaunchUrl(Uri.parse(link))) {
            await launchUrl(Uri.parse(link),
                mode: LaunchMode.externalApplication);
          } else {
            throw "Не удалось открыть $link";
          }
        }
      },
    );
  }
}
