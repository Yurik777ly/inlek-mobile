import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/core/models/courier_zone_model.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/usecases/content/get_pharmacies.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

part 'info_about_order_screen_event.dart';
part 'info_about_order_screen_state.dart';

class InfoAboutOrderScreenBloc
    extends Bloc<InfoAboutOrderScreenEvent, InfoAboutOrderScreenState> {
  final GetPharmaciesUC getPharmaciesUC;

  InfoAboutOrderScreenBloc({required this.getPharmaciesUC})
      : super(InfoAboutOrderScreenState()) {
    on<LoadDataEvent>(_onLoadData);
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<InfoAboutOrderScreenState> emit) async {
    List<CustomMapObject> mapObjects = await _loadPolygonObjects();

    final failureOrLoads = await getPharmaciesUC('');

    failureOrLoads.fold(
      (_) => emit(
        InfoAboutOrderScreenState(isLoading: false),
      ),
      (pharmacies) async {
        for (PharmacyEntity pharmacy in pharmacies) {
          double latitude =
              double.parse(pharmacy.coordinates!.split(', ').first);
          double longitude =
              double.parse(pharmacy.coordinates!.split(', ').last);

          // Генерация иконки для маркера с количеством аптек

          mapObjects.add(
            CustomMapObject(
              mapObject: PlacemarkMapObject(
                mapId: MapObjectId(pharmacy.pharmacyId.toString()),
                point: Point(latitude: latitude, longitude: longitude),
              ),
              data: (pharmacy as PharmacyModel).toJson(),
            ),
          );
        }
      },
    );

    emit(
      InfoAboutOrderScreenState(isLoading: false, mapObjects: mapObjects),
    );
  }

  Future<List<CustomMapObject>> _loadPolygonObjects() async {
    List<CustomMapObject> mapObjects = [];

    String jsonString = await rootBundle.loadString(Paths.courierZonesJsonPath);

    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    CourierZoneModel courierZoneData = CourierZoneModel.fromJson(jsonData);

    for (Feature feature in courierZoneData.features) {
      for (List<List<double>> coordinates in feature.geometry.coordinates) {
        mapObjects.add(
          CustomMapObject(
            mapObject: PolygonMapObject(
              fillColor: Color(
                int.parse(
                  "0xFF${feature.properties.fill.replaceAll('#', '')}",
                ),
              ).withOpacity(feature.properties.fillOpacity),
              strokeColor: Color(
                int.parse(
                  "0xFF${feature.properties.stroke.replaceAll('#', '')}",
                ),
              ).withOpacity(feature.properties.strokeOpacity),
              strokeWidth: feature.properties.strokeWidth,
              mapId: MapObjectId(feature.id.toString()),
              polygon: Polygon(
                outerRing: LinearRing(
                  points: List.generate(
                    coordinates.length,
                    (index) => Point(
                        latitude: coordinates[index].last,
                        longitude: coordinates[index].first),
                  ),
                ),
                innerRings: [],
              ),
            ),
          ),
        );
      }
    }

    return mapObjects;
  }
}
