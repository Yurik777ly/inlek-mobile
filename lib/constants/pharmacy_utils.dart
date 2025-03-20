class PharmacyUtils {
  static // Функция для парсинга диапазона дней
      List<int> _parseDaysRange(String daysRange) {
    final daysMap = {
      'ПН': 1,
      'ВТ': 2,
      'СР': 3,
      'ЧТ': 4,
      'ПТ': 5,
      'СБ': 6,
      'ВС': 7,
    };

    if (daysRange.contains('-')) {
      final parts = daysRange.split('-');
      if (parts.length == 2 &&
          daysMap.containsKey(parts[0]) &&
          daysMap.containsKey(parts[1])) {
        final start = daysMap[parts[0]]!;
        final end = daysMap[parts[1]]!;
        return List.generate(end - start + 1, (index) => start + index);
      }
    } else if (daysRange.contains(',')) {
      return daysRange.split(',').map((d) => daysMap[d]!).toList();
    } else if (daysMap.containsKey(daysRange)) {
      return [daysMap[daysRange]!];
    }

    return [];
  }

  // Функция для парсинга диапазона часов
  static List<int>? _parseHoursRange(String hoursRange) {
    final parts = hoursRange.split('-');
    if (parts.length == 2) {
      final start = _parseTimeToMinutes(parts[0]);
      final end = _parseTimeToMinutes(parts[1]);
      return start != null && end != null ? [start, end] : null;
    }
    return null;
  }

// Функция для перевода времени в минуты
  static int? _parseTimeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      final hours = int.tryParse(parts[0]);
      final minutes = int.tryParse(parts[1]);
      if (hours != null && minutes != null) {
        return hours * 60 + minutes;
      }
    }
    return null;
  }

  static bool isPharmacyOpen(String schedule) {
    final now = DateTime.now();
    final currentDay = now.weekday; // 1 = ПН, ..., 7 = ВС
    final currentTime = now.hour * 60 + now.minute; // Время в минутах

    final Map<int, List<int>> workHours = {};

    // Разбиваем расписание по \r\n
    final lines = schedule.split('\r\n');
    for (var line in lines) {
      final parts = line.split(': ');
      if (parts.length != 2) continue;

      final daysRange = parts[0]; // Например, "ПН-ПТ"
      final hoursRange = parts[1]; // Например, "08:00-21:00"

      final days = _parseDaysRange(daysRange);
      final hours = _parseHoursRange(hoursRange);
      if (hours == null) continue;

      for (var day in days) {
        workHours[day] = hours;
      }
    }

    // Проверяем, есть ли у текущего дня рабочие часы
    if (workHours.containsKey(currentDay)) {
      final hours = workHours[currentDay]!;
      return currentTime >= hours[0] && currentTime <= hours[1];
    }

    return false;
  }
}
