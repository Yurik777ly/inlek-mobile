import 'dart:convert';

class PharmacyUtils {
  static List<int> _parseDaysRange(String daysRange) {
    final daysMap = {
      'ПН': 1,
      'ВТ': 2,
      'СР': 3,
      'ЧТ': 4,
      'ПТ': 5,
      'СБ': 6,
      'ВС': 7,
    };

    final normalized = daysRange.trim().toUpperCase();

    if (normalized.contains('-')) {
      final parts = normalized.split('-');
      if (parts.length == 2 &&
          daysMap.containsKey(parts[0].trim()) &&
          daysMap.containsKey(parts[1].trim())) {
        final start = daysMap[parts[0].trim()]!;
        final end = daysMap[parts[1].trim()]!;
        return List.generate(end - start + 1, (index) => start + index);
      }
    } else if (normalized.contains(',')) {
      return normalized
          .split(',')
          .map((d) => daysMap[d.trim()])
          .whereType<int>()
          .toList();
    } else if (daysMap.containsKey(normalized)) {
      return [daysMap[normalized]!];
    }

    return [];
  }

  static List<int>? _parseHoursRange(String hoursRange) {
    final parts = hoursRange.trim().split('-');
    if (parts.length == 2) {
      final start = _parseTimeToMinutes(parts[0]);
      final end = _parseTimeToMinutes(parts[1]);
      return start != null && end != null ? [start, end] : null;
    }
    return null;
  }

  static int? _parseTimeToMinutes(String time) {
    final parts = time.trim().split(':');
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      if (hours != null && minutes != null) {
        return hours * 60 + minutes;
      }
    }
    return null;
  }

  static String normalizeSchedule(dynamic schedule) {
    if (schedule == null) {
      return '';
    }

    if (schedule is String) {
      final trimmed = schedule.trim();
      if (trimmed.isEmpty) {
        return '';
      }

      if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is String) {
            return decoded.trim();
          }
        } catch (_) {}
      }

      return trimmed;
    }

    return schedule.toString().trim();
  }

  static bool isPharmacyOpen(dynamic schedule) {
    final normalizedSchedule = normalizeSchedule(schedule);
    if (normalizedSchedule.isEmpty) {
      return false;
    }

    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = now.hour * 60 + now.minute;

    final Map<int, List<int>> workHours = {};
    final lines = normalizedSchedule.split(RegExp(r'\r?\n'));

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      final colonIndex = line.indexOf(':');
      if (colonIndex == -1) {
        continue;
      }

      final daysRange = line.substring(0, colonIndex).trim();
      final hoursRange = line.substring(colonIndex + 1).trim();

      final days = _parseDaysRange(daysRange);
      final hours = _parseHoursRange(hoursRange);
      if (hours == null || days.isEmpty) {
        continue;
      }

      for (final day in days) {
        workHours[day] = hours;
      }
    }

    if (workHours.containsKey(currentDay)) {
      final hours = workHours[currentDay]!;
      return currentTime >= hours[0] && currentTime <= hours[1];
    }

    return false;
  }
}
