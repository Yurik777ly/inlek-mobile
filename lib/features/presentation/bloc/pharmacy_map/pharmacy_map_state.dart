part of 'pharmacy_map_bloc.dart';

class PharmacyMapState extends Equatable {
  final String? selectedMarkerId;
  final bool showStackWindow;
  final List<MapObject<dynamic>> markers;
  final List<CustomMapObject> points;
  final YandexMapController? mapController;
  final Point defaultPosition;

  const PharmacyMapState({
    this.selectedMarkerId,
    this.showStackWindow = false,
    this.markers = const [],
    this.points = const [],
    this.mapController,
    this.defaultPosition = const Point(latitude: 53.9006, longitude: 27.5590),
  });

  PharmacyMapState copyWith({
    String? selectedMarkerId,
    bool? showStackWindow,
    List<MapObject<dynamic>>? markers,
    List<CustomMapObject>? points,
    CameraPosition? position,
    YandexMapController? mapController,
    Point? defaultPosition,
  }) {
    return PharmacyMapState(
      showStackWindow: showStackWindow ?? this.showStackWindow,
      selectedMarkerId: selectedMarkerId ?? this.selectedMarkerId,
      markers: markers ?? this.markers,
      points: points ?? this.points,
      mapController: mapController ?? this.mapController,
      defaultPosition: defaultPosition ?? this.defaultPosition,
    );
  }

  @override
  List<Object?> get props => [
        showStackWindow,
        selectedMarkerId,
        markers,
        points,
        mapController,
        defaultPosition
      ];
}
