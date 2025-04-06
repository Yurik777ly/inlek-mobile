import 'package:yandex_geocoder/yandex_geocoder.dart';

class GeocoderManager {
  final YandexGeocoder _geocoder;

  GeocoderManager(this._geocoder);

  Future<GeocodeResponse?> getGeocodeFromPoint(double lat, double lon,
      {Lang lang = Lang.ru}) async {
    try {
      return (await _geocoder.getGeocode(
        ReverseGeocodeRequest(
          pointGeocode: (lat: lat, lon: lon),
          lang: lang,
          kind: KindRequest.house,
          ll: SearchAreaLL(latitude: 53.9006, longitude: 27.5590),
          spn: SearchAreaSPN(
              differenceLatitude: 9.584443, differenceLongitude: 4.910062),
        ),
      ));
    } catch (e) {
      print('Ошибка при обратном геокодировании: $e');
      return null;
    }
  }

  Future<GeocodeResponse?> getGeocodeFromAddress(String address,
      {Lang lang = Lang.ru}) async {
    try {
      return (await _geocoder.getGeocode(
        DirectGeocodeRequest(
            rspn: true,
            ll: SearchAreaLL(latitude: 53.9006, longitude: 27.5590),
            spn: SearchAreaSPN(
                differenceLatitude: 9.584443, differenceLongitude: 4.910062),
            addressGeocode: address,
            lang: lang),
      ));
    } catch (e) {
      print('Ошибка при прямом геокодировании: $e');
      return null;
    }
  }
}
