import 'package:yandex_mapkit/yandex_mapkit.dart';

class CustomMapObject {
  final MapObject mapObject;
  final Map<String, dynamic>? data;

  const CustomMapObject({required this.mapObject, this.data});
}
