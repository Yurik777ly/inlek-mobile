import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/geocoder_manager.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';
import 'package:inlek/features/presentation/widgets/select_region_screen/city_search_field.dart';
import 'package:inlek/features/presentation/widgets/validation_helper_widget.dart';
import 'package:inlek/locator_service.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

class DeliveryAddressBlock extends StatefulWidget {
  const DeliveryAddressBlock({
    super.key,
    required this.screenContext,
    required this.onPickAddressOnMap,
    this.cityKey,
    this.streetKey,
  });

  final BuildContext screenContext;
  final Function() onPickAddressOnMap;
  final GlobalKey? cityKey;
  final GlobalKey? streetKey;

  @override
  State<DeliveryAddressBlock> createState() => _DeliveryAddressBlockState();
}

class _DeliveryAddressBlockState extends State<DeliveryAddressBlock> {
  // таймер для задержки по обратному геокодированию
  Timer? debounce;

  // Стейт для отслеживания выбранного адреса
  List<GeoObject?> suggestionObjects = [];
  GeoObject? selectedAddress;

  @override
  Widget build(BuildContext context) {
    final cartBloc = widget.screenContext.read<CartScreenBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. Адрес',
          style:
              UiConstants.textStyle5.copyWith(color: UiConstants.darkBlueColor),
        ),
        SizedBox(height: 8.dp),
        Container(
          padding: getMarginOrPadding(all: 16),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              OptimizedFormField(
                fieldKey: widget.cityKey,
                child: AppTextFieldWidget(
                    title: 'Город',
                    actionTitle: 'Выбрать на карте',
                    onTapActionTitle: widget.onPickAddressOnMap,
                    hintText: 'Укажите город',
                    controller: cartBloc.cityController,
                    validator: Utils.validate),
              ),
              SizedBox(height: 24.dp),
              OptimizedFormField(
                fieldKey: widget.streetKey,
                child: CitySearchField(
                  title: 'Улица, дом',
                  hintText: 'Укажите адрес',
                  widthOverlay: MediaQuery.of(context).size.width - 72.dp,
                  offset: const Offset(0, 80),
                  controller: cartBloc.streetHomeController,
                  validator: (p0) {
                    String? error = Utils.validate(p0);
                    if (error == null) {
                      if (cartBloc.selectedAddress == null ||
                          cartBloc.state.deliveryZone ==
                              DeliveryZoneType.none) {
                        error = 'Сюда пока не доставляем';
                      }
                    }

                    return error;
                  },
                  hasSearchWidget: false,
                  suggestionObjects: suggestionObjects,
                  suggestionFetcher: (query) async {
                    debounce?.cancel();
                    if (query.length <= 2) {
                      return [];
                    }

                    final completer = Completer<List<String>>();
                    debounce = Timer(Duration(milliseconds: 750), () async {
                      final geocoderManager = sl<GeocoderManager>();

                      List<String> addresses =
                          await geocoderManager.getAddressSuggestions(query);

                      setState(() {});

                      completer.complete(addresses);
                    });

                    return completer.future;
                  },
                  onSuggestionTap: (p0) async {
                    final geocoderManager = sl<GeocoderManager>();
                    final response =
                        await geocoderManager.getGeocodeFromAddress(p0);

                    if (response != null && response.firstAddress != null) {
                      final geoObject = response.response?.geoObjectCollection
                          ?.featureMember?.first.geoObject;

                      // Check if the address contains a "house" component
                      if (geoObject?.metaDataProperty?.geocoderMetaData?.address
                              ?.components
                              ?.any((component) =>
                                  component.kind == KindResponse.house) ??
                          false) {
                        setState(
                          () {
                            // Extract the city name from the address components
                            final cityComponent = geoObject?.metaDataProperty
                                ?.geocoderMetaData?.address?.components
                                ?.firstWhere((component) =>
                                    component.kind == KindResponse.locality);

                            // If the city component exists, assign it to the controller
                            if (cityComponent != null) {
                              cartBloc.cityController.text = cityComponent
                                      .name ??
                                  ''; // Fallback to empty string if name is null
                            } else {
                              cartBloc.cityController.text =
                                  ''; // If no city component found, set text to empty string
                            }

                            // Extract the street and house number from the address components
                            final streetComponent = geoObject?.metaDataProperty
                                ?.geocoderMetaData?.address?.components
                                ?.firstWhere((component) =>
                                    component.kind == KindResponse.street);

                            final houseComponent = geoObject?.metaDataProperty
                                ?.geocoderMetaData?.address?.components
                                ?.firstWhere((component) =>
                                    component.kind == KindResponse.house);

                            // Format and assign to streetHomeController
                            if (streetComponent != null &&
                                houseComponent != null) {
                              cartBloc.streetHomeController.text =
                                  '${streetComponent.name}, ${houseComponent.name}';
                            } else if (streetComponent != null) {
                              cartBloc.streetHomeController.text =
                                  streetComponent.name ??
                                      ''; // If street found but not house
                            } else if (houseComponent != null) {
                              cartBloc.streetHomeController.text =
                                  houseComponent.name ??
                                      ''; // If house found but not street
                            } else {
                              cartBloc.streetHomeController.text =
                                  ''; // If neither street nor house found
                            }

                            selectedAddress = geoObject;
                            cartBloc.selectedAddress = geoObject;

                            // Set the selected address as well
                            cartBloc.add(
                                UpdateDeliveryPriceEvent(address: geoObject));
                          },
                        );
                      }
                    }
                  },
                  onChangeField: (p0) {
                    setState(
                      () {
                        cartBloc.selectedAddress = null;
                        selectedAddress = null;
                        cartBloc.add(UpdateDeliveryPriceEvent());
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 24.dp),
              Row(
                children: [
                  Expanded(
                    child: AppTextFieldWidget(
                        title: 'Подъезд',
                        hintText: 'Не указано',
                        controller: cartBloc.entranceController),
                  ),
                  SizedBox(width: 8.dp),
                  Expanded(
                    child: AppTextFieldWidget(
                        title: 'Этаж',
                        hintText: 'Не указано',
                        controller: cartBloc.floorController),
                  ),
                ],
              ),
              SizedBox(height: 24.dp),
              Row(
                children: [
                  Expanded(
                    child: AppTextFieldWidget(
                        title: 'Квартира',
                        hintText: 'Не указано',
                        controller: cartBloc.flatController),
                  ),
                  SizedBox(width: 8.dp),
                  Expanded(
                    child: AppTextFieldWidget(
                        title: 'Домофон',
                        hintText: 'Не указано',
                        controller: cartBloc.doorPhoneController),
                  ),
                ],
              ),
              SizedBox(height: 24.dp),
              AppTextFieldWidget(
                  title: 'Комментарий к заказу',
                  hintText: 'Укажите, что необходимо учесть при доставке',
                  controller: cartBloc.commentController,
                  minLines: 4)
            ],
          ),
        ),
      ],
    );
  }
}
