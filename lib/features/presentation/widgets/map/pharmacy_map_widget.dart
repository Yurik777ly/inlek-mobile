import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/models/map_marker_model.dart';
import 'package:inlek/features/presentation/bloc/pharmacy_map/pharmacy_map_bloc.dart';
import 'package:inlek/features/presentation/widgets/map/address_plate.dart';
import 'package:inlek/features/presentation/widgets/map/map_button.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

class PharmacyMapWidget extends StatelessWidget {
  final List<CustomMapObject> points;
  const PharmacyMapWidget({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PharmacyMapBloc()..add(InitPharmacyMapEvent(points: points)),
      child: BlocBuilder<PharmacyMapBloc, PharmacyMapState>(
        builder: (context, state) {
          final bloc = context.read<PharmacyMapBloc>();

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 439.h,
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
                    mapObjects: state.markers),
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
                        onPressed: () =>
                            bloc.add(MoveToCurrentLocationEvent())),
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
                        child: Builder(builder: (context) {
                          final String address = state.points
                                  .firstWhereOrNull((e) =>
                                      e.mapObject.mapId.value.toString() ==
                                      state.selectedMarkerId)
                                  ?.data?['address'] ??
                              '';

                          final List<String> addressSplit = address.split(', ');

                          String city = '';
                          String street = '';

                          if (addressSplit.length > 1) {
                            city = addressSplit.first;
                            street = addressSplit.skip(1).join(', ');
                          }

                          return AddressPlate(
                            city: city,
                            street: street,
                            onClose: () => bloc..add(SelectMarkerEvent()),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
