import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/bottom_sheet_manager.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/data/models/cart_pharmacies_model.dart';
import 'package:inlek/features/data/models/city_model.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/domain/entities/cart_pharmacies_entity.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

part 'pharmacy_map_event.dart';
part 'pharmacy_map_state.dart';

class PharmacyMapBloc extends Bloc<PharmacyMapEvent, PharmacyMapState> {
  final MapScreenType mapScreenType;
  final SharedPreferences sharedPreferences;

  final BuildContext? screenContext;

  PharmacyMapBloc(
      {required this.mapScreenType,
      required this.sharedPreferences,
      this.screenContext})
      : super(PharmacyMapState()) {
    on<InitPharmacyMapEvent>((event, emit) {
      Point? defaultPosition;

      if (event.initialCameraPoint != null) {
        defaultPosition = event.initialCameraPoint;
      } else if (mapScreenType == MapScreenType.order) {
        if (event.points.isNotEmpty) {
          CustomMapObject? mark = event.points
              .firstWhereOrNull((e) => e.mapObject is PlacemarkMapObject);
          if (mark != null) {
            defaultPosition = (mark.mapObject as PlacemarkMapObject).point;
          }
        }
      } else if (mapScreenType != MapScreenType.courierDeliveryZones) {
        final city = (() {
          try {
            final json =
                sharedPreferences.getString(SharedPreferencesKeys.city);
            return json == null ? null : CityModel.fromJson(jsonDecode(json));
          } catch (_) {
            return null;
          }
        })();

        if (city != null) {
          defaultPosition =
              Point(latitude: city.latitude, longitude: city.longitude);
        }
      }

      if (defaultPosition != null) {
        emit(state.copyWith(defaultPosition: defaultPosition));
      }
      emit(state.copyWith(points: event.points));

      add(UpdatePharmacyMapEvent());
    });
    on<AttachControllerEvent>((event, emit) {
      emit(state.copyWith(mapController: event.mapController));
      event.mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: state.defaultPosition, zoom: 12),
        ),
      );
    });
    on<SelectMarkerEvent>(_onSelectMarker);
    on<UpdatePharmacyMapEvent>(_onUpdateMap);
    on<ZoomInEvent>(_onZoomIn);
    on<ZoomOutEvent>(_onZoomOut);
    on<MoveToCurrentLocationEvent>(_onMoveToCurrentLocation);
    on<MoveToPoint>(_onMoveToPoint);
  }

  void _onSelectMarker(
      SelectMarkerEvent event, Emitter<PharmacyMapState> emit) async {
    String selectedMarkerId = event.markerId ?? state.selectedMarkerId!;

    emit(state.copyWith(
        selectedMarkerId: selectedMarkerId,
        showStackWindow: state.selectedMarkerId != selectedMarkerId
            ? true
            : !state.showStackWindow));

    CameraPosition? position = await state.mapController?.getCameraPosition();
    final targetPoint = state.showStackWindow
        ? (state.points
                .firstWhereOrNull(
                    (e) => e.mapObject.mapId.value == state.selectedMarkerId)
                ?.mapObject as PlacemarkMapObject?)
            ?.point
        : null;

    if (targetPoint != null && position != null) {
      state.mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            position.copyWith(target: targetPoint),
          ),
          animation: MapAnimation(duration: 0.6));
    }
  }

  void _onUpdateMap(
    UpdatePharmacyMapEvent event,
    Emitter<PharmacyMapState> emit,
  ) async {
    final stopwatch = Stopwatch()..start();

    // Создание списков для маркеров и полигонов
    List<PlacemarkMapObject> placemarks = [];
    List<PolygonMapObject> polygons = [];

    // Обработка маркеров (PlacemarkMapObject)
    for (CustomMapObject point
        in state.points.where((e) => e.mapObject is PlacemarkMapObject)) {
      final icon = await Utils.createBitmapIcon();
      final placemark = PlacemarkMapObject(
        opacity: 1,
        mapId: MapObjectId(point.mapObject.mapId.value),
        point: Point(
          latitude: (point.mapObject as PlacemarkMapObject).point.latitude,
          longitude: (point.mapObject as PlacemarkMapObject).point.longitude,
        ),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(image: icon),
        ),
        onTap: (point, __) {
          if (mapScreenType == MapScreenType.product) {
            final dataMap = state.points
                .firstWhereOrNull((e) =>
                    e.mapObject.mapId.value.toString() == point.mapId.value)
                ?.data;
            if (dataMap != null) {
              PharmacyEntity pharmacy = PharmacyModel.fromJson(dataMap);
              BottomSheetManager.showPharmacyInfoSheet(pharmacy);
            }
          } else if (mapScreenType == MapScreenType.cart) {
            final dataMap = state.points
                .firstWhereOrNull((e) =>
                    e.mapObject.mapId.value.toString() == point.mapId.value)
                ?.data;
            if (dataMap != null) {
              CartPharmacyEntity pharmacy = CartPharmacyModel.fromJson(dataMap);
              BottomSheetManager.showPharmacySheet(screenContext!, pharmacy);
            }
          } else {
            add(SelectMarkerEvent(markerId: point.mapId.value));
          }
        },
      );
      placemarks.add(placemark);
    }

    // Обработка полигонов (PolygonMapObject)
    for (CustomMapObject point
        in state.points.where((e) => e.mapObject is PolygonMapObject)) {
      polygons.add(point.mapObject as PolygonMapObject);
    }

    // Создание кластеризованной коллекции маркеров
    final markers = <MapObject>[...polygons];

    if (placemarks.isNotEmpty) {
      markers.add(
        ClusterizedPlacemarkCollection(
          mapId: MapObjectId('clusterized_collection'),
          placemarks: placemarks,
          radius: 60,
          minZoom: 10,
          onClusterAdded:
              (ClusterizedPlacemarkCollection self, Cluster cluster) async {
            final clusterIcon =
                await Utils.createBitmapIcon(count: cluster.size);
            return cluster.copyWith(
              appearance: cluster.appearance.copyWith(
                opacity: 1,
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(image: clusterIcon),
                ),
              ),
            );
          },
          onClusterTap: (self, cluster) {
            add(ZoomInEvent(point: cluster.appearance.point));
          },
        ),
      );
    }

    // ❗ Оптимизация: перезаписываем markers, чтобы не плодились дубликаты
    emit(state.copyWith(markers: markers));

    stopwatch.stop();
    debugPrint(
        '⏱️ _onUpdateMap executed in ${stopwatch.elapsedMilliseconds} ms');
  }

  Future _onZoomIn(ZoomInEvent event, Emitter<PharmacyMapState> emit) async {
    CameraPosition? position = await state.mapController?.getCameraPosition();
    final targetPoint = state.showStackWindow
        ? (state.points
                .firstWhereOrNull(
                    (e) => e.mapObject.mapId.value == state.selectedMarkerId)
                ?.mapObject as PlacemarkMapObject?)
            ?.point
        : null;
    if (position != null) {
      state.mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            position.copyWith(
                zoom: position.zoom + 1, target: event.point ?? targetPoint),
          ),
          animation: MapAnimation(duration: 0.6));
    }
  }

  Future _onZoomOut(ZoomOutEvent event, Emitter<PharmacyMapState> emit) async {
    CameraPosition? position = await state.mapController?.getCameraPosition();
    final targetPoint = state.showStackWindow
        ? (state.points
                .firstWhereOrNull(
                    (e) => e.mapObject.mapId.value == state.selectedMarkerId)
                ?.mapObject as PlacemarkMapObject?)
            ?.point
        : null;
    if (position != null) {
      state.mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            position.copyWith(zoom: position.zoom - 1, target: targetPoint),
          ),
          animation: MapAnimation(duration: 0.6));
    }
  }

  Future _onMoveToCurrentLocation(
      MoveToCurrentLocationEvent event, Emitter<PharmacyMapState> emit) async {
    CameraPosition? position = await state.mapController?.getCameraPosition();
    if (position != null) {
      Point newPoint = state.defaultPosition;
      if (mapScreenType == MapScreenType.order) {
        if (state.points.isNotEmpty) {
          CustomMapObject? mark = state.points
              .firstWhereOrNull((e) => e.mapObject is PlacemarkMapObject);
          if (mark != null) {
            newPoint = (mark.mapObject as PlacemarkMapObject).point;
          }
        }
      }
      state.mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            position.copyWith(target: newPoint, zoom: 12),
          ),
          animation: MapAnimation(duration: 0.6));
    }
  }

  Future _onMoveToPoint(
      MoveToPoint event, Emitter<PharmacyMapState> emit) async {
    state.mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: event.point, zoom: event.zoom),
        ),
        animation: MapAnimation(duration: 0.6));
  }
}
