import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/courier_zone_manager.dart';
import 'package:inlek/core/formatters/date_input_formatter.dart';
import 'package:inlek/core/geocoder_manager.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:inlek/core/params/cart_pharmacies_param.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/city_model.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/code_screen/code_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/orders_screen/orders_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/personal_data_screen/personal_data_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/pharmacies_cart_screen/pharmacies_cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/pharmacies_screen/pharmacies_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/pharmacy_map/pharmacy_map_bloc.dart';
import 'package:inlek/features/presentation/bloc/products_screen/products_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/profile/orders/orders_screen.dart';
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
import 'package:inlek/features/presentation/widgets/cart_screen/summary_block/summary_pharmacy_prices_block.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/custom_bottom_sheet.dart';
import 'package:inlek/features/presentation/widgets/custom_checkbox.dart';
import 'package:inlek/features/presentation/widgets/custom_radio_button.dart';
import 'package:inlek/features/presentation/widgets/dropdown_block_item.dart';
import 'package:inlek/features/presentation/widgets/dropdown_block_template.dart';
import 'package:inlek/features/presentation/widgets/info_about_order_screen/courier_delivery_zone_item.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/map/pharmacy_map_widget.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_info_list.dart';
import 'package:inlek/features/presentation/widgets/pinput_widget.dart';
import 'package:inlek/features/presentation/widgets/product_screen/product_pharmacy_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/price_range_widget.dart';
import 'package:inlek/features/presentation/widgets/select_region_screen/city_search_field.dart';
import 'package:inlek/features/presentation/widgets/validation_helper_widget.dart';
import 'package:inlek/locator_service.dart';
import 'package:inlek/main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as ym;

