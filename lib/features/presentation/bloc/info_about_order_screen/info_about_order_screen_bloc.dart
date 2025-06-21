import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inlek/core/courier_zone_manager.dart';
import 'package:inlek/core/models/custom_marker_model.dart';
import 'package:inlek/features/data/models/pharmacy_model.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';
import 'package:inlek/features/domain/usecases/content/get_pharmacies.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

part 'info_about_order_screen_event.dart';
part 'info_about_order_screen_state.dart';

class InfoAboutOrderScreenBloc
    extends Bloc<InfoAboutOrderScreenEvent, InfoAboutOrderScreenState> {
  final GetPharmaciesUC getPharmaciesUC;
  final CourierZoneManager courierZoneManager;

  InfoAboutOrderScreenBloc(
      {required this.getPharmaciesUC, required this.courierZoneManager})
      : super(InfoAboutOrderScreenState()) {
    on<LoadDataEvent>(_onLoadData);
  }

  void _onLoadData(
      LoadDataEvent event, Emitter<InfoAboutOrderScreenState> emit) async {
    List<CustomMapObject> mapObjects = List.of(courierZoneManager.mapObjects);

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
}
