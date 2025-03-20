import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/params/cart_params.dart';
import 'package:inlek/features/domain/entities/cart_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/entities/product_pharmacy_entity.dart';
import 'package:inlek/features/domain/usecases/cart/add_cart.dart';
import 'package:inlek/features/domain/usecases/cart/delete_cart.dart';
import 'package:inlek/features/domain/usecases/cart/get_cart.dart';

part 'cart_screen_event.dart';
part 'cart_screen_state.dart';

class CartScreenBloc extends Bloc<CartScreenEvent, CartScreenState> {
  final GetCartUC getCartUC;
  final AddCartUC addCartUC;
  final DeleteCartUC deleteCartUC;
  ScrollController controller = ScrollController();

  TextEditingController fNameController = TextEditingController();
  TextEditingController sNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController cityController = TextEditingController();
  TextEditingController streetHomeController = TextEditingController();
  TextEditingController entranceController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController flatController = TextEditingController();
  TextEditingController doorPhoneController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  List<ProductEntity> inStockProducts = [];
  List<ProductEntity> pickUpAndInStockProducts = [];
  List<ProductEntity> noInStockProducts = [];

  CartScreenBloc(
      {required this.getCartUC,
      required this.addCartUC,
      required this.deleteCartUC})
      : super(
          CartScreenState(),
        ) {
    on<LoadCartDataEvent>(_onLoadData);
    on<AddCartEvent>(_onAddCart);
    on<DeleteCartEvent>(_onDeleteCart);
    on<ToggleSelectionEvent>(_onToggleSelection);
    on<ToggleShowPharmaciesWorkingNowEvent>(_onToggleShowPharmaciesWorkingNow);
    on<ToggleShowPharmaciesProductsInStockEvent>(
        _onToggleShowPharmaciesProductsInStock);

    on<PickAllProductsEvent>(
      (event, emit) async {
        Set<int> selectedProductIds = {};

        if (!state.isAllProductsChecked) {
          selectedProductIds =
              state.cartData!.products!.map((e) => e.productId!).toSet();
        }

        //await update();
        emit(
          state.copyWith(
              selectedProductIds: selectedProductIds,
              isAllProductsChecked: selectedProductIds.isNotEmpty),
        );
      },
    );

    on<ClearProductsEvent>(
      (event, emit) async {
        //await update();
        for (ProductEntity product in state.cartData?.products ?? []) {
          await deleteCartUC(
            CartParams(productId: product.productId.toString(), quantity: '0'),
          );
        }
        add(LoadCartDataEvent());
      },
    );

    on<DeleteProductEvent>(
      (event, emit) async {
        ProductEntity? product = state.cartData?.products
            ?.firstWhereOrNull((e) => e.productId == event.productId);
        if (product != null) {
          add(
            DeleteCartEvent(
                context: event.context,
                productId: product.productId!,
                count: product.pivot!.quantity),
          );
        } else {
          add(LoadCartDataEvent());
        }
      },
    );

    on<AddPromoCodeEvent>(
      (event, emit) async {
        List<int> promoCodes = List<int>.from(state.promoCodes);
        promoCodes.add(promoCodes.length);

        await update();
        emit(
          state.copyWith(promoCodes: promoCodes),
        );
      },
    );

    on<DeletePromoCodeEvent>(
      (event, emit) async {
        List<int> promoCodes = List<int>.from(state.promoCodes);
        promoCodes.remove(promoCodes.length - 1);

        await update();
        emit(
          state.copyWith(promoCodes: promoCodes),
        );
      },
    );

    on<ChangeCartTypeEvent>((event, emit) async {
      await update();
      emit(state.copyWith(cartType: event.cartType));
    });

    on<ChangePaymentTypeEvent>((event, emit) async {
      await update();
      emit(state.copyWith(paymentType: event.paymentType));
    });

    on<SelectPharmacy>((event, emit) async {
      emit(state.copyWith(selectedPharmacy: event.pharmacy));
      await update();
    });

    on<ScrollUpListEvent>((_, __) {
      controller.animateTo(0,
          duration: Duration(milliseconds: 700), curve: Curves.easeOut);
    });
  }