class BottomSheetManager {
  static Future<bool?> showDeleteAccountSheet(BuildContext context) {
    return showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (sheetContext) {
        return CustomBottomSheet(
          //height: 158,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Вы дейстивильно хотите удалить аккаунт?',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButtonWidget(
                      alignment: Alignment.centerLeft,
                      onTap: () {
                        Navigator.pop(sheetContext, true);
                      },
                      text: 'Удалить',
                      backgroundColor: UiConstants.whiteColor,
                      textColor: UiConstants.blackColor.withOpacity(.6),
                    ),
                  ),
                  Expanded(
                    child: AppButtonWidget(
                        onTap: () => Navigator.pop(sheetContext, false),
                        text: 'Нет',
                        backgroundColor: UiConstants.purpleColor),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<bool?> showUnsavedChangesSheet(BuildContext context) {
    return showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (sheetContext) {
        return CustomBottomSheet(
          //height: 158,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Вы хотите уйти без сохранения изменений?',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButtonWidget(
                        alignment: Alignment.centerLeft,
                        onTap: () {
                          Navigator.pop(sheetContext, true); // Save and leave
                        },
                        text: 'Сохранить',
                        backgroundColor: UiConstants.whiteColor,
                        textColor: UiConstants.darkBlueColor),
                  ),
                  Expanded(
                    child: AppButtonWidget(
                      onTap: () => Navigator.pop(
                          sheetContext, false), // Don't save, just leave
                      text: 'Не сохранять',
                      backgroundColor: UiConstants.purpleColor,
                      textColor: UiConstants.whiteColor,
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static showClearCartSheet(BuildContext screenContext) {
    showModalBottomSheet(
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        return CustomBottomSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Удалить все товары?',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 8),
              Text(
                'Отменить данное действие будет невозможно',
                style: UiConstants.textStyle3.copyWith(
                  color: UiConstants.darkBlue2Color.withOpacity(.6),
                ),
              ),
              SizedBox(height: 16),
              AppButtonWidget(
                text: 'Удалить',
                onTap: () {
                  screenContext.read<CartScreenBloc>().add(
                        ClearProductsEvent(screenContext),
                      );
                  Navigator.pop(sheetContext);
                },
              ),
              SizedBox(height: 8),
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

  static Future<bool?> showNotAllProductsAvailableDeliverySheet(
      BuildContext screenContext, BuildContext homeContext) {
    return showModalBottomSheet<bool>(
      context: homeContext,
      builder: (sheetContext) {
        return CustomBottomSheet(
          child: Column(
            children: [
              Text(
                'Не все товары доступны для доставки',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 8),
              Text(
                'Чтобы продолжить, снимите выбор с недоступных для доставки товаров или измените способ получения на самовывоз.',
                style: UiConstants.textStyle3.copyWith(
                  color: UiConstants.darkBlue2Color.withOpacity(.6),
                ),
              ),
              SizedBox(height: 16),
              AppButtonWidget(
                text: 'Оформить самовывоз',
                onTap: () => Navigator.pop(sheetContext, true),
              ),
              SizedBox(height: 8),
              AppButtonWidget(
                text: 'Вернуться к оформлению',
                isFilled: false,
                onTap: () => Navigator.pop(sheetContext, false),
              ),
            ],
          ),
        );
      },
    );
  }

  static showDeletePromoCodeSheet(
      BuildContext screenContext, PromocodeEntity promo) {
    return showModalBottomSheet(
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        return CustomBottomSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Удалить промокод?',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 16),
              AppButtonWidget(
                text: 'Оставить',
                onTap: () => Navigator.pop(sheetContext),
              ),
              SizedBox(height: 8),
              AppButtonWidget(
                text: 'Удалить',
                isFilled: false,
                onTap: () {
                  screenContext.read<CartScreenBloc>().add(
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

  static Future<bool?> showExitAccountSheet(BuildContext context) {
    return showModalBottomSheet<bool?>(
      useRootNavigator: true,
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        return CustomBottomSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Вы хотите выйти из профиля?',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 16),
              AppButtonWidget(
                text: 'Остаться',
                onTap: () => Navigator.pop(sheetContext, false),
              ),
              SizedBox(height: 8),
              AppButtonWidget(
                text: 'Выйти',
                isFilled: false,
                onTap: () {
                  Navigator.pop(sheetContext, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static showDeliverySheet(BuildContext screenContext) {
    GlobalKey<FormState> formKey = GlobalKey();
    final ScrollController scrollController = ScrollController();

    // GlobalKeys для обязательных полей
    final GlobalKey firstNameKey = GlobalKey();
    final GlobalKey lastNameKey = GlobalKey();
    final GlobalKey phoneKey = GlobalKey();
    final GlobalKey emailKey = GlobalKey();
    final GlobalKey commentKey = GlobalKey();
    final GlobalKey cityKey = GlobalKey();
    final GlobalKey streetKey = GlobalKey();

    CartScreenBloc cartBloc = screenContext.read<CartScreenBloc>();
    PersonalDataScreenBloc personalDataScreenBloc =
        screenContext.read<PersonalDataScreenBloc>();
    OrdersScreenBloc ordersScreenBloc = screenContext.read<OrdersScreenBloc>();

    // сбрасываем при новом открытии
    cartBloc.cityController.text = '';
    cartBloc.streetHomeController.text = '';
    cartBloc.flatController.text = '';
    cartBloc.floorController.text = '';
    cartBloc.entranceController.text = '';
    cartBloc.doorPhoneController.text = '';
    cartBloc.commentController.text = '';
    cartBloc.add(ChangePaymentTypeEvent(PaymentType.courier));

    final sharedPreferences = sl<SharedPreferences>();

    final String? fName = personalDataScreenBloc.initialFirstName;
    final String? lName = personalDataScreenBloc.initialLastName;
    final String? email = personalDataScreenBloc.initialEmail;
    final String? phone = personalDataScreenBloc.initialPhone;

    final city = (() {
      try {
        final json = sharedPreferences.getString(SharedPreferencesKeys.city);
        return json == null
            ? 'null'
            : CityModel.fromJson(jsonDecode(json)).pagetitle;
      } catch (_) {
        return 'null';
      }
    })();

    final savedApartment =
        sharedPreferences.getString(SharedPreferencesKeys.savedApartment);
    final savedEntrance =
        sharedPreferences.getString(SharedPreferencesKeys.savedEntrance);
    final savedFloor =
        sharedPreferences.getString(SharedPreferencesKeys.savedFloor);
    final savedIntercom =
        sharedPreferences.getString(SharedPreferencesKeys.savedIntercom);
    final savedComment =
        sharedPreferences.getString(SharedPreferencesKeys.savedComment);

    if (cartBloc.selectedAddress != null) {
      try {
        final streetComponent = cartBloc.selectedAddress!.metaDataProperty
            ?.geocoderMetaData?.address?.components
            ?.firstWhere((component) => component.kind == KindResponse.street);

        final houseComponent = cartBloc.selectedAddress!.metaDataProperty
            ?.geocoderMetaData?.address?.components
            ?.firstWhere((component) => component.kind == KindResponse.house);

        final cityComponent = cartBloc.selectedAddress!.metaDataProperty
            ?.geocoderMetaData?.address?.components
            ?.firstWhere(
                (component) => component.kind == KindResponse.locality);

        cartBloc.streetHomeController.text =
            '${streetComponent?.name}, ${houseComponent?.name}';
        cartBloc.cityController.text = cityComponent?.name ?? '';
      } catch (_) {
        if (city != 'null') {
          cartBloc.cityController.text = city;
        }
      }
    } else if (city != 'null') {
      cartBloc.cityController.text = city;
    }

    cartBloc.fNameController.text = fName ?? '';
    cartBloc.sNameController.text = lName ?? '';
    cartBloc.emailController.text = email ?? '';
    cartBloc.phoneController.text = phone ?? '';

    cartBloc.flatController.text = savedApartment ?? '';
    cartBloc.floorController.text = savedFloor ?? '';
    cartBloc.doorPhoneController.text = savedIntercom ?? '';
    cartBloc.entranceController.text = savedEntrance ?? '';

    cartBloc.commentController.text = savedComment ?? '';

    cartBloc.phoneController.text = phone != null && phone != 'null'
        ? Utils.formatPhoneNumber(phone, toServerFormat: false)
        : '';

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: navigatorKey.currentContext!,
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<CartScreenBloc>.value(value: cartBloc),
            BlocProvider<PersonalDataScreenBloc>.value(
                value: personalDataScreenBloc),
          ],
          child: BlocBuilder<CartScreenBloc, CartScreenState>(
            bloc: cartBloc,
            builder: (context, state) {
              return Scaffold(
                resizeToAvoidBottomInset: true,
                body: CustomBottomSheet(
                  padding: getMarginOrPadding(
                      left: 20, right: 20, top: 8, bottom: 16),
                  color: UiConstants.backgroundColor,
                  child: Expanded(
                    child: Form(
                      key: formKey,
                      child: ListView(
                        controller: scrollController,
                        shrinkWrap: true,
                        children: [
                          Text(
                            cartBloc.state.cartType == TypeReceiving.delivery
                                ? 'Доставка'
                                : 'Самовывоз',
                            style: UiConstants.textStyle1
                                .copyWith(color: UiConstants.darkBlueColor),
                          ),
                          SizedBox(height: 16),
                          if (cartBloc.state.cartType == TypeReceiving.delivery)
                            Padding(
                              padding: getMarginOrPadding(bottom: 16),
                              child: InfoPlateWidget(
                                  text:
                                      'Доставка производится только по Минску и Минскому району'),
                            ),
                          DeliveryCustomerBlock(
                            screenContext: screenContext,
                            firstNameKey: firstNameKey,
                            lastNameKey: lastNameKey,
                            phoneKey: phoneKey,
                            emailKey: emailKey,
                            commentKey: commentKey,
                          ),
                          if (cartBloc.state.cartType == TypeReceiving.delivery)
                            Padding(
                              padding: getMarginOrPadding(top: 16),
                              child: DeliveryAddressBlock(
                                screenContext: screenContext,
                                onPickAddressOnMap: () =>
                                    showSelectAddressOnMapSheet(screenContext,
                                        sheetContext: sheetContext),
                                cityKey: cityKey,
                                streetKey: streetKey,
                              ),
                            ),
                          if (cartBloc.state.cartType == TypeReceiving.delivery)
                            Padding(
                              padding: getMarginOrPadding(top: 16),
                              child: DeliveryPaymentBlock(
                                screenContext: screenContext,
                                changedOnlineMethodTap: () async {
                                  PaymentType? paymentType =
                                      await showPickOnlinePaymentSheet(
                                          screenContext);

                                  if (paymentType != null) {
                                    cartBloc.add(
                                        ChangePaymentTypeEvent(paymentType));
                                  }
                                },
                              ),
                            ),
                          SizedBox(height: 16),
                          SizedBox(
                            height: cartBloc.state.cartType ==
                                        TypeReceiving.pickup ||
                                    (cartBloc.state.cartType ==
                                                TypeReceiving.delivery &&
                                            cartBloc.selectedAddress == null ||
                                        cartBloc.state.deliveryZone ==
                                            DeliveryZoneType.none)
                                ? null
                                : 60,
                            child: AppButtonWidget(
                              textWidget: cartBloc.state.isOrderCompleting
                                  ? Center(
                                      child: CircularProgressIndicator(
                                          color: UiConstants.pink2Color),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Оформить заказ',
                                          style: UiConstants.textStyle3
                                              .copyWith(height: 1),
                                        ),
                                        if (cartBloc.state.cartType ==
                                                TypeReceiving.delivery &&
                                            cartBloc.selectedAddress != null &&
                                            cartBloc.state.deliveryZone !=
                                                DeliveryZoneType.none)
                                          Expanded(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Стоимость доставки - ${cartBloc.state.deliveryPayment}р.',
                                                style: UiConstants.textStyle8
                                                    .copyWith(
                                                        color: UiConstants
                                                            .whiteColor,
                                                        height: 1),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                              isActive: true,
                              onTap: () {
                                if ((formKey.currentState?.validate() ??
                                        false) &&
                                    !cartBloc.state.isOrderCompleting) {
                                  screenContext
                                      .read<CartScreenBloc>()
                                      .add(CreateOrderEvent(
                                        screenContext: screenContext,
                                        callback: () {
                                          personalDataScreenBloc.getProfile();
                                          ordersScreenBloc.add(LoadDataEvent());
                                        },
                                      ));
                                  Navigator.pop(sheetContext);
                                } else {
                                  // Показываем уведомление и скроллим к незаполненным полям
                                  _showDeliveryValidationError(
                                    context,
                                    cartBloc,
                                    firstNameKey,
                                    lastNameKey,
                                    phoneKey,
                                    emailKey,
                                    commentKey,
                                    cityKey,
                                    streetKey,
                                    scrollController,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Future<PaymentType?> showPickOnlinePaymentSheet(
      BuildContext screenContext) async {
    return showModalBottomSheet(
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        return CustomBottomSheet(
          //height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Оплата онлайн',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              SizedBox(height: 16),
              OnlinePaymentMethodButton(
                child: Padding(
                  padding: getMarginOrPadding(top: 10, bottom: 10),
                  child: Row(
                    children: [
                      SvgPicture.asset(Paths.cardIconPath,
                          width: 24, height: 24),
                      SizedBox(width: 8),
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
                  Navigator.pop(sheetContext, PaymentType.bepaid);
                },
              ),
              OnlinePaymentMethodButton(
                child: SvgPicture.asset(Paths.oplatiIconPath),
                onTap: () {
                  Navigator.pop(sheetContext, PaymentType.oplati);
                },
              ),
              OnlinePaymentMethodButton(
                child: Image.asset(Paths.eripIconPath, width: 88, height: 44),
                onTap: () {
                  Navigator.pop(sheetContext, PaymentType.erip);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static showSelectAddressOnMapSheet(BuildContext screenContext,
      {BuildContext? sheetContext}) async {
    // контроллер для адреса
    TextEditingController searchAddressController = TextEditingController();
    // стейт-менеджер для работы с корзиной
    CartScreenBloc cartScreenBloc = screenContext.read<CartScreenBloc>();
    // таймер для задержки по обратному геокодированию
    Timer? debounce;

    // Стейт для отслеживания выбранного адреса
    List<GeoObject?> suggestionObjects = [];

    GeoObject? selectedAddress = cartScreenBloc.selectedAddress;
    searchAddressController.text = selectedAddress
            ?.metaDataProperty?.geocoderMetaData?.address?.formatted ??
        '';

    Future<GeocodeResponse?> zoomToQueryAddress(
      BuildContext context,
      String query,
    ) async {
      if (query.isEmpty) {
        context.read<PharmacyMapBloc>().add(MoveToCurrentLocationEvent());
        return null;
      }

      final geocoderManager = sl<GeocoderManager>();
      final response = await geocoderManager.getGeocodeFromAddress(query);

      double zoom = 12;

      if (response!.firstAddress!.components!
          .any((e) => e.kind == KindResponse.house)) {
        zoom = 20;
      } else if (response.firstAddress!.components!
          .any((e) => e.kind == KindResponse.street)) {
        zoom = 16;
      } else if (response.firstAddress!.components!
          .any((e) => e.kind == KindResponse.locality)) {
        zoom = 12;
      }

      if (context.mounted) {
        context.read<PharmacyMapBloc>().add(
              MoveToPoint(
                zoom: zoom,
                point: ym.Point(
                  latitude: response.firstPoint!.lat,
                  longitude: response.firstPoint!.lon,
                ),
              ),
            );
      }
      return response;
    }

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: sheetContext!,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocProvider(
              create: (mapContext) => PharmacyMapBloc(
                screenContext: screenContext,
                mapScreenType: MapScreenType.order,
                sharedPreferences: sl(),
              )..add(
                  InitPharmacyMapEvent(
                    points: [
                      if (selectedAddress != null)
                        CustomMapObject(
                          mapObject: ym.PlacemarkMapObject(
                            mapId: ym.MapObjectId("213"),
                            point: ym.Point(
                                latitude: selectedAddress!.point!.latitude!,
                                longitude: selectedAddress!.point!.longitude!),
                          ),
                          data: {
                            'address': selectedAddress?.metaDataProperty
                                ?.geocoderMetaData?.address?.formatted,
                            'hasError': cartScreenBloc.state.deliveryZone ==
                                DeliveryZoneType.none
                          },
                        ),
                      ...sl<CourierZoneManager>().mapObjects
                    ],
                  ),
                ),
              child: BlocConsumer<CartScreenBloc, CartScreenState>(
                bloc: cartScreenBloc,
                listener: (context, state) {
                  context.read<PharmacyMapBloc>().add(
                        InitPharmacyMapEvent(
                          points: [
                            if (selectedAddress != null)
                              CustomMapObject(
                                  mapObject: ym.PlacemarkMapObject(
                                    mapId: ym.MapObjectId("213"),
                                    point: ym.Point(
                                        latitude:
                                            selectedAddress!.point!.latitude!,
                                        longitude:
                                            selectedAddress!.point!.longitude!),
                                  ),
                                  data: {
                                    'address': selectedAddress?.metaDataProperty
                                        ?.geocoderMetaData?.address?.formatted,
                                    'hasError':
                                        cartScreenBloc.state.deliveryZone ==
                                            DeliveryZoneType.none
                                  }),
                            ...sl<CourierZoneManager>().mapObjects
                          ],
                        ),
                      );
                },
                builder: (context, state) {
                  return BlocBuilder<PharmacyMapBloc, PharmacyMapState>(
                    builder: (context, state) {
                      return CustomBottomSheet(
                        padding: getMarginOrPadding(
                            left: 20, right: 20, top: 8, bottom: 16),
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
                              SizedBox(height: 16),
                              InfoPlateWidget(
                                  text:
                                      'Доставка производится только по Минску и Минскому району'),
                              SizedBox(height: 16),
                              Skeleton.ignorePointer(
                                child: Skeleton.shade(
                                  child: CitySearchField(
                                    validator: Utils.validate,
                                    hintText: 'Искать улицу или район',
                                    controller: searchAddressController,
                                    suggestionObjects: suggestionObjects,
                                    suggestionFetcher: (query) async {
                                      debounce?.cancel();
                                      if (query.length <= 2) {
                                        zoomToQueryAddress(context, '');
                                        return [];
                                      }

                                      final completer =
                                          Completer<List<String>>();
                                      debounce =
                                          Timer(Duration(milliseconds: 750),
                                              () async {
                                        final geocoderManager =
                                            sl<GeocoderManager>();

                                        List<String> addresses =
                                            await geocoderManager
                                                .getAddressSuggestions(query);

                                        if (addresses.isNotEmpty &&
                                            context.mounted) {
                                          zoomToQueryAddress(
                                              context, addresses.first);
                                        }

                                        setState(() {});

                                        completer.complete(addresses);
                                      });

                                      return completer.future;
                                    },
                                    onSuggestionTap: (p0) async {
                                      GeocodeResponse? response =
                                          await zoomToQueryAddress(context, p0);

                                      if (response != null &&
                                          response.firstAddress != null) {
                                        final geoObject = response
                                            .response
                                            ?.geoObjectCollection
                                            ?.featureMember
                                            ?.first
                                            .geoObject;

                                        // Check if the address contains a "house" component
                                        if (geoObject
                                                ?.metaDataProperty
                                                ?.geocoderMetaData
                                                ?.address
                                                ?.components
                                                ?.any((component) =>
                                                    component.kind ==
                                                    KindResponse.house) ??
                                            false) {
                                          setState(
                                            () {
                                              // Extract the city name from the address components
                                              final cityComponent = geoObject
                                                  ?.metaDataProperty
                                                  ?.geocoderMetaData
                                                  ?.address
                                                  ?.components
                                                  ?.firstWhere((component) =>
                                                      component.kind ==
                                                      KindResponse.locality);

                                              // If the city component exists, assign it to the controller
                                              if (cityComponent != null) {
                                                cartScreenBloc.cityController
                                                    .text = cityComponent
                                                        .name ??
                                                    ''; // Fallback to empty string if name is null
                                              } else {
                                                cartScreenBloc
                                                        .cityController.text =
                                                    ''; // If no city component found, set text to empty string
                                              }

                                              // Extract the street and house number from the address components
                                              final streetComponent = geoObject
                                                  ?.metaDataProperty
                                                  ?.geocoderMetaData
                                                  ?.address
                                                  ?.components
                                                  ?.firstWhere((component) =>
                                                      component.kind ==
                                                      KindResponse.street);

                                              final houseComponent = geoObject
                                                  ?.metaDataProperty
                                                  ?.geocoderMetaData
                                                  ?.address
                                                  ?.components
                                                  ?.firstWhere((component) =>
                                                      component.kind ==
                                                      KindResponse.house);

                                              // Format and assign to streetHomeController
                                              if (streetComponent != null &&
                                                  houseComponent != null) {
                                                cartScreenBloc
                                                        .streetHomeController
                                                        .text =
                                                    '${streetComponent.name}, ${houseComponent.name}';
                                              } else if (streetComponent !=
                                                  null) {
                                                cartScreenBloc
                                                    .streetHomeController
                                                    .text = streetComponent
                                                        .name ??
                                                    ''; // If street found but not house
                                              } else if (houseComponent !=
                                                  null) {
                                                cartScreenBloc
                                                    .streetHomeController
                                                    .text = houseComponent
                                                        .name ??
                                                    ''; // If house found but not street
                                              } else {
                                                cartScreenBloc
                                                        .streetHomeController
                                                        .text =
                                                    ''; // If neither street nor house found
                                              }

                                              cartScreenBloc.selectedAddress =
                                                  geoObject;
                                              selectedAddress = geoObject;

                                              // Set the selected address as well
                                              cartScreenBloc.add(
                                                  UpdateDeliveryPriceEvent(
                                                      address: geoObject));
                                            },
                                          );
                                        }
                                      }
                                    },
                                    onChangeField: (p0) {
                                      setState(
                                        () {
                                          cartScreenBloc.selectedAddress = null;
                                          selectedAddress = null;
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Expanded(
                                child: PharmacyMapWidget(
                                  onTapMap: (point) async {
                                    // ничего не делаем, если пользователь нажал уже на выбранный адрес
                                    if (selectedAddress?.point?.point?.lat ==
                                            point.latitude &&
                                        selectedAddress?.point?.point?.lon ==
                                            point.longitude) {
                                      return;
                                    }
                                    final geocoderManager =
                                        sl<GeocoderManager>();
                                    GeocodeResponse? response =
                                        await geocoderManager
                                            .getGeocodeFromPoint(point.latitude,
                                                point.longitude);

                                    if (response?.firstAddress != null) {
                                      // Update address controllers
                                      final components =
                                          response?.firstAddress?.components ??
                                              [];

                                      // Find city component
                                      final cityComponent =
                                          components.firstWhere(
                                        (component) =>
                                            component.kind ==
                                            KindResponse.locality,
                                        orElse: () => Component(),
                                      );

                                      // Find street component
                                      final streetComponent =
                                          components.firstWhere(
                                        (component) =>
                                            component.kind ==
                                            KindResponse.street,
                                        orElse: () => Component(),
                                      );

                                      // Find house component
                                      final houseComponent =
                                          components.firstWhere(
                                        (component) =>
                                            component.kind ==
                                            KindResponse.house,
                                        orElse: () => Component(),
                                      );

                                      setState(() {
                                        // Update city controller
                                        cartScreenBloc.cityController.text =
                                            cityComponent.name ?? '';

                                        // Update street and house controller
                                        if (streetComponent.name != null &&
                                            houseComponent.name != null) {
                                          cartScreenBloc
                                                  .streetHomeController.text =
                                              '${streetComponent.name}, ${houseComponent.name}';
                                        } else if (streetComponent.name !=
                                            null) {
                                          cartScreenBloc
                                                  .streetHomeController.text =
                                              streetComponent.name ?? '';
                                        } else if (houseComponent.name !=
                                            null) {
                                          cartScreenBloc.streetHomeController
                                              .text = houseComponent.name ?? '';
                                        } else {
                                          cartScreenBloc
                                              .streetHomeController.text = '';
                                        }

                                        // Update search address controller with formatted address
                                        searchAddressController.text =
                                            response?.firstAddress?.formatted ??
                                                '';

                                        selectedAddress = response
                                            ?.response
                                            ?.geoObjectCollection
                                            ?.featureMember
                                            ?.first
                                            .geoObject;

                                        cartScreenBloc.selectedAddress =
                                            selectedAddress;

                                        // Update delivery price
                                        cartScreenBloc.add(
                                            UpdateDeliveryPriceEvent(
                                                address: selectedAddress));
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 16),
                              CourierDeliveryZoneItem(
                                  title: 'Зелёная зона',
                                  subtitle:
                                      'Бесплатно — для заказов от 40 руб.\nПлатно — для заказов до 40 руб.',
                                  deliveryZoneType: DeliveryZoneType.green),
                              SizedBox(height: 16),
                              CourierDeliveryZoneItem(
                                  title: 'Желтая зона',
                                  subtitle: 'Платная доставка',
                                  deliveryZoneType: DeliveryZoneType.yellow),
                              SizedBox(height: 16),
                              if (selectedAddress != null &&
                                  cartScreenBloc.state.deliveryZone !=
                                      DeliveryZoneType.none)
                                AppButtonWidget(
                                  text: 'Подтвердить',
                                  isActive: true,
                                  onTap: () =>
                                      Navigator.pop(UiConstants.homeContext!),
                                )
                              else
                                AppButtonWidget(
                                  text: 'Оформить самовывоз',
                                  isActive: true,
                                  onTap: () =>
                                      Navigator.pop(UiConstants.homeContext!),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  static showThanksForOrderSheet(
      BuildContext screenContext, OrderEntity order) {
    CartScreenBloc cartBloc = screenContext.read<CartScreenBloc>();
    HomeScreenBloc homeBloc = screenContext.read<HomeScreenBloc>();

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: true,
      context: screenContext,
      builder: (sheetContext) {
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
                SizedBox(height: 8),
                Text(
                  '${order.typeReceipt == TypeReceiving.pickup ? 'Проверим наличие и свяжемся в случае отсутствия товаров.\n\n' : ''}Статус заказов можно отслеживать в профиле в разделе «Заказы».',
                  style: UiConstants.textStyle2.copyWith(
                    color: UiConstants.darkBlue2Color.withOpacity(.6),
                  ),
                ),
                SizedBox(height: 16),
                ProductsListWidget(
                    title: 'Товары',
                    products: order.products ?? [],
                    productsListScreenType: ProductsListScreenType.order,
                    screenContext: screenContext),
                SizedBox(height: 16),
                Text(
                  'Информация о заказе',
                  style: UiConstants.textStyle5
                      .copyWith(color: UiConstants.darkBlueColor),
                ),
                SizedBox(height: 8),
                Container(
                  padding: getMarginOrPadding(all: 16),
                  decoration: BoxDecoration(
                    color: UiConstants.whiteColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: OrderInfoList(
                    pharmacy: order.pharmacy,
                    order: order,
                    address:
                        "${cartBloc.cityController.text}, ${cartBloc.streetHomeController.text}",
                  ),
                ),
                SizedBox(height: 32),
                AppButtonWidget(
                  text: 'К списку заказов',
                  isActive: true,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    homeBloc.add(ChangePageEvent(3, forcePopToRoot: true));
                    await Future.delayed(Duration(milliseconds: 300));
                    homeBloc.navigatorKeys[3].currentState!.push(
                      Routes.createRoute(
                        OrdersScreen(),
                        settings: RouteSettings(name: Routes.ordersScreen),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static showSelectPharmacySheet(BuildContext screenContext) {
    CartScreenBloc cartBloc = screenContext.read<CartScreenBloc>();
    TextEditingController queryController = TextEditingController();

    // таймер для задержки по обратному геокодированию
    Timer? debounce;

    Future<GeocodeResponse?> zoomToQueryAddress(
      BuildContext context,
      String query,
    ) async {
      if (query.isEmpty) {
        context.read<PharmacyMapBloc>().add(MoveToCurrentLocationEvent());
        return null;
      }

      final geocoderManager = sl<GeocoderManager>();
      final response = await geocoderManager.getGeocodeFromAddress(query);

      double zoom = 12;

      if (response!.firstAddress!.components!
          .any((e) => e.kind == KindResponse.house)) {
        zoom = 20;
      } else if (response.firstAddress!.components!
          .any((e) => e.kind == KindResponse.street)) {
        zoom = 16;
      } else if (response.firstAddress!.components!
          .any((e) => e.kind == KindResponse.locality)) {
        zoom = 12;
      }

      if (context.mounted) {
        context.read<PharmacyMapBloc>().add(
              MoveToPoint(
                zoom: zoom,
                point: ym.Point(
                  latitude: response.firstPoint!.lat,
                  longitude: response.firstPoint!.lon,
                ),
              ),
            );
      }
      return response;
    }

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: true,
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        int selectorIndex = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocBuilder<CartScreenBloc, CartScreenState>(
              bloc: cartBloc,
              builder: (context, cartState) {
                return CustomBottomSheet(
                  padding: getMarginOrPadding(
                      left: 20, right: 20, top: 8, bottom: 0),
                  color: UiConstants.whiteColor,
                  child: Expanded(
                    child: BlocProvider(
                      create: (context) => SelectorCubit(index: selectorIndex),
                      child: BlocBuilder<SelectorCubit, SelectorState>(
                        builder: (context, state) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => PharmaciesCartScreenBloc(
                                    getCartPharmaciesUC: sl(),
                                    context: screenContext)
                                  ..add(LoadPharmaciesCartDataEvent(
                                      products: cartState.cartData!.products
                                          // это выбрет только те товары, которые отмчены, а так же те, которых нет в наличии
                                          .where((e) =>
                                              cartState.selectedProductIds
                                                  .contains(e.productId) ||
                                              e.availability == 'absent')
                                          .map(
                                            (toElement) =>
                                                CartPharmaciesProductParam(
                                              productId: toElement.productId,
                                              quantity: (toElement
                                                          .requestedQuantity ??
                                                      toElement.quantity ??
                                                      1)
                                                  .clamp(1, double.infinity)
                                                  .toInt(),
                                            ),
                                          )
                                          .toList())),
                              ),
                              BlocProvider(
                                create: (context) => PharmacyMapBloc(
                                    screenContext: screenContext,
                                    sharedPreferences: sl(),
                                    mapScreenType: MapScreenType.cart),
                              ),
                            ],
                            child: BlocConsumer<PharmaciesCartScreenBloc,
                                PharmaciesCartScreenState>(
                              listener: (context, state) async {
                                await Future.delayed(
                                    Duration(milliseconds: 300));
                                context.read<PharmacyMapBloc>().add(
                                      InitPharmacyMapEvent(
                                          points: state.mapObjects),
                                    );
                              },
                              builder: (context, state) {
                                final pharmaciesBloc =
                                    context.read<PharmaciesCartScreenBloc>();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Самовывоз',
                                      style: UiConstants.textStyle1.copyWith(
                                          color: UiConstants.darkBlueColor),
                                    ),
                                    SizedBox(height: 16),
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
                                            showPharmacySort2Sheet(context),
                                        onChangedField: (value) {
                                          pharmaciesBloc.add(
                                            ChangePharmacyCartQueryEvent(value),
                                          );

                                          debounce?.cancel();
                                          debounce?.cancel();
                                          if (value.length <= 2) {
                                            zoomToQueryAddress(context, '');
                                            return [];
                                          }

                                          debounce =
                                              Timer(Duration(milliseconds: 750),
                                                  () async {
                                            final geocoderManager =
                                                sl<GeocoderManager>();

                                            List<String> addresses =
                                                await geocoderManager
                                                    .getAddressSuggestions(
                                                        value);

                                            if (addresses.isNotEmpty &&
                                                context.mounted) {
                                              zoomToQueryAddress(
                                                  context, addresses.first);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                    Align(
                                      alignment: AlignmentDirectional.center,
                                      child: Selector(
                                        titlesList: const ['Список', 'Карта'],
                                        selectedIndex: selectorIndex,
                                        onTap: (index) => setState(() {
                                          selectorIndex = index;
                                        }),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Expanded(
                                      child: state.isLoading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : selectorIndex == 0
                                              ? state.filteredPharmacies.isEmpty
                                                  ? Center(
                                                      child: Text(
                                                        'По выбранным фильтрам аптек нет',
                                                        style: UiConstants
                                                            .textStyle3
                                                            .copyWith(
                                                                color: UiConstants
                                                                    .darkBlueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                      ),
                                                    )
                                                  : ListView.separated(
                                                      padding:
                                                          getMarginOrPadding(
                                                              bottom: 16),
                                                      shrinkWrap: true,
                                                      itemBuilder: (context,
                                                              index) =>
                                                          CartPharmacyWidget(
                                                              pharmacy:
                                                                  state.filteredPharmacies[
                                                                      index],
                                                              onButtonTap: () =>
                                                                  showPharmacySheet(
                                                                    screenContext,
                                                                    state.filteredPharmacies[
                                                                        index],
                                                                  ),
                                                              screenContext:
                                                                  screenContext,
                                                              isShowAvailableCount:
                                                                  true),
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              SizedBox(
                                                                  height: 8),
                                                      itemCount: state
                                                          .filteredPharmacies
                                                          .length)
                                              : Padding(
                                                  padding: getMarginOrPadding(
                                                      bottom: 16),
                                                  child: PharmacyMapWidget(),
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
      },
    );
  }

  static showPharmacySheet(
      BuildContext screenContext, CartPharmacyEntity pharmacy) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: true,
      context: screenContext,
      builder: (sheetContext) {
        CartScreenBloc cartBloc = screenContext.read<CartScreenBloc>();

        return BlocBuilder<CartScreenBloc, CartScreenState>(
          bloc: cartBloc,
          builder: (context, state) {
            // Разделяем по наличию
            final inStockProducts = <CartPharmaciesProductEntity>[];
            final outOfStockProducts = <CartPharmaciesProductEntity>[];

            for (final product in pharmacy.products) {
              if (product.stockCount != 0) {
                inStockProducts.add(product);
              } else {
                outOfStockProducts.add(product);
              }
            }

            return CustomBottomSheet(
              padding: getMarginOrPadding(left: 20, right: 20, top: 8),
              color: UiConstants.backgroundColor,
              child: Expanded(
                child: ListView(
                  padding: getMarginOrPadding(bottom: 94),
                  shrinkWrap: true,
                  children: [
                    Text(
                      pharmacy.pharmacyName,
                      style: UiConstants.textStyle3
                          .copyWith(color: UiConstants.darkBlueColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      pharmacy.address ?? '-',
                      style: UiConstants.textStyle2.copyWith(
                        color: UiConstants.darkBlueColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    PharmacyAvailableProductsChip(
                        allProductsAvailable: pharmacy.availability == 'full'),
                    SizedBox(height: 32),
                    // список с законченными товарами
                    if (outOfStockProducts.isNotEmpty)
                      Padding(
                        padding: getMarginOrPadding(bottom: 32),
                        child: ProductsListWidget(
                            title: 'Товары закончились',
                            subtitle:
                                'Эти товары останутся в корзине, их можно будет оформить отдельным заказом в другой аптеке.',
                            products: outOfStockProducts,
                            screenContext: screenContext,
                            productsListScreenType:
                                ProductsListScreenType.pharmacy),
                      ),
                    ProductsListWidget(
                        title: 'В наличии',
                        products: inStockProducts,
                        screenContext: screenContext,
                        productsListScreenType:
                            ProductsListScreenType.pharmacy),
                    // подсчёт стоимости
                    if ((cartBloc.state.cartData?.products ?? []).isNotEmpty)
                      Padding(
                        padding: getMarginOrPadding(bottom: 16, top: 16),
                        child: SummaryPharmacyPricesBlock(
                            pharmacy: pharmacy, screenContext: screenContext),
                      ),

                    AppButtonWidget(
                      text: 'Заберу отсюда',
                      isActive: true,
                      onTap: () {
                        cartBloc.add(SelectPharmacy(pharmacy.pharmacyId));
                        Navigator.pop(sheetContext);
                        Navigator.pop(UiConstants.homeContext!);
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

  static Future<bool?> showProductReceiptNotificationSheet() {
    return showModalBottomSheet<bool?>(
      context: navigatorKey.currentContext!,
      useRootNavigator: true,
      builder: (sheetContext) {
        return CustomBottomSheet(
          //height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Мы сообщим вам о поступлении данного товара пуш‑уведомлением',
                style: UiConstants.textStyle5
                    .copyWith(color: UiConstants.darkBlueColor),
              ),
              32.ph,
              AppButtonWidget(
                text: 'Продолжить покупки',
                onTap: () => Navigator.pop(sheetContext, true),
              ),
            ],
          ),
        );
      },
    );
  }

  static showConfirmationCodeSheet(BuildContext screenContext,
      PersonalDataScreenBloc personalDataBloc) async {
    final bloc = screenContext.read<CodeScreenBloc>();

    showModalBottomSheet(
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        return BlocBuilder<CodeScreenBloc, CodeScreenState>(
          bloc: bloc,
          builder: (context, state) {
            return CustomBottomSheet(
              // height: 365,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Введите код подтверждения',
                    style: UiConstants.textStyle5
                        .copyWith(color: UiConstants.darkBlueColor),
                  ),
                  SizedBox(height: 8),
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
                  SizedBox(height: 32),
                  Center(
                    child: PinputWidget(
                        controller: bloc.codeController,
                        focusNode: bloc.codeFocusNode,
                        showError: bloc.state.showError),
                  ),
                  SizedBox(height: 32),
                  AppButtonWidget(
                    isActive: bloc.state.isButtonActive,
                    text: 'Подтвердить',
                    onTap: () => bloc.add(SubmitCodeEvent()),
                  ),
                  SizedBox(height: 16),
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

  static showProductsFilterSheet(BuildContext screenContext,
      {ProductsScreenBloc? productsScreenBloc}) {
    ProductsScreenBloc productsScreenBloc =
        screenContext.read<ProductsScreenBloc>();
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: UiConstants.homeContext!,
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
                          onTap: () {
                            productsScreenBloc.add(ClearEvent());
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Сбросить',
                            style: UiConstants.textStyle3.copyWith(
                              color: UiConstants.darkBlue2Color.withOpacity(.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    PriceRangeWidget(screenContext: screenContext),
                    SizedBox(height: 11),
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
                    SizedBox(height: 16),
                    DropdownBlockTemplate(
                      title: 'Производитель',
                      groupByFirstLetter: true,
                      child: state.manufacturers,
                      selectedItems: state.selectedManufacturers,
                      onChanged: (item, isChecked) => productsScreenBloc.add(
                        SelectManufacturerEvent(item, isChecked),
                      ),
                    ),
                    SizedBox(height: 16),
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
                      text: 'Есть в наличии',
                      isChecked: state.isAvailable,
                      onChanged: (isChecked) => productsScreenBloc.add(
                        ToggleAvailableEvent(isChecked),
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownBlockItem(
                      text: 'Без рецепта',
                      isChecked: state.isWithoutPrescription,
                      onChanged: (isChecked) => productsScreenBloc.add(
                        ToggleWithoutPrescriptionEvent(isChecked),
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownBlockItem(
                      text: 'Участвует в акции',
                      isChecked: state.isParticipatesInCampaign,
                      onChanged: (isChecked) => productsScreenBloc.add(
                        ToggleParticipatesInCampaignEvent(isChecked),
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownBlockItem(
                      text: 'Возможна доставка',
                      isChecked: state.isDeliveryPossible,
                      onChanged: (isChecked) => productsScreenBloc.add(
                        ToggleDeliveryPossibleEvent(isChecked),
                      ),
                    ),
                    SizedBox(height: 16),
                    AppButtonWidget(
                      text: 'Показать результаты',
                      onTap: () {
                        productsScreenBloc.add(ChangeProductSortTypeEvent());

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

  static showProductSortSheet(BuildContext screenContext) {
    showModalBottomSheet(
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        ProductsScreenBloc productsBloc =
            screenContext.read<ProductsScreenBloc>();
        return BlocBuilder<ProductsScreenBloc, ProductsScreenState>(
          bloc: productsBloc,
          builder: (context, state) {
            return CustomBottomSheet(
              //height: 210,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сортировка',
                    style: UiConstants.textStyle5
                        .copyWith(color: UiConstants.darkBlueColor),
                  ),
                  SizedBox(height: 16),
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
                            ChangeProductSortTypeEvent(
                                productSortType: sortType),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(height: 8),
                      itemCount: ProductSortType.values.length)
                ],
              ),
            );
          },
        );
      },
    );
  }

  static showPharmacySortSheet(
      BuildContext homeContext, BuildContext screenContext,
      {required ProductEntity product}) {
    showModalBottomSheet(
      context: homeContext,
      builder: (sheetContext) {
        PharmaciesScreenBloc pharmaciesBloc =
            screenContext.read<PharmaciesScreenBloc>();

        // Check if product is prescription or alcohol-containing
        bool isRestrictedProduct = product.isRecipe || product.isAlcohol;

        // If it's a restricted product, set pickup as default and disable other options
        if (isRestrictedProduct &&
            pharmaciesBloc.state.pharmacySortType != TypeReceiving.pickup) {
          pharmaciesBloc.add(ChangePharmacySortTypeEvent(TypeReceiving.pickup));
        }

        return BlocBuilder<PharmaciesScreenBloc, PharmaciesScreenState>(
          bloc: pharmaciesBloc,
          builder: (context, state) {
            return CustomBottomSheet(
              //height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Фильтр',
                    style: UiConstants.textStyle5
                        .copyWith(color: UiConstants.darkBlueColor),
                  ),
                  SizedBox(height: 16),
                  Opacity(
                    opacity: isRestrictedProduct ? 0.5 : 1.0,
                    child: CustomRadioButton(
                      isAvailable: !isRestrictedProduct,
                      isLabelOnLeft: true,
                      title: 'Все способы получения',
                      textStyle: UiConstants.textStyle2,
                      value: TypeReceiving.all,
                      groupValue: state.pharmacySortType,
                      onChanged: () => pharmaciesBloc.add(
                        ChangePharmacySortTypeEvent(TypeReceiving.all),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
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
                  SizedBox(height: 8),
                  Opacity(
                    opacity: isRestrictedProduct ? 0.5 : 1.0,
                    child: CustomRadioButton(
                      isAvailable: !isRestrictedProduct,
                      isLabelOnLeft: true,
                      title: 'Доставка',
                      textStyle: UiConstants.textStyle2,
                      value: TypeReceiving.delivery,
                      groupValue: state.pharmacySortType,
                      onChanged: () => pharmaciesBloc.add(
                        ChangePharmacySortTypeEvent(TypeReceiving.delivery),
                      ),
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

  static showPharmacySort2Sheet(BuildContext screenContext) {
    showModalBottomSheet(
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        PharmaciesCartScreenBloc pharmaciesBloc =
            screenContext.read<PharmaciesCartScreenBloc>();
        return BlocBuilder<PharmaciesCartScreenBloc, PharmaciesCartScreenState>(
          bloc: pharmaciesBloc,
          builder: (context, state) {
            return CustomBottomSheet(
              //height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Фильтр',
                    style: UiConstants.textStyle5
                        .copyWith(color: UiConstants.darkBlueColor),
                  ),
                  SizedBox(height: 16),
                  CustomCheckbox(
                    title: Text(
                      'Работает сейчас',
                      style: UiConstants.textStyle11
                          .copyWith(color: UiConstants.darkBlueColor),
                    ),
                    textStyle: UiConstants.textStyle2,
                    isChecked: pharmaciesBloc.state.showWorkingNowOnly,
                    onChanged: (isChecked) => pharmaciesBloc.add(
                      ToggleShowWorkingNowOnlyEvent(isChecked ?? false),
                    ),
                  ),
                  SizedBox(height: 8),
                  CustomCheckbox(
                    title: Text(
                      'Все товары в наличии',
                      style: UiConstants.textStyle11
                          .copyWith(color: UiConstants.darkBlueColor),
                    ),
                    textStyle: UiConstants.textStyle2,
                    isChecked: pharmaciesBloc.state.showWithAllProductsOnly,
                    onChanged: (isChecked) => pharmaciesBloc.add(
                      ToggleShowWithAllProductsOnlyEvent(isChecked ?? false),
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
                          onTap: () {
                            ordersBloc.add(ClearFilterEvent());
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Сбросить',
                            style: UiConstants.textStyle3.copyWith(
                              color: UiConstants.darkBlue2Color.withOpacity(.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
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
                    SizedBox(height: 16),
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
                    SizedBox(height: 16),
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
                              suffixWidget:
                                  SvgPicture.asset(Paths.calendarIconPath),
                              contentPadding:
                                  getMarginOrPadding(left: 12, right: 12),
                              onChangedField: (value) => validateDates(),
                            ),
                          ),
                          SizedBox(width: 8),
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
                              suffixWidget:
                                  SvgPicture.asset(Paths.calendarIconPath),
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

  static showPharmacyInfoSheet(PharmacyEntity pharmacy) {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: UiConstants.homeContext!,
      builder: (sheetContext) {
        return CustomBottomSheet(
          padding: EdgeInsets.zero,
          //height: 230,
          child: ProductPharmacyWidget(pharmacy: pharmacy),
        );
      },
    );
  }

  // Функция для показа уведомления о незаполненных полях в delivery sheet
  static void _showDeliveryValidationError(
    BuildContext context,
    CartScreenBloc cartBloc,
    GlobalKey firstNameKey,
    GlobalKey lastNameKey,
    GlobalKey phoneKey,
    GlobalKey emailKey,
    GlobalKey commentKey,
    GlobalKey cityKey,
    GlobalKey streetKey,
    ScrollController scrollController,
  ) {
    List<String> emptyFields = [];

    // Проверяем обязательные поля
    if (cartBloc.fNameController.text.trim().isEmpty) {
      emptyFields.add('Имя');
    }
    if (cartBloc.sNameController.text.trim().isEmpty) {
      emptyFields.add('Фамилия');
    }
    if (cartBloc.phoneController.text.trim().isEmpty ||
        !Utils.phoneRegexp.hasMatch(cartBloc.phoneController.text)) {
      emptyFields.add('Телефон');
    }

    // Email обязателен только при онлайн оплате
    if (cartBloc.state.paymentType != PaymentType.courier) {
      if (cartBloc.emailController.text.trim().isEmpty ||
          Utils.emailValidate(cartBloc.emailController.text) != null) {
        emptyFields.add('Email');
      }
    }

    // Проверяем поля адреса только при доставке
    if (cartBloc.state.cartType == TypeReceiving.delivery) {
      if (cartBloc.cityController.text.trim().isEmpty) {
        emptyFields.add('Город');
      }
      if (cartBloc.streetHomeController.text.trim().isEmpty ||
          cartBloc.selectedAddress == null ||
          cartBloc.state.deliveryZone == DeliveryZoneType.none) {
        emptyFields.add('Улица, дом');
      }
    }

    if (emptyFields.isNotEmpty) {
      ValidationHelper.showValidationError(
        context,
        emptyFields: emptyFields,
        onShowFields: () {
          // Скроллим к первому незаполненному полю
          List<GlobalKey> fieldKeys = [
            firstNameKey,
            lastNameKey,
            phoneKey,
            emailKey
          ];
          List<bool Function()> validationChecks = [
            () => cartBloc.fNameController.text.trim().isEmpty,
            () => cartBloc.sNameController.text.trim().isEmpty,
            () =>
                cartBloc.phoneController.text.trim().isEmpty ||
                !Utils.phoneRegexp.hasMatch(cartBloc.phoneController.text),
            () =>
                cartBloc.state.paymentType != PaymentType.courier &&
                (cartBloc.emailController.text.trim().isEmpty ||
                    Utils.emailValidate(cartBloc.emailController.text) != null),
          ];

          // Добавляем поля адреса только при доставке
          if (cartBloc.state.cartType == TypeReceiving.delivery) {
            fieldKeys.addAll([cityKey, streetKey]);
            validationChecks.addAll([
              () => cartBloc.cityController.text.trim().isEmpty,
              () =>
                  cartBloc.streetHomeController.text.trim().isEmpty ||
                  cartBloc.selectedAddress == null ||
                  cartBloc.state.deliveryZone == DeliveryZoneType.none,
            ]);
          }

          ValidationHelper.scrollToFirstEmptyField(
            context,
            fieldKeys,
            validationChecks,
            scrollController,
          );
        },
      );
    }
  }
}
