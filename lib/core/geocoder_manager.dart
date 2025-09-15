import 'dart:convert';

import 'package:http/http.dart' as http;
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
            results: 1),
      ));
    } catch (e) {
      print('Ошибка при обратном геокодировании: $e');
      return null;
    }
  }

  /// 🔹 Подсказки через Suggest API
  Future<List<String>> getAddressSuggestions(
    String query, {
    String lang = "ru_RU",
    int results = 5,
  }) async {
    final url = Uri.parse(
      "https://suggest-maps.yandex.ru/v1/suggest"
      "?apikey=bcd2aad2-0542-4674-a464-2264cc611a0e"
      "&text=$query"
      "&lang=$lang"
      "&results=$results"
      "&bbox=23.178,51.256~32.776,56.172"
      "&print_address=1"
      "&types=geo,street,house,locality",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data["results"] ?? [];

        return results
            .map((e) =>
                e["address"]?["formatted_address"]?.toString() ??
                e["title"]?["text"]?.toString() ??
                "")
            .where((text) => text.isNotEmpty)
            .toList();
      } else {
        print("Ошибка Suggest API: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Ошибка при запросе подсказок: $e");
      return [];
    }
  }

  Future<GeocodeResponse?> getGeocodeFromAddress(
    String address, {
    Lang lang = Lang.ru,
  }) async {
    try {
      return await _geocoder.getGeocode(
        DirectGeocodeRequest(
            rspn: true, // ограничиваем область поиска Беларусью
            ll: SearchAreaLL(
              latitude: 53.7098, // центр Беларуси
              longitude: 27.9534,
            ),
            spn: SearchAreaSPN(
              differenceLatitude: 4.91, // север-юг Беларуси
              differenceLongitude: 9.6, // запад-восток Беларуси
            ),
            addressGeocode: address,
            lang: lang,
            kind: KindRequest.locality,
            results: 1),
      );
    } catch (e) {
      print('Ошибка при прямом геокодировании: $e');
      return null;
    }
  }
}
