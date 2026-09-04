import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

class DeliveryAddressHelper {
  static GeoObject? geoObjectFromResponse(GeocodeResponse? response) {
    return response
        ?.response?.geoObjectCollection?.featureMember?.firstOrNull?.geoObject;
  }

  static List<Component> componentsFromGeoObject(GeoObject? geoObject) {
    return geoObject
            ?.metaDataProperty?.geocoderMetaData?.address?.components ??
        [];
  }

  static String? formattedAddress(GeoObject? geoObject) {
    return geoObject?.metaDataProperty?.geocoderMetaData?.address?.formatted;
  }

  static void setControllerText(TextEditingController controller, String text) {
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  static void applyToCart({
    required CartScreenBloc cartBloc,
    required GeoObject? geoObject,
    TextEditingController? searchAddressController,
    String? formattedOverride,
  }) {
    final components = componentsFromGeoObject(geoObject);
    final formatted = formattedOverride ?? formattedAddress(geoObject);

    if (geoObject == null && (formatted == null || formatted.isEmpty)) {
      return;
    }

    final city = components
            .firstWhereOrNull((c) => c.kind == KindResponse.locality)
            ?.name ??
        components
            .firstWhereOrNull((c) => c.kind == KindResponse.district)
            ?.name ??
        _cityFromFormatted(formatted);

    final street =
        components.firstWhereOrNull((c) => c.kind == KindResponse.street)?.name;
    final house =
        components.firstWhereOrNull((c) => c.kind == KindResponse.house)?.name;

    if (city != null && city.isNotEmpty) {
      cartBloc.cityController.text = city;
    }

    if (street != null && house != null) {
      cartBloc.streetHomeController.text = '$street, $house';
    } else if (street != null) {
      cartBloc.streetHomeController.text = street;
    } else if (house != null) {
      cartBloc.streetHomeController.text = house;
    } else if (formatted != null && formatted.isNotEmpty) {
      cartBloc.streetHomeController.text = _streetFromFormatted(formatted);
    }

    if (searchAddressController != null &&
        formatted != null &&
        formatted.isNotEmpty) {
      setControllerText(searchAddressController, formatted);
    }

    if (geoObject != null) {
      cartBloc.selectedAddress = geoObject;
      cartBloc.add(UpdateDeliveryPriceEvent(address: geoObject));
    }
  }

  static void applyFromResponse({
    required CartScreenBloc cartBloc,
    required GeocodeResponse? response,
    TextEditingController? searchAddressController,
    String? selectedAddressText,
  }) {
    if (response == null) {
      if (selectedAddressText != null &&
          selectedAddressText.isNotEmpty &&
          searchAddressController != null) {
        setControllerText(searchAddressController, selectedAddressText);
      }
      return;
    }

    final geoObject = geoObjectFromResponse(response);
    final formatted =
        formattedAddress(geoObject) ?? response.firstAddress?.formatted;

    applyToCart(
      cartBloc: cartBloc,
      geoObject: geoObject,
      searchAddressController: searchAddressController,
      formattedOverride: formatted ?? selectedAddressText,
    );
  }

  static String? _cityFromFormatted(String? formatted) {
    if (formatted == null || formatted.isEmpty) {
      return null;
    }

    final parts = formatted.split(',').map((part) => part.trim()).toList();
    if (parts.length >= 2) {
      return parts[1];
    }
    return parts.firstOrNull;
  }

  static String _streetFromFormatted(String formatted) {
    final parts = formatted.split(',').map((part) => part.trim()).toList();
    if (parts.length <= 2) {
      return parts.last;
    }
    return parts.sublist(2).join(', ');
  }
}
