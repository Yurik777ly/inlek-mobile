import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yandex_geocoder/yandex_geocoder.dart';

class GeocoderManager {
  GeocoderManager(
    this._geocoder, {
    required this.suggestApiKey,
  });

  final YandexGeocoder _geocoder;
  final String suggestApiKey;

  /// Центр Минска
  static const double _minskLat = 53.9023;
  static const double _minskLon = 27.5615;

  /// Bbox: Минск и Минский район (для подсказок и геокодирования)
  static const String _deliveryBbox = '27.35,53.75~28.55,54.15';

  Future<GeocodeResponse?> getGeocodeFromPoint(
    double lat,
    double lon, {
    Lang lang = Lang.ru,
  }) async {
    try {
      return await _geocoder.getGeocode(
        ReverseGeocodeRequest(
          pointGeocode: (lat: lat, lon: lon),
          lang: lang,
          results: 1,
        ),
      );
    } catch (e) {
      print('Ошибка при обратном геокодировании: $e');
      return null;
    }
  }

  Future<List<String>> getAddressSuggestions(
    String query, {
    String lang = 'ru_RU',
    int results = 7,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final url = Uri.https(
      'suggest-maps.yandex.ru',
      '/v1/suggest',
      {
        'apikey': suggestApiKey,
        'text': trimmed,
        'lang': lang,
        'results': results.toString(),
        'bbox': _deliveryBbox,
        'll': '$_minskLon,$_minskLat',
        'print_address': '1',
        'types': 'geo,street,house,locality',
      },
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        print('Ошибка Suggest API: ${response.statusCode} ${response.body}');
        return [];
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> items = data['results'] ?? [];

      return items
          .map((item) {
            final map = item as Map<String, dynamic>;
            final address = map['address'] as Map<String, dynamic>?;
            final formatted = address?['formatted_address']?.toString();
            if (formatted != null && formatted.isNotEmpty) {
              return formatted;
            }
            return map['title']?['text']?.toString() ?? '';
          })
          .where((text) => text.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      print('Ошибка при запросе подсказок: $e');
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
          rspn: true,
          ll: SearchAreaLL(
            latitude: _minskLat,
            longitude: _minskLon,
          ),
          spn: SearchAreaSPN(
            differenceLatitude: 0.4,
            differenceLongitude: 0.55,
          ),
          addressGeocode: address,
          lang: lang,
          results: 1,
        ),
      );
    } catch (e) {
      print('Ошибка при прямом геокодировании: $e');
      return null;
    }
  }
}
