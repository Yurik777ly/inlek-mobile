import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/presentation/bloc/pharmacy_map/pharmacy_map_bloc.dart';
import 'package:inlek/features/presentation/widgets/map/address_plate.dart';
import 'package:inlek/features/presentation/widgets/map/map_button.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class PharmacyMapWidget extends StatelessWidget {
  const PharmacyMapWidget({super.key, this.onTapMap});

  final Function(Point point)? onTapMap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacyMapBloc, PharmacyMapState>(
      builder: (context, state) {
        final bloc = context.read<PharmacyMapBloc>();

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: YandexMap(
                    onMapCreated: (controller) => bloc
                      ..add(AttachControllerEvent(mapController: controller)),
                    onCameraPositionChanged: (position, reason, isGesture) =>
                        bloc.add(UpdatePharmacyMapEvent(position: position)),
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    onMapTap: onTapMap,
                    /* (argument) async {
                        final geocoderManager = sl<GeocoderManager>();
        
                        GeocodeResponse? response =
                            await geocoderManager.getGeocodeFromPoint(
                                argument.latitude, argument.longitude);
        
                        List<Component>? components =
                            response?.firstAddress?.components;
        
                        String getComponentName(KindResponse kind) {
                          return components
                                  ?.firstWhereOrNull((e) => e.kind == kind)
                                  ?.name ??
                              '';
                        }
        
                        String city =
                            getComponentName(KindResponse.locality); // Город
                        String street =
                            getComponentName(KindResponse.street); // Улица
                        String house =
                            getComponentName(KindResponse.house); // Дом
        
                        String address =
                            '$street, д.$house'.trim(); // Собираем адрес
        
                        print('Город: $city');
                        print('Адрес: $address');
                      },*/
                    mapObjects: state.markers),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              left: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MapButton(
                      assetName: Paths.locationIconPath,
                      color: UiConstants.pink2Color,
                      onPressed: () => bloc.add(MoveToCurrentLocationEvent())),
                  SizedBox(height: 16.dp),
                  MapButton(
                      assetName: Paths.plusIconPath,
                      color: Color(0xFF222222).withOpacity(.6),
                      onPressed: () => bloc.add(ZoomInEvent())),
                  SizedBox(height: 4.dp),
                  MapButton(
                      assetName: Paths.minusIconPath,
                      color: Color(0xFF222222).withOpacity(.6),
                      onPressed: () => bloc.add(ZoomOutEvent())),
                  if (state.showStackWindow ||
                      bloc.mapScreenType == MapScreenType.order)
                    Padding(
                      padding: getMarginOrPadding(top: 16),
                      child: Builder(
                        builder: (context) {
                          final dataMap = state.points
                              .firstWhereOrNull((e) =>
                                  e.mapObject.mapId.value.toString() ==
                                  (state.selectedMarkerId ?? '213'))
                              ?.data;

                          if (bloc.mapScreenType ==
                              MapScreenType.courierDeliveryZones) {
                            PharmacyEntity pharmacy =
                                PharmacyModel.fromJson(dataMap!);

                            final addressParts =
                                (pharmacy.address ?? '').split(', ');

                            // Пропускаем первый элемент (например, индекс или страна)
                            final cleanedAddress =
                                addressParts.skip(1).join(', ');

                            String city = '';
                            String street = '';

                            final addressSplit = cleanedAddress.split(', ');
                            if (addressSplit.length > 1) {
                              city = addressSplit.first;
                              street = addressSplit.skip(1).join(', ');
                            } else if (addressSplit.isNotEmpty) {
                              city = addressSplit.first;
                            }

                            return AddressPlate(
                              title: city,
                              body: street,
                              onClose: () => bloc..add(SelectMarkerEvent()),
                            );
                          } else if (bloc.mapScreenType ==
                              MapScreenType.product) {
                            return Container();
                          } else if (bloc.mapScreenType ==
                              MapScreenType.order) {
                            final hasError = dataMap?['hasError'] ?? false;
                            final address = dataMap?['address'];

                            if (hasError) {
                              return AddressPlate(
                                  title: 'Сюда пока не доставляем',
                                  body:
                                      'Оформите самовывоз из аптеки вашего города');
                            } else if (address != null) {
                              final rawAddress = address?.toString() ?? '';

                              final addressParts = rawAddress.split(', ');

                              // Пропускаем первый элемент (например, индекс или страна)
                              final cleanedAddress =
                                  addressParts.skip(1).join(', ');

                              String city = '';
                              String street = '';

                              final addressSplit = cleanedAddress.split(', ');
                              if (addressSplit.length > 1) {
                                city = addressSplit.first;
                                street = addressSplit.skip(1).join(', ');
                              } else if (addressSplit.isNotEmpty) {
                                city = addressSplit.first;
                              }

                              return AddressPlate(title: city, body: street);
                            } else {
                              return Container();
                            }
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
