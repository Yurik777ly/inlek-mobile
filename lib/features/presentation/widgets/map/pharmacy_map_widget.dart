import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/presentation/bloc/pharmacy_map/pharmacy_map_bloc.dart';
import 'package:inlek/features/presentation/widgets/map/address_plate.dart';
import 'package:inlek/features/presentation/widgets/map/map_button.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

class PharmacyMapWidget extends StatelessWidget {
  const PharmacyMapWidget({super.key});

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
                    onCameraPositionChanged: (position, reason, isGesture,
                            visibleRegion) =>
                        bloc.add(UpdatePharmacyMapEvent(position: position)),
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    /*onMapTap: (argument) async {
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
                      }*/
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
                  SizedBox(height: 16.h),
                  MapButton(
                      assetName: Paths.plusIconPath,
                      color: Color(0xFF222222).withOpacity(.6),
                      onPressed: () => bloc.add(ZoomInEvent())),
                  SizedBox(height: 4.h),
                  MapButton(
                      assetName: Paths.minusIconPath,
                      color: Color(0xFF222222).withOpacity(.6),
                      onPressed: () => bloc.add(ZoomOutEvent())),
                  if (state.showStackWindow)
                    Padding(
                      padding: getMarginOrPadding(top: 16),
                      child: Builder(
                        builder: (context) {
                          final dataMap = state.points
                              .firstWhereOrNull((e) =>
                                  e.mapObject.mapId.value.toString() ==
                                  state.selectedMarkerId)
                              ?.data;

                          if (bloc.mapScreenType ==
                              MapScreenType.courierDeliveryZones) {
                            PharmacyEntity pharmacy =
                                PharmacyModel.fromJson(dataMap!);

                            return AddressPlate(
                              pharmacy: pharmacy,
                              onClose: () => bloc..add(SelectMarkerEvent()),
                            );
                          } else if (bloc.mapScreenType ==
                              MapScreenType.product) {
                            return Container();
                          } else {
                            return Container();
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
