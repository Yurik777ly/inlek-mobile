import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/delivery_address_helper.dart';
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
    this.scrollController,
  });

  final BuildContext screenContext;
  final Function() onPickAddressOnMap;
  final GlobalKey? cityKey;
  final GlobalKey? streetKey;
  final ScrollController? scrollController;

  @override
  State<DeliveryAddressBlock> createState() => _DeliveryAddressBlockState();
}

class _DeliveryAddressBlockState extends State<DeliveryAddressBlock> {
  // таймер для задержки по обратному геокодированию
  Timer? debounce;

  // Стейт для отслеживания выбранного адреса
  List<GeoObject?> suggestionObjects = [];
  GeoObject? selectedAddress;

  // FocusNode для поля "Улица, дом"
  late FocusNode streetFocusNode;

  @override
  void initState() {
    super.initState();
    streetFocusNode = FocusNode();
    streetFocusNode.addListener(_onStreetFocusChange);
  }

  @override
  void dispose() {
    streetFocusNode.removeListener(_onStreetFocusChange);
    streetFocusNode.dispose();
    debounce?.cancel();
    super.dispose();
  }

  void _onStreetFocusChange() {
    if (streetFocusNode.hasFocus && widget.scrollController != null) {
      // Увеличиваем задержку для корректного скролла после появления клавиатуры
      Future.delayed(Duration(milliseconds: 600), () {
        if (widget.scrollController!.hasClients) {
          // Находим позицию поля "Город" и скроллим к нему
          if (widget.cityKey?.currentContext != null) {
            final RenderBox? renderBox = widget.cityKey!.currentContext!
                .findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final position = renderBox.localToGlobal(Offset.zero);
              final scrollPosition = widget.scrollController!.position;

              // Вычисляем позицию для скролла (поле "Город" вверху экрана)
              final targetOffset = scrollPosition.pixels +
                  position.dy -
                  100; // 100px отступ сверху

              widget.scrollController!.animateTo(
                targetOffset.clamp(0.0, scrollPosition.maxScrollExtent),
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          }
        }
      });
    }
  }

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
        SizedBox(height: 8),
        Container(
          padding: getMarginOrPadding(all: 16),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(16),
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
              SizedBox(height: 24),
              OptimizedFormField(
                fieldKey: widget.streetKey,
                child: CitySearchField(
                  title: 'Улица, дом',
                  hintText: 'Укажите адрес',
                  controller: cartBloc.streetHomeController,
                  fillColor: UiConstants.white3Color,
                  focusNode: streetFocusNode,
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
                  minFetcherLength: 2,
                  suggestionObjects: suggestionObjects,
                  suggestionFetcher: (query) async {
                    debounce?.cancel();
                    if (query.trim().length < 2) {
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
                    DeliveryAddressHelper.setControllerText(
                      cartBloc.streetHomeController,
                      p0,
                    );

                    final geocoderManager = sl<GeocoderManager>();
                    final response =
                        await geocoderManager.getGeocodeFromAddress(p0);

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      DeliveryAddressHelper.applyFromResponse(
                        cartBloc: cartBloc,
                        response: response,
                        selectedAddressText: p0,
                      );
                      selectedAddress =
                          DeliveryAddressHelper.geoObjectFromResponse(response);
                    });
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
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppTextFieldWidget(
                        title: 'Подъезд',
                        hintText: 'Не указано',
                        controller: cartBloc.entranceController),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: AppTextFieldWidget(
                        title: 'Этаж',
                        hintText: 'Не указано',
                        controller: cartBloc.floorController),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppTextFieldWidget(
                        title: 'Квартира',
                        hintText: 'Не указано',
                        controller: cartBloc.flatController),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: AppTextFieldWidget(
                        title: 'Домофон',
                        hintText: 'Не указано',
                        controller: cartBloc.doorPhoneController),
                  ),
                ],
              ),
              SizedBox(height: 24),
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
