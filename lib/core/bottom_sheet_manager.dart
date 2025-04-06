import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/json_utils.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/formatters/date_input_formatter.dart';
import 'package:inlek/core/geocoder_manager.dart';
import 'package:inlek/core/models/courier_zone_model.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/code_screen/code_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/orders_screen/orders_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/personal_data_screen/personal_data_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/pharmacies_screen/pharmacies_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/products_screen/products_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/cart_pharmacy_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/delivery_bottom_sheet/delivery_address_block.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/delivery_bottom_sheet/delivery_customer_block.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/delivery_bottom_sheet/delivery_payment_block.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/delivery_bottom_sheet/delivery_plate_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/delivery_bottom_sheet/online_payment_method_button.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/pharmacy_available_products_chip.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/products_list_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/selector_widget.dart/cubit/selector_cubit.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/selector_widget.dart/selector/selector.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/summary_block/card_summary_block.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:inlek/features/presentation/widgets/custom_radio_button.dart';
import 'package:inlek/features/presentation/widgets/dropdown_block_item.dart';
import 'package:inlek/features/presentation/widgets/dropdown_block_template.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/map/pharmacy_map_widget.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_info_list.dart';
import 'package:inlek/features/presentation/widgets/pinput_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_pharmacy_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/price_range_widget.dart';
import 'package:inlek/features/presentation/widgets/select_region_screen/city_search_field.dart';
import 'package:inlek/locator_service.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart' as ym;

