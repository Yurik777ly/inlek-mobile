import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inlek/core/models/map_marker_model.dart';
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
    final failureOrLoads = await getPharmaciesUC('');
    List<MapMarkerModel> points = [];

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

          points.add(
            MapMarkerModel(
              id: pharmacy.pharmacyId!,
              point: Point(latitude: latitude, longitude: longitude),
              data: (pharmacy as PharmacyModel).toJson(),
            ),
          );
        }
      },
    );

    emit(
      InfoAboutOrderScreenState(isLoading: false, points: points),
    );
  }
}