  void _onLoadData(
      LoadCartDataEvent event, Emitter<CartScreenState> emit) async {
    state.copyWith(isLoading: false);

    final failureOrLoads = await getCartUC();

    failureOrLoads.fold(
      (_) => emit(
        state.copyWith(isLoading: false, errorText: 'Ошибка загрузки данных'),
      ),
      (cartData) {
        inStockProducts = cartData.products ?? [];
        pickUpAndInStockProducts = cartData.products ?? [];
        noInStockProducts = cartData.products ?? [];
        emit(
          state.copyWith(errorText: null, isLoading: false, cartData: cartData),
        );
      },
    );
  }

  void _onAddCart(AddCartEvent event, Emitter<CartScreenState> emit) async {
    ProductEntity? product = state.cartData?.products
        ?.firstWhereOrNull((e) => e.productId == event.productId);
    int newCountProduct = 1;

    if (product != null) {
      newCountProduct = product.pivot!.quantity + (event.count ?? 1);
    }

    final failureOrLoads = await addCartUC(
      CartParams(
          productId: event.productId.toString(),
          quantity: newCountProduct.toString()),
    );

    failureOrLoads.fold(
      (_) => Utils.showCustomDialog(
        screenContext: event.context,
        text: 'Ошибка добавления товара в корзину',
        action: (context) => Navigator.of(context).pop(),
      ),
      (cartData) => add(LoadCartDataEvent()),
    );
  }

  void _onDeleteCart(
      DeleteCartEvent event, Emitter<CartScreenState> emit) async {
    ProductEntity? product = state.cartData?.products
        ?.firstWhereOrNull((e) => e.productId == event.productId);
    if (product != null) {
      int newCountProduct = product.pivot!.quantity - (event.count ?? 1);

      final failureOrLoads = await deleteCartUC(
        CartParams(
          productId: event.productId.toString(),
          quantity: newCountProduct.toString(),
        ),
      );

      failureOrLoads.fold(
        (_) => Utils.showCustomDialog(
          screenContext: event.context,
          text: 'Ошибка удаления товара из корзины',
          action: (context) => Navigator.of(context).pop(),
        ),
        (cartData) => add(LoadCartDataEvent()),
      );
    }
  }

  void _onToggleShowPharmaciesWorkingNow(
      ToggleShowPharmaciesWorkingNowEvent event,
      Emitter<CartScreenState> emit) {
    emit(state.copyWith(
        isShowPharmaciesWorkingNow: event.isShowPharmaciesWorkingNow));
  }

  void _onToggleShowPharmaciesProductsInStock(
      ToggleShowPharmaciesProductsInStockEvent event,
      Emitter<CartScreenState> emit) {
    emit(
      state.copyWith(
          isShowPharmaciesProductsInStock:
              event.isShowPharmaciesProductsInStock),
    );
  }

  // Event handlers
  Future _onToggleSelection(
      ToggleSelectionEvent event, Emitter<CartScreenState> emit) async {
    if (event.isChecked == null) return;

    final selectedProductIds = Set<int>.from(state.selectedProductIds);
    if (selectedProductIds.contains(event.productId)) {
      selectedProductIds.remove(event.productId);
    } else {
      selectedProductIds.add(event.productId);
    }

    bool isAllProductsChecked = (state.cartData?.products ?? [])
        .every((e) => selectedProductIds.contains(e.productId));

    //await update();
    emit(state.copyWith(
        selectedProductIds: selectedProductIds,
        isAllProductsChecked: isAllProductsChecked));
  }

  Future update() async {
    //inStockProducts = state.products
    //    .where((product) =>
    //        product.inStock &&
    //        (state.cartType == TypeReceiving.pickup || !product.isPrescription))
    //    .toList();

    //pickUpAndInStockProducts = state.products
    //    .where((product) => product.inStock && product.isPrescription)
    //    .toList();

    //noInStockProducts =
    //    state.products.where((product) => !product.inStock).toList();

    //selectedPharmacy = state.pharmacies
    //     .firstWhereOrNull((e) => e.id == state.selectedPharmacy);
  }
}
