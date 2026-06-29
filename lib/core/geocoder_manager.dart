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
  static const double minskLat = 53.9023;
  static const double minskLon = 27.5615;

  /// Bbox: Минск и Минский район
  static const String minskBbox = '27.35,53.75~28.55,54.15';

  /// Центр Беларуси
  static const double belarusCenterLat = 53.7098;
  static const double belarusCenterLon = 27.9534;

  /// Bbox всей Беларуси
  static const String belarusBbox = '23.0,51.0~32.8,56.2';

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

  Future<GeocodeResponse?> getGeocodeCityInBelarus(
    String city, {
    Lang lang = Lang.ru,
  }) async {
    final normalized = city.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final query = _containsBelarus(normalized)
        ? normalized
        : '$normalized, Беларусь';

    try {
      return await _geocoder.getGeocode(
        DirectGeocodeRequest(
          rspn: false,
          addressGeocode: query,
          lang: lang,
          results: 1,
        ),
      );
    } catch (e) {
      print('Ошибка при геокодировании города: $e');
      return null;
    }
  }

  Future<List<String>> getCitySuggestions(
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
        'bbox': belarusBbox,
        'll': '$belarusCenterLon,$belarusCenterLat',
        'types': 'locality',
      },
    );

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        print('Ошибка Suggest API (города): ${response.statusCode}');
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
      print('Ошибка при запросе подсказок городов: $e');
      return [];
    }
  }

  Future<List<String>> getAddressSuggestions(
    String query, {
    String lang = 'ru_RU',
    int results = 7,
    String? cityContext,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final resolvedCity = resolveCityContext(
      query: trimmed,
      fieldCity: cityContext,
    );
    final searchArea = await _resolveSearchArea(resolvedCity);
    final searchText = _buildAddressQuery(
      trimmed,
      cityContext: resolvedCity,
    );

    final url = Uri.https(
      'suggest-maps.yandex.ru',
      '/v1/suggest',
      {
        'apikey': suggestApiKey,
        'text': searchText,
        'lang': lang,
        'results': results.toString(),
        'bbox': searchArea.bbox,
        'll': '${searchArea.lon},${searchArea.lat}',
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
    String? cityContext,
    bool restrictToMinsk = false,
  }) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final resolvedCity = resolveCityContext(
      query: trimmed,
      fieldCity: cityContext,
    );
    final query = _buildAddressQuery(
      trimmed,
      cityContext: resolvedCity,
    );
    if (query.isEmpty) {
      return null;
    }

    try {
      if (restrictToMinsk) {
        return await _geocoder.getGeocode(
          DirectGeocodeRequest(
            rspn: true,
            ll: SearchAreaLL(
              latitude: minskLat,
              longitude: minskLon,
            ),
            spn: SearchAreaSPN(
              differenceLatitude: 0.4,
              differenceLongitude: 0.55,
            ),
            addressGeocode: query,
            lang: lang,
            results: 1,
          ),
        );
      }

      final searchArea = await _resolveSearchArea(resolvedCity);

      return await _geocoder.getGeocode(
        DirectGeocodeRequest(
          rspn: resolvedCity != null && resolvedCity.isNotEmpty,
          ll: SearchAreaLL(
            latitude: searchArea.lat,
            longitude: searchArea.lon,
          ),
          spn: SearchAreaSPN(
            differenceLatitude: searchArea.spnLat,
            differenceLongitude: searchArea.spnLon,
          ),
          addressGeocode: query,
          lang: lang,
          results: 1,
        ),
      );
    } catch (e) {
      print('Ошибка при прямом геокодировании: $e');
      return null;
    }
  }

  /// Город из строки адреса важнее города в отдельном поле.
  String? resolveCityContext({
    required String query,
    String? fieldCity,
  }) {
    final explicitCity = extractCityFromAddressQuery(query);
    if (explicitCity != null && explicitCity.isNotEmpty) {
      return explicitCity;
    }

    final city = fieldCity?.trim();
    if (city == null || city.isEmpty) {
      return null;
    }

    return city;
  }

  String? extractCityFromAddressQuery(String query) {
    final parts = query
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return null;
    }

    final firstPart = parts.first;
    if (_looksLikeStreetPart(firstPart)) {
      return null;
    }

    return _normalizeCityName(firstPart);
  }

  bool _looksLikeStreetPart(String part) {
    final lower = part.toLowerCase();
    return lower.startsWith('ул.') ||
        lower.startsWith('ул ') ||
        lower.startsWith('улица') ||
        lower.startsWith('пр.') ||
        lower.startsWith('проспект') ||
        lower.startsWith('пер.') ||
        lower.startsWith('переулок') ||
        RegExp(r'\d').hasMatch(part);
  }

  String? _normalizeCityName(String raw) {
    var city = raw
        .replaceFirst(
          RegExp(r'^(г\.?|город)\s*', caseSensitive: false),
          '',
        )
        .trim();

    if (city.isEmpty) {
      return null;
    }

    return city;
  }

  Future<_SearchArea> _resolveSearchArea(String? cityContext) async {
    final city = cityContext?.trim();
    if (city != null && city.isNotEmpty) {
      final cityGeo = await getGeocodeCityInBelarus(city);
      final point = cityGeo?.firstPoint;
      if (point != null) {
        return _SearchArea(
          lat: point.lat,
          lon: point.lon,
          spnLat: 0.6,
          spnLon: 0.8,
          bbox:
              '${point.lon - 0.35},${point.lat - 0.25}~${point.lon + 0.35},${point.lat + 0.25}',
        );
      }
    }

    return const _SearchArea(
      lat: belarusCenterLat,
      lon: belarusCenterLon,
      spnLat: 2.5,
      spnLon: 5.0,
      bbox: belarusBbox,
    );
  }

  String _buildAddressQuery(
    String address, {
    String? cityContext,
  }) {
    var query = address.trim();
    if (query.isEmpty) {
      return '';
    }

    final explicitCity = extractCityFromAddressQuery(query);
    final city = explicitCity ?? cityContext?.trim();

    if (city != null &&
        city.isNotEmpty &&
        explicitCity == null &&
        !query.toLowerCase().contains(city.toLowerCase())) {
      query = '$city, $query';
    }

    if (!_containsBelarus(query)) {
      query = '$query, Беларусь';
    }

    return query;
  }

  bool _containsBelarus(String value) {
    final lower = value.toLowerCase();
    return lower.contains('беларус') || lower.contains('belarus');
  }
}

class _SearchArea {
  const _SearchArea({
    required this.lat,
    required this.lon,
    required this.spnLat,
    required this.spnLon,
    required this.bbox,
  });

  final double lat;
  final double lon;
  final double spnLat;
  final double spnLon;
  final String bbox;
}