class BottomSheetManager {
  static showClearCartSheet(BuildContext homeContext) {
    showModalBottomSheet(
      context: homeContext,
      builder: (sheetContext) {
        return CustomBottomSheet(
          height: 231.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Удалить все товары?',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 8.h),
              Text(
                'Отменить данное действие будет невозможно',
                style: UiConstants.textStyle3.copyWith(
                  color: UiConstants.darkBlue2Color.withOpacity(.6),
                ),
              ),
              SizedBox(height: 16.h),
              AppButtonWidget(
                text: 'Удалить',
                onTap: () {
                  homeContext.read<CartScreenBloc>().add(
                        ClearProductsEvent(homeContext),
                      );
                  Navigator.pop(sheetContext);
                },
              ),
              SizedBox(height: 8.h),
              AppButtonWidget(
                text: 'Отменить',
                isFilled: false,
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  static showNotAllProductsAvailableDeliverySheet(
      BuildContext screenContext, BuildContext homeContext) {
    return showModalBottomSheet(
      context: homeContext,
      builder: (sheetContext) {
        return CustomBottomSheet(
          height: 288.h,
          child: Column(
            children: [
              Text(
                'Не все товары доступны для доставки',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 8.h),
              Text(
                'Чтобы продолжить, снимите выбор с недоступных для доставки товаров или измените способ получения на самовывоз.',
                style: UiConstants.textStyle3.copyWith(
                  color: UiConstants.darkBlue2Color.withOpacity(.6),
                ),
              ),
              SizedBox(height: 16.h),
              AppButtonWidget(
                text: 'Оформить самовывоз',
                onTap: () {
                  homeContext.read<CartScreenBloc>().add(
                        ChangeCartTypeEvent(TypeReceiving.pickup),
                      );
                  homeContext.read<CartScreenBloc>().add(
                        ScrollUpListEvent(),
                      );
                  screenContext.read<SelectorCubit>().onSelectorItemTap(
                        [TypeReceiving.delivery, TypeReceiving.pickup]
                            .indexOf(TypeReceiving.pickup),
                      );
                  Navigator.pop(sheetContext);
                },
              ),
              SizedBox(height: 8.h),
              AppButtonWidget(
                text: 'Вернуться к оформлению',
                isFilled: false,
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );
  }

  static showDeletePromoCodeSheet(
      BuildContext homeContext, PromocodeEntity promo) {
    return showModalBottomSheet(
      context: homeContext,
      builder: (sheetContext) {
        return CustomBottomSheet(
          height: 186.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Удалить промокод?',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 16.h),
              AppButtonWidget(
                text: 'Оставить',
                onTap: () => Navigator.pop(sheetContext),
              ),
              SizedBox(height: 8.h),
              AppButtonWidget(
                text: 'Удалить',
                isFilled: false,
                onTap: () {
                  homeContext.read<CartScreenBloc>().add(
                        DeletePromoCodeEvent(promo: promo),
                      );
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static showDeliverySheet(BuildContext homeContext) {
    GlobalKey<FormState> formKey = GlobalKey();

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: homeContext,
      builder: (sheetContext) {
        return CustomBottomSheet(
          padding: getMarginOrPadding(left: 20, right: 20, top: 8, bottom: 94),
          color: UiConstants.backgroundColor,
          child: Expanded(
            child: Form(
              key: formKey,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  Text(
                    'Доставка',
                    style: UiConstants.textStyle1
                        .copyWith(color: UiConstants.darkBlueColor),
                  ),
                  SizedBox(height: 16.h),
                  InfoPlateWidget(
                      text:
                          'Доставка производится только по Минску и Минскому району'),
                  SizedBox(height: 16.h),
                  DeliveryCustomerBlock(screenContext: homeContext),
                  SizedBox(height: 16.h),
                  DeliveryAddressBlock(
                    screenContext: homeContext,
                    onPickAddressOnMap: () =>
                        showSelectAddressOnMapSheet(homeContext, sheetContext),
                  ),
                  SizedBox(height: 16.h),
                  DeliveryPaymentBlock(
                    screenContext: homeContext,
                    changedOnlineMethodTap: () =>
                        showPickOnlinePaymentSheet(homeContext, sheetContext),
                  ),
                  SizedBox(height: 16.h),
                  AppButtonWidget(
                    text: 'Оформить заказ',
                    isActive: true,
                    onTap: () {
                      if (formKey.currentState?.validate() ?? false) {
                        homeContext
                            .read<CartScreenBloc>()
                            .add(CreateOrderEvent());
                        showThanksForOrderSheet(homeContext);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static showPickOnlinePaymentSheet(
      BuildContext homeContext, BuildContext screenContext) {
    return showModalBottomSheet(
      context: screenContext,
      builder: (sheetContext) {
        return CustomBottomSheet(
          height: 250.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Оплата онлайн',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 16.h),
              /*OnlinePaymentMethodButton(
                child: Padding(
                  padding: getMarginOrPadding(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      SvgPicture.asset(Paths.cardIconPath,
                          width: 24.w, height: 24.w),
                      SizedBox(width: 8.w),
                      Text(
                        'Картой',
                        style: UiConstants.textStyle3.copyWith(
                            color: UiConstants.darkBlueColor,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.pop(screenContext);
                },
              ),*/
              OnlinePaymentMethodButton(
                child: SvgPicture.asset(Paths.oplatiIconPath),
                onTap: () {
                  Navigator.pop(screenContext);
                },
              ),
              OnlinePaymentMethodButton(
                child:
                    Image.asset(Paths.eripIconPath, width: 88.w, height: 44.h),
                onTap: () {
                  Navigator.pop(screenContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static showSelectAddressOnMapSheet(
      BuildContext homeContext, BuildContext screenContext) async {
    // контроллер для адреса
    TextEditingController searchAddressController = TextEditingController();
    // стейт-менеджер для работы с корзиной
    CartScreenBloc cartScreenBloc = homeContext.read<CartScreenBloc>();
    // модель полигонов доставки
    CourierZoneModel courierZoneModel = await JsonUtils.loadCourierZones();
    // таймер для задержки по обратному геокодированию
    Timer? debounce;

    // Стейт для отслеживания выбранного адреса
    List<GeoObject?> suggestionObjects = [];
    GeoObject? selectedAddress;

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: homeContext,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomBottomSheet(
              padding:
                  getMarginOrPadding(left: 20, right: 20, top: 8, bottom: 94),
              color: UiConstants.backgroundColor,
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Выбрать на карте',
                      style: UiConstants.textStyle1
                          .copyWith(color: UiConstants.darkBlueColor),
                    ),
                    SizedBox(height: 16.h),
                    InfoPlateWidget(
                        text:
                            'Доставка производится только по Минску и Минскому району'),
                    SizedBox(height: 16.h),
                    Skeleton.ignorePointer(
                      child: Skeleton.shade(
                        child: CitySearchField(
                          hint: 'Искать улицу или район',
                          controller: searchAddressController,
                          suggestionObjects: suggestionObjects,
                          suggestionFetcher: (query) async {
                            if (query.length <= 2) return [];

                            debounce?.cancel();

                            final completer = Completer<List<String>>();
                            debounce =
                                Timer(Duration(milliseconds: 1500), () async {
                              final geocoderManager = sl<GeocoderManager>();
                              GeocodeResponse? response = await geocoderManager
                                  .getGeocodeFromAddress(query);

                              suggestionObjects = response?.response
                                      ?.geoObjectCollection?.featureMember
                                      ?.map((e) => e.geoObject)
                                      .toList() ??
                                  [];

                              // Извлекаем все адреса из ответа
                              List<String> addresses = suggestionObjects
                                  .map((e) =>
                                      e?.metaDataProperty?.geocoderMetaData
                                          ?.address?.formatted ??
                                      '')
                                  .where((address) => address.isNotEmpty)
                                  .toList();

                              setState(() {});

                              completer.complete(addresses);
                            });

                            return completer.future;
                          },
                          onSuggestionTap: (p0) {
                            if ((p0 as GeoObject?)
                                    ?.metaDataProperty
                                    ?.geocoderMetaData
                                    ?.address
                                    ?.components
                                    ?.any((component) =>
                                        component.kind == KindResponse.house) ??
                                false) {
                              setState(() => selectedAddress = p0);
                            }
                          },
                          onChangeField: (p0) {
                            if (selectedAddress != null) {
                              setState(() => selectedAddress = null);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: PharmacyMapWidget(points: [
                        if (selectedAddress != null)
                          CustomMapObject(
                              mapObject: ym.PlacemarkMapObject(
                                  mapId: ym.MapObjectId("213"),
                                  point: ym.Point(
                                      latitude:
                                          selectedAddress!.point!.latitude!,
                                      longitude:
                                          selectedAddress!.point!.longitude!)))
                      ], mapScreenType: MapScreenType.order),
                    ),
                    SizedBox(height: 16.h),
                    if (selectedAddress != null)
                      AppButtonWidget(
                        text: 'Подтвердить',
                        isActive: true,
                        onTap: () => Navigator.pop(screenContext),
                      )
                    else
                      AppButtonWidget(
                        text: 'Оформить самовывоз',
                        isActive: true,
                        onTap: () => Navigator.pop(screenContext),
                      )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static showThanksForOrderSheet(BuildContext homeContext) {
    CartScreenBloc cartBloc = homeContext.read<CartScreenBloc>();
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: homeContext,
      builder: (sheetContext) {
        final List<ProductEntity> cartProducts =
            cartBloc.state.cartData?.products ?? [];
        final Set<int> selectedProductIds = cartBloc.state.selectedProductIds;

        List<ProductEntity> orderedProducts = cartProducts
            .where((e) => selectedProductIds.contains(e.productId))
            .toList();
        return CustomBottomSheet(
          padding: getMarginOrPadding(left: 20, right: 20, top: 8),
          color: UiConstants.backgroundColor,
          child: Expanded(
            child: ListView(
              padding: getMarginOrPadding(bottom: 94),
              shrinkWrap: true,
              children: [
                Text(
                  'Спасибо за заказ!',
                  style: UiConstants.textStyle1
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Статус заказов можно отслеживать в профиле в разделе «Заказы» или на главной странице.',
                  style: UiConstants.textStyle2.copyWith(
                    color: UiConstants.darkBlue2Color.withOpacity(.6),
                  ),
                ),
                SizedBox(height: 16.h),
                ProductsListWidget(
                    title: 'Товары',
                    products: orderedProducts,
                    productsListScreenType: ProductsListScreenType.order,
                    screenContext: homeContext),
                SizedBox(height: 16.h),
                Text(
                  'Информация о заказе',
                  style: UiConstants.textStyle5
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: getMarginOrPadding(all: 16),
                  decoration: BoxDecoration(
                    color: UiConstants.whiteColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: OrderInfoList(
                    pharmacy: cartBloc.state.selectedPharmacy,
                    order: OrderEntity(
                        orderId: Random().nextInt(10000),
                        createdAt: DateTime.now(),
                        typeReceipt: cartBloc.state.cartType,
                        paymentType: cartBloc.state.paymentType),
                    address:
                        "${cartBloc.cityController.text}, ${cartBloc.streetHomeController.text}",
                  ),
                ),
                SizedBox(height: 32.h),
                AppButtonWidget(
                  text: 'К списку заказов',
                  isActive: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.pop(homeContext);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static showSelectPharmacySheet(BuildContext homeContext) {
    CartScreenBloc cartBloc = homeContext.read<CartScreenBloc>();
    TextEditingController queryController = TextEditingController();

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: homeContext,
      builder: (sheetContext) {
        int selectorIndex = 0;

        return BlocBuilder<CartScreenBloc, CartScreenState>(
          bloc: cartBloc,
          builder: (context, cartState) {
            return CustomBottomSheet(
              padding: getMarginOrPadding(left: 20, right: 20, top: 8),
              color: UiConstants.whiteColor,
              child: Expanded(
                child: BlocProvider(
                  create: (context) => SelectorCubit(index: selectorIndex),
                  child: BlocBuilder<SelectorCubit, SelectorState>(
                    builder: (context, state) {
                      return BlocProvider(
                        create: (context) => PharmaciesScreenBloc()
                          ..add(
                            LoadPharmaciesDataEvent(cartState.pharmacies),
                          ),
                        child: BlocBuilder<PharmaciesScreenBloc,
                            PharmaciesScreenState>(
                          builder: (context, state) {
                            PharmaciesScreenBloc pharmaciesBloc =
                                context.read<PharmaciesScreenBloc>();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Самовывоз',
                                  style: UiConstants.textStyle1.copyWith(
                                      color: UiConstants.darkBlueColor),
                                ),
                                SizedBox(height: 16.h),
                                BlockWidget(
                                  title: 'Выбор аптеки',
                                  titleStyle: UiConstants.textStyle9,
                                  clickableText:
                                      '${state.filteredPharmacies.length} аптек',
                                  child: CustomAppBar(
                                    controller: queryController,
                                    hintText: 'Искать аптеки',
                                    backgroundColor: Colors.transparent,
                                    contentPadding: EdgeInsets.zero,
                                    isShowFilterButton: true,
                                    onTapFilterButton: () =>
                                        showPharmacySortSheet(context),
                                    onChangedField: (value) =>
                                        pharmaciesBloc.add(
                                      ChangePharmacyQueryEvent(value),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32.h),
                                // селектор список/карта
                                Align(
                                  alignment: AlignmentDirectional.center,
                                  child: Selector(
                                    titlesList: const ['Список', 'Карта'],
                                    onTap: (int index) => selectorIndex = index,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                if (selectorIndex == 0)
                                  Expanded(
                                    child: ListView.separated(
                                        padding: getMarginOrPadding(bottom: 94),
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) =>
                                            CartPharmacyWidget(
                                                pharmacy: state
                                                    .filteredPharmacies[index],
                                                onButtonTap: () =>
                                                    showPharmacySheet(
                                                      homeContext,
                                                      state.filteredPharmacies[
                                                          index],
                                                    ),
                                                screenContext: homeContext),
                                        separatorBuilder: (context, index) =>
                                            SizedBox(height: 8.h),
                                        itemCount:
                                            state.filteredPharmacies.length),
                                  )
                                else
                                  Expanded(
                                    child: Padding(
                                      padding: getMarginOrPadding(bottom: 94),
                                      child: PharmacyMapWidget(
                                          points: state.mapObjects,
                                          mapScreenType: MapScreenType.cart),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static showPharmacySheet(BuildContext homeContext, PharmacyEntity pharmacy) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: homeContext,
      builder: (sheetContext) {
        final cartBloc = homeContext.read<CartScreenBloc>();

        return BlocBuilder<CartScreenBloc, CartScreenState>(
          builder: (context, state) {
            List<ProductEntity> products =
                cartBloc.state.cartData?.products ?? [];
            Set<int> selectedProductIds = cartBloc.state.selectedProductIds;

            List<ProductEntity> selectedProducts = products
                .where(
                    (product) => selectedProductIds.contains(product.productId))
                .toList();

            List<ProductEntity> noAvailableProducts = [];

            //List<ProductEntity> noAvailableProducts = selectedProducts
            //    .where((product) =>
            //        !pharmacy.availableProducts.contains(product.productId))
            //    .toList();
//
            // Обновляем свойство inStock для каждого продукта
            //for (var product in noAvailableProducts) {
            //  product.inStock = false;
            //}

            //List<Product> availableProducts = selectedProducts
            //    .where((product) => pharmacy.availableProducts
            //        .map((e) => e.id)
            //        .contains(product.id))
            //    .toList();

            List<ProductEntity> availableProducts = [];
            return CustomBottomSheet(
              padding: getMarginOrPadding(left: 20, right: 20, top: 8),
              color: UiConstants.backgroundColor,
              child: Expanded(
                child: ListView(
                  padding: getMarginOrPadding(bottom: 94),
                  shrinkWrap: true,
                  children: [
                    Text(
                      pharmacy.pageTitle ?? pharmacy.pharmacyName ?? '-',
                      style: UiConstants.textStyle3
                          .copyWith(color: UiConstants.darkBlueColor),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      pharmacy.address ?? '',
                      style: UiConstants.textStyle2.copyWith(
                        color: UiConstants.darkBlueColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    PharmacyAvailableProductsChip(
                        allProductsAvailable: noAvailableProducts.isEmpty),
                    SizedBox(height: 32.h),
                    // список с законченными товарами
                    if (noAvailableProducts.isNotEmpty)
                      Padding(
                        padding: getMarginOrPadding(bottom: 32),
                        child: ProductsListWidget(
                            title: 'Товары закончились',
                            subtitle:
                                'Эти товары останутся в корзине, их можно будет оформить отдельным заказом в другой аптеке.',
                            products: noAvailableProducts,
                            screenContext: homeContext,
                            productsListScreenType:
                                ProductsListScreenType.pharmacy),
                      ),
                    ProductsListWidget(
                        title: 'В наличии',
                        products: selectedProducts,
                        screenContext: homeContext,
                        productsListScreenType:
                            ProductsListScreenType.pharmacy),
                    // подсчёт стоимости
                    if ((cartBloc.state.cartData?.products ?? []).isNotEmpty)
                      Padding(
                        padding: getMarginOrPadding(bottom: 16, top: 16),
                        child: CardSummaryBlock(
                            screenContext: homeContext,
                            canUsePromoCodes: false),
                      ),

                    AppButtonWidget(
                      text: 'Заберу отсюда',
                      isActive: true,
                      onTap: () {
                        cartBloc.add(SelectPharmacy(pharmacy));
                        Navigator.pop(context);
                        Navigator.pop(homeContext);
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static showProductReceiptNotificationSheet(BuildContext homeContext) {
    showModalBottomSheet(
      context: homeContext,
      builder: (sheetContext) {
        return CustomBottomSheet(
          height: 180.h,
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Мы сообщим вам о поступлении данного товара пуш‑уведомлением',
                  style: UiConstants.textStyle5
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                Spacer(),
                AppButtonWidget(
                  text: 'Продолжить покупки',
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static showConfirmationCodeSheet(
      BuildContext homeContext,
      BuildContext screenContext,
      PersonalDataScreenBloc personalDataBloc) async {
    final bloc = screenContext.read<CodeScreenBloc>();

    showModalBottomSheet(
      context: homeContext,
      builder: (sheetContext) {
        return BlocBuilder<CodeScreenBloc, CodeScreenState>(
          bloc: bloc,
          builder: (context, state) {
            return CustomBottomSheet(
              height: 365,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Введите код подтверждения',
                    style: UiConstants.textStyle5
                        .copyWith(color: UiConstants.darkBlueColor),
                  ),
                  SizedBox(height: 8.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Мы отправили код на номер\n',
                          style: UiConstants.textStyle3.copyWith(
                            color: UiConstants.darkBlue2Color.withOpacity(.6),
                          ),
                        ),
                        TextSpan(
                          text: personalDataBloc.phoneController.text,
                          style: UiConstants.textStyle3.copyWith(
                              color: UiConstants.darkBlue2Color.withOpacity(.6),
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Center(
                    child: PinputWidget(
                        controller: bloc.codeController,
                        focusNode: bloc.codeFocusNode,
                        showError: bloc.state.showError),
                  ),
                  SizedBox(height: 32.h),
                  AppButtonWidget(
                    isActive: bloc.state.isButtonActive,
                    text: 'Подтвердить',
                    onTap: () => bloc.add(SubmitCodeEvent()),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: Builder(
                      builder: (context) {
                        return bloc.state.canRequestNewCode
                            ? GestureDetector(
                                onTap: () => bloc.add(RequestNewCodeEvent()),
                                child: Text(
                                  'Запросить код снова',
                                  style: UiConstants.textStyle3
                                      .copyWith(color: UiConstants.purpleColor),
                                ),
                              )
                            : Text(
                                'Запросить код ещё раз через ${Utils.formatSecondToMMSS(bloc.state.secondsLeft)}',
                                style: UiConstants.textStyle3.copyWith(
                                    color: UiConstants.mutedVioletColor),
                              );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static showProductsFilterSheet(BuildContext homeContext,
      {ProductsScreenBloc? productsScreenBloc}) {
    ProductsScreenBloc productsScreenBloc =
        homeContext.read<ProductsScreenBloc>();
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: homeContext.read<HomeScreenBloc>().context,
      builder: (sheetContext) {
        return BlocBuilder<ProductsScreenBloc, ProductsScreenState>(
          bloc: productsScreenBloc,
          builder: (context, state) {
            return CustomBottomSheet(
              color: UiConstants.whiteColor,
              child: Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Фильтры',
                          style: UiConstants.textStyle5
                              .copyWith(color: UiConstants.darkBlueColor),
                        ),
                        GestureDetector(
                          onTap: () => productsScreenBloc.add(
                            ClearEvent(),
                          ),
                          child: Text(
                            'Сбросить',
                            style: UiConstants.textStyle3.copyWith(
                              color: UiConstants.darkBlue2Color.withOpacity(.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    PriceRangeWidget(homeContext: homeContext),
                    SizedBox(height: 11.h),
                    DropdownBlockTemplate(
                      title: 'Форма выпуска',
                      child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final item = state.releaseForms[index];

                            return DropdownBlockItem(
                              text: item,
                              isChecked:
                                  state.selectedReleaseForms.contains(item),
                              onChanged: (isChecked) => productsScreenBloc.add(
                                SelectReleaseFormEvent(item, isChecked),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 8),
                          itemCount: state.releaseForms.length),
                    ),
                    SizedBox(height: 16.h),
                    DropdownBlockTemplate(
                      title: 'Производитель',
                      child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final item = state.manufacturers[index];

                            return DropdownBlockItem(
                              text: item,
                              isChecked:
                                  state.selectedManufacturers.contains(item),
                              onChanged: (isChecked) => productsScreenBloc.add(
                                SelectManufacturerEvent(item, isChecked),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 8),
                          itemCount: state.manufacturers.length),
                    ),
                    SizedBox(height: 16.h),
                    DropdownBlockTemplate(
                      title: 'Страна производства',
                      child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final item = state.countries[index];

                            return DropdownBlockItem(
                              text: item,
                              isChecked: state.selectedCountries.contains(item),
                              onChanged: (isChecked) => productsScreenBloc.add(
                                SelectCountryEvent(item, isChecked),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 8),
                          itemCount: state.countries.length),
                    ),
                    Padding(
                      padding: getMarginOrPadding(top: 16, bottom: 16),
                      child: Divider(color: UiConstants.white5Color),
                    ),
                    DropdownBlockItem(
                      text: 'Без рецепта',
                      isChecked: state.isWithoutPrescription,
                      onChanged: (isChecked) => productsScreenBloc.add(
                        ToggleWithoutPrescriptionEvent(isChecked),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownBlockItem(
                      text: 'Участвует в акции',
                      isChecked: state.isParticipatesInCampaign,
                      onChanged: (isChecked) => productsScreenBloc.add(
                        ToggleParticipatesInCampaignEvent(isChecked),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownBlockItem(
                      text: 'Возможна доставка',
                      isChecked: state.isDeliveryPossible,
                      onChanged: (isChecked) => productsScreenBloc.add(
                        ToggleDeliveryPossibleEvent(isChecked),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppButtonWidget(
                      text: 'Показать результаты',
                      onTap: () {
                        productsScreenBloc.add(
                          ChangeProductSortTypeEvent(
                              ProductSortType.popularity),
                        );

                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static showProductSortSheet(
      BuildContext homeContext, BuildContext screenContext) {
    showModalBottomSheet(
      context: homeContext,
      builder: (sheetContext) {
        ProductsScreenBloc productsBloc =
            screenContext.read<ProductsScreenBloc>();
        return BlocBuilder<ProductsScreenBloc, ProductsScreenState>(
          bloc: productsBloc,
          builder: (context, state) {
            return CustomBottomSheet(
              height: 210.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сортировка',
                    style: UiConstants.textStyle5
                        .copyWith(color: UiConstants.darkBlueColor),
                  ),
                  SizedBox(height: 16.h),
                  ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final sortType = ProductSortType.values[index];

                        return CustomRadioButton(
                          isLabelOnLeft: true,
                          title: sortType.displayName,
                          textStyle: UiConstants.textStyle2,
                          value: sortType,
                          groupValue: state.productSortType,
                          onChanged: () => productsBloc.add(
                            ChangeProductSortTypeEvent(sortType),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 8.h),
                      itemCount: ProductSortType.values.length)
                ],
              ),
            );
          },
        );
      },
    );
  }

  static showPharmacySortSheet(BuildContext homeContext) {
    showModalBottomSheet(
      context: homeContext,
      builder: (sheetContext) {
        PharmaciesScreenBloc pharmaciesBloc =
            homeContext.read<PharmaciesScreenBloc>();
        return BlocBuilder<PharmaciesScreenBloc, PharmaciesScreenState>(
          bloc: pharmaciesBloc,
          builder: (context, state) {
            return CustomBottomSheet(
              height: 240.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Фильтр',
                    style: UiConstants.textStyle5
                        .copyWith(color: UiConstants.darkBlueColor),
                  ),
                  SizedBox(height: 16.h),
                  CustomRadioButton(
                    isLabelOnLeft: true,
                    title: 'Все способы получения',
                    textStyle: UiConstants.textStyle2,
                    value: TypeReceiving.all,
                    groupValue: state.pharmacySortType,
                    onChanged: () => pharmaciesBloc.add(
                      ChangePharmacySortTypeEvent(TypeReceiving.all),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomRadioButton(
                    isLabelOnLeft: true,
                    title: 'Самовывоз',
                    textStyle: UiConstants.textStyle2,
                    value: TypeReceiving.pickup,
                    groupValue: state.pharmacySortType,
                    onChanged: () => pharmaciesBloc.add(
                      ChangePharmacySortTypeEvent(TypeReceiving.pickup),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomRadioButton(
                    isLabelOnLeft: true,
                    title: 'Доставка',
                    textStyle: UiConstants.textStyle2,
                    value: TypeReceiving.delivery,
                    groupValue: state.pharmacySortType,
                    onChanged: () => pharmaciesBloc.add(
                      ChangePharmacySortTypeEvent(TypeReceiving.delivery),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static showOrdersFilterSheet(
      BuildContext homeContext, BuildContext screenContext) {
    OrdersScreenBloc ordersBloc = screenContext.read<OrdersScreenBloc>();
    final state = ordersBloc.state;

    // Локальные копии состояния
    Set<int> selectedTypesReceivingIds =
        Set.from(state.selectedTypesReceivingIds);
    Set<OrderStatus> selectedStatuses = Set.from(state.selectedStatuses);

    DateTime? startDate =
        state.startDate ?? DateTime(DateTime.now().year, 1, 1);
    DateTime? endDate = state.endDate ?? DateTime(DateTime.now().year, 12, 31);

    DateFormat format = DateFormat('dd / MM / yyyy');
    TextEditingController startDateController =
        TextEditingController(text: format.format(startDate));
    TextEditingController endDateController =
        TextEditingController(text: format.format(endDate));

    bool isButtonActive =
        startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: homeContext,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validateDates() {
              RegExp dateRegex = RegExp(r'^\d{2} / \d{2} / \d{4}$');

              bool isValidFormat =
                  dateRegex.hasMatch(startDateController.text) &&
                      dateRegex.hasMatch(endDateController.text);

              if (!isValidFormat) {
                setState(() {
                  isButtonActive = false;
                });
                return;
              }

              startDate = DateFormat('dd / MM / yyyy')
                  .tryParse(startDateController.text);
              endDate =
                  DateFormat('dd / MM / yyyy').tryParse(endDateController.text);

              bool isValid = startDate != null &&
                  endDate != null &&
                  (startDate!.isBefore(endDate!) ||
                      startDate!.isAtSameMomentAs(endDate!));

              setState(() {
                isButtonActive = isValid;
              });
            }

            void clear() {
              selectedTypesReceivingIds.clear();
              selectedStatuses.clear();

              startDate =
                  state.startDate ?? DateTime(DateTime.now().year, 1, 1);
              endDate = state.endDate ?? DateTime(DateTime.now().year, 12, 31);

              startDateController =
                  TextEditingController(text: format.format(startDate!));
              endDateController =
                  TextEditingController(text: format.format(endDate!));
            }

            return CustomBottomSheet(
              color: UiConstants.whiteColor,
              child: Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Фильтры',
                          style: UiConstants.textStyle5
                              .copyWith(color: UiConstants.darkBlueColor),
                        ),
                        GestureDetector(
                          onTap: () => setState(clear),
                          child: Text(
                            'Сбросить',
                            style: UiConstants.textStyle3.copyWith(
                              color: UiConstants.darkBlue2Color.withOpacity(.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    DropdownBlockTemplate(
                      title: 'Способ получения',
                      child: ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => DropdownBlockItem(
                                text: state.typesReceiving[index],
                                isChecked:
                                    selectedTypesReceivingIds.contains(index),
                                onChanged: (isChecked) {
                                  if (isChecked == null) return;
                                  setState(() {
                                    if (isChecked) {
                                      selectedTypesReceivingIds.add(index);
                                    } else {
                                      selectedTypesReceivingIds.remove(index);
                                    }
                                  });
                                },
                              ),
                          separatorBuilder: (_, __) => SizedBox(height: 8),
                          itemCount: state.typesReceiving.length),
                    ),
                    SizedBox(height: 16.h),
                    DropdownBlockTemplate(
                      title: 'Статус',
                      child: ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final statusMap = OrderStatusExtension.titles.entries
                              .elementAt(index);
                          final status = statusMap.key;
                          final statusName = statusMap.value;

                          return DropdownBlockItem(
                            text: statusName,
                            isChecked: selectedStatuses.contains(status),
                            onChanged: (isChecked) {
                              if (isChecked == null) return;
                              setState(
                                () {
                                  if (isChecked) {
                                    selectedStatuses.add(status);
                                  } else {
                                    selectedStatuses.remove(status);
                                  }
                                },
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: 8),
                        itemCount: OrderStatusExtension.titles.length,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    DropdownBlockTemplate(
                      title: 'Дата заказа',
                      child: Row(
                        children: [
                          Expanded(
                            child: AppTextFieldWidget(
                              hintMaxLines: 1,
                              title: 'От',
                              hintText: 'ДД / ММ / ГГГГ',
                              controller: startDateController,
                              keyboardType: TextInputType.datetime,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                DateInputFormatter()
                              ],
                              suffixWidget: Padding(
                                padding:
                                    getMarginOrPadding(top: 10, bottom: 12),
                                child: SvgPicture.asset(Paths.calendarIconPath),
                              ),
                              contentPadding:
                                  getMarginOrPadding(left: 12, right: 12),
                              onChangedField: (value) => validateDates(),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: AppTextFieldWidget(
                              hintMaxLines: 1,
                              title: 'До',
                              hintText: 'ДД / ММ / ГГГГ',
                              controller: endDateController,
                              keyboardType: TextInputType.datetime,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                DateInputFormatter()
                              ],
                              suffixWidget: Padding(
                                padding:
                                    getMarginOrPadding(top: 10, bottom: 12),
                                child: SvgPicture.asset(Paths.calendarIconPath),
                              ),
                              contentPadding:
                                  getMarginOrPadding(left: 12, right: 12),
                              onChangedField: (value) => validateDates(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    AppButtonWidget(
                        text: 'Показать результаты',
                        onTap: isButtonActive
                            ? () {
                                ordersBloc.add(
                                  ApplyFiltersEvent(
                                      selectedTypesReceivingIds:
                                          selectedTypesReceivingIds,
                                      selectedStatuses: selectedStatuses,
                                      startDate: startDate,
                                      endDate: endDate),
                                );
                                Navigator.pop(context);
                              }
                            : null)
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static showPharmacyInfoSheet(
      BuildContext homeContext, PharmacyEntity pharmacy) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: homeContext,
      builder: (sheetContext) {
        return CustomBottomSheet(
          padding: EdgeInsets.zero,
          height: 230,
          child: ProductPharmacyWidget(pharmacy: pharmacy),
        );
      },
    );
  }
}
