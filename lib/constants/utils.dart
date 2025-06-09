import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/locator_service.dart';
import 'package:intl/intl.dart';
import 'package:jivosdk_plugin/bridge.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_mapkit_lite/yandex_mapkit_lite.dart';

class Utils {
  static RegExp phoneRegexp = RegExp(r'^\+375 \(\d{2}\) \d{3}-\d{2}-\d{2}$');
  static RegExp nameAndSurnameRegexp = RegExp(r'^[a-zA-Zа-яА-ЯёЁ\-]+$');

  static TextStyle htmlTextStyle = UiConstants.textStyle2;

  static Style htmlStyle = Style(
    fontSize: FontSize(htmlTextStyle.fontSize!),
    color: UiConstants.darkBlueColor,
    fontWeight: htmlTextStyle.fontWeight!,
    height: Height((htmlTextStyle.height ?? 1) * htmlTextStyle.fontSize!),
    fontFamily: htmlTextStyle.fontFamily,
  );

  static String mockHtml =
      "<blockquote>\r\n<p style=\"text-align: justify;\"><strong>Louis Widmer </strong>&mdash; это швейцарская <strong><a href=\"katalog/gigiena-i-kosmetika/uhod-za-licom/zhirnaya-i-problemnaya-kozha.html\">лечебная косметика</a></strong> для самой чувствительной кожи.</p>\r\n</blockquote>\r\n<p class=\"bx-section-desc-post\" style=\"text-align: justify;\">&nbsp;</p>\r\n<p class=\"bx-section-desc-post\" style=\"text-align: justify;\">Средства созданы в тесном сотрудничестве с лучшими швейцарскими дерматологами, химиками и известными университетами.&nbsp;Эффективные дерматологические компоненты в фармакодинамических дозах.&nbsp;Продукты с минимальным содержанием консервантов либо их полным отсутствием, благодаря стерильности производства.&nbsp;Без парфюмерных отдушек и красителей, очень высокая&nbsp;переносимость людьми&nbsp;страдающими аллергией.&nbsp;&nbsp;Наноэмульсии (биодоступность в 5-10 раз выше обычных микроэмульсий, используемых при производстве косметических средств).&nbsp;Липосомные технологии (доставка активных компонентов и воздействие на клеточном уровне).&nbsp;Ферментированная гиалуроновая кислота, действующая в глубоких слоях кожи.&nbsp;Использование ультразвукового эмульгирования при производстве,&nbsp;позволяет снизить до 60% нежелательное действие эмульгаторов на кожу.<br /><br />В марке представлены гаммы:<br /><br /></p>\r\n<ul>\r\n<li style=\"text-align: justify;\"><b><i>Louis Widmer&nbsp;Очищение&nbsp;</i></b>-&nbsp;&nbsp;нежная, но глубокая очистка. Деликатное очищение для чувствительной кожи. Благодаря активным компонентам (комплекс аминокислот и пантенол) продукты данной гаммы увлажняют и успокаивают.</li>\r\n<li style=\"text-align: justify;\"><b><i>Louis Widmer&nbsp;Уход -&nbsp;</i></b>дневной уход&nbsp;для каждого типа кожи: Крема с ценными биоактивными ингредиентами для дневного ухода. Результат: гладкая и мягкая кожа, меньше морщин, идеальное увлажнение.&nbsp;Ночной уход&nbsp;для каждого типа кожи: интенсивно восстанавливает, смягчает. Крема поддерживают естественный процесс регенерации кожи, улучшают кровообращение и стимулируют обновление тканей.</li>\r\n<li style=\"text-align: justify;\"><b><i>Louis Widmer&nbsp;Скин Эпил (</i></b><b><i>Skin Appeal)&nbsp;</i></b>- линейка для проблемной и жирной кожи.&nbsp;Воздействует на: воспалительные элементы; подавляет размножение Р. Аcnes; обладает&nbsp; противовоспалительным, бактерицидным, противогрибковым, противовирусным и ранозаживляющим действием. НЕ СУШИТ КОЖУ.</li>\r\n<li style=\"text-align: justify;\"><b><i>Louis Widmer&nbsp;Ремедерм (Remederm</i></b><b><i>)&nbsp;</i></b>- интенсивный уход для очень сухой и атопичной кожи младенцев детей и взрослых. Глубоко увлажняет, питает и восстанавливает повреждённые участки кожи.&nbsp;</li>\r\n<li style=\"text-align: justify;\"><b><i>Louis Widmer&nbsp;Солнечная линия (Sun line</i></b><b><i>)</i></b>&nbsp;- гамма идеально подходит <strong><a href=\"katalog/gigiena-i-kosmetika/uhod-za-licom/uhod-za-chuvstvitelnoj-atopichnoj-kozhej.html\">для очень чувствительной кожи</a></strong> и кожи, склонной к аллергическим реакциям.&nbsp;Входящие в состав ухаживающие компоненты эффективно восстанавливают и увлажняют кожу.&nbsp;UVA и UVB фильтры нового поколения предотвращают проявление кожных аллергических реакций и снижают вероятность получения солнечных ожогов.&nbsp;Высокая водостойкость.</li>\r\n</ul>";

  static String? emailValidate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Поле не должно быть пустым';
    }

    // Регулярное выражение для проверки email
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);

    if (!regex.hasMatch(value)) {
      return 'Введите валидный email';
    }
    return null; // Если email корректный, возвращаем null (валидация успешна)
  }

  static String? nameValidate(String? value,
      {bool isSensitiveEmptyValue = true}) {
    if (value == null || value.isEmpty) {
      if (!isSensitiveEmptyValue) {
        return null;
      }
      return 'Поле не должно быть пустым';
    }
    if (!nameAndSurnameRegexp.hasMatch(value)) {
      return 'Только текст и дефис';
    }
    return null;
  }

  static String? dateValidate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Убираем пробелы и проверяем формат
    final trimmed = value.replaceAll(' ', '');
    final dateRegexp = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegexp.hasMatch(trimmed)) {
      return 'Введите дату в формате ДД / ММ / ГГГГ';
    }

    try {
      final parts = trimmed.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final parsedDate = DateTime(year, month, day);

      // Проверим, что дата соответствует введённым значениям
      if (parsedDate.day != day ||
          parsedDate.month != month ||
          parsedDate.year != year) {
        return 'Некорректная дата';
      }

      return null; // дата корректна
    } catch (_) {
      return 'Некорректная дата';
    }
  }

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Поле не должно быть пустым';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if ((value ?? '').length < 19) {
      return 'Введите номер телефона';
    }
    return null;
  }

  static String formatSecondToMMSS(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String removeTrailingZeros(double value, int fractionDigits) {
    // Convert the value to a string with fixed decimal places
    String result = value.toStringAsFixed(fractionDigits).replaceAll('.', ',');

    // Remove trailing zeros
    result = result.replaceAll(RegExp(r"([,]*0+)(?!,*\d)"), "");

    return result;
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final DateFormat formatter = DateFormat('dd.MM.yyyy в HH:mm');
    return formatter.format(dateTime);
  }

  static String getRussianTypeReceiving(TypeReceiving typeReceiving) {
    switch (typeReceiving) {
      case TypeReceiving.delivery:
        return 'Доставка';
      case TypeReceiving.pickup:
        return 'Самовывоз';

      default:
        return '';
    }
  }

  static String getRussianOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.courier:
        return 'У курьера';
      case OrderStatus.readyToIssue:
        return 'Готов к выдаче';
      case OrderStatus.reserved:
        return 'Зарезервирован';
      case OrderStatus.canceled:
        return 'Отменен';
      case OrderStatus.received:
        return 'Получен';
      case OrderStatus.collected:
        return 'Собран';
      case OrderStatus.processing:
        return 'В обработке';
      case OrderStatus.awaitingPayment:
        return 'Ожидает оплаты';
    }
  }

  static String getOrderStatusSubtitle(OrderStatus status, {DateTime? date}) {
    switch (status) {
      case OrderStatus.courier:
        return "Курьер уже едет к вам";
      case OrderStatus.readyToIssue:
        return "Заказ ждет вас в аптеке до конца дня ${formatDate(date!)}";
      case OrderStatus.reserved:
        return "Проверим наличие и свяжемся с вами в случае отсутствия товаров";
      case OrderStatus.received:
        return "Спасибо за заказ";
      case OrderStatus.collected:
        return "Ваш заказ собран, скоро мы передадим его курьеру";
      case OrderStatus.processing:
        return "Мы уже начали работать с вашим заказом";
      case OrderStatus.awaitingPayment:
        return "Товары готовы к сборке и ожидают оплаты.";
      default:
        return '';
    }
  }

  static String getOrderStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.courier:
        return Paths.carIconPath;
      case OrderStatus.readyToIssue:
        return Paths.boxIconPath;
      case OrderStatus.reserved:
        return Paths.hourglassIconPath;
      case OrderStatus.received:
        return Paths.flagIconPath;
      case OrderStatus.collected:
        return Paths.boxIconPath;
      case OrderStatus.processing:
        return Paths.clockIconPath;
      case OrderStatus.awaitingPayment:
        return Paths.cardIconPath;
      case OrderStatus.canceled:
        return Paths.cancelIconPath;
    }
  }

  static List<OrderStatus> getOrderStatuses(
      PaymentType? paymentType, TypeReceiving typeReceipt,
      {OrderStatus? orderStatus}) {
    List<OrderStatus> statuses = [];
    if (orderStatus == OrderStatus.canceled) {
      statuses = [
        OrderStatus.processing,
        OrderStatus.canceled,
      ];
    } else if (typeReceipt == TypeReceiving.pickup) {
      statuses = [
        OrderStatus.processing,
        OrderStatus.reserved,
        OrderStatus.readyToIssue,
        OrderStatus.received,
      ];
    } else if (typeReceipt == TypeReceiving.delivery) {
      statuses = [
        OrderStatus.processing,
        OrderStatus.awaitingPayment,
        OrderStatus.collected,
        OrderStatus.courier,
        OrderStatus.received,
      ];

      if (![PaymentType.bepaid, PaymentType.oplati].contains(paymentType)) {
        statuses.remove(OrderStatus.awaitingPayment);
      }
    }

    if (orderStatus == null) {
      statuses.add(OrderStatus.canceled);
    }

    return statuses;
  }

  static Map<String, dynamic> getNotNullFields(Map<String, dynamic> map) {
    return Map.from(map)..removeWhere((key, value) => value == null);
  }

  static String formatPhoneNumber(String? phoneNumber,
      {bool toServerFormat = true}) {
    if (phoneNumber == null || phoneNumber == '') return '';
    if (toServerFormat) {
      // Преобразование из клиентского формата в серверный
      final RegExp regex =
          RegExp(r'^\+375 \((\d{2})\) (\d{3})-(\d{2})-(\d{2})$');
      return phoneNumber.replaceAllMapped(
        regex,
        (match) => '+375${match[1]}-${match[2]}-${match[3]}-${match[4]}',
      );
    } else {
      // Преобразование из серверного формата в клиентский (учитываем дефисы)
      final RegExp regex = RegExp(r'^\+375(\d{2})-?(\d{3})-?(\d{2})-?(\d{2})$');

      return phoneNumber.replaceAllMapped(
        regex,
        (match) => '+375 (${match[1]}) ${match[2]}-${match[3]}-${match[4]}',
      );
    }
  }

  static void showCustomDialog(
      {required BuildContext screenContext,
      String? title,
      required String text,
      required Function(BuildContext context) action}) {
    showDialog(
      context: screenContext,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            action(context);
            return false; // Предотвращаем автоматическое закрытие
          },
          child: AlertDialog(
            backgroundColor: UiConstants.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title ?? 'Ошибка',
                  style: UiConstants.textStyle5
                      .copyWith(color: UiConstants.blackColor),
                ),
                GestureDetector(
                  onTap: () => action(context),
                  child: Icon(Icons.close,
                      color: UiConstants.blackColor, size: 25.w),
                ),
              ],
            ),
            content: Text(
              text,
              style: UiConstants.textStyle2
                  .copyWith(color: UiConstants.blackColor),
            ),
            actions: [
              AppButtonWidget(
                text: 'Ок',
                onTap: () => action(context),
              ),
            ],
          ),
        );
      },
    );
  }

  static String getProductCountText(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return '$count товар';
    } else if ((count % 10 >= 2 && count % 10 <= 4) &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return '$count товара';
    } else {
      return '$count товаров';
    }
  }

  static String getPharmacyLabel(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'аптеке';
    } else if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'аптеках';
    } else {
      return 'аптеках';
    }
  }

  static String formatPrice(double? price) {
    if (price == null) return '-';
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'ru_RU', symbol: 'р.');
    return formatter.format(price);
  }

  static Future<BitmapDescriptor> createBitmapIcon({int? count}) async {
    if (count == null) {
      final ByteData data = await rootBundle.load(Paths.mapPointPath);
      final Uint8List list = Uint8List.view(data.buffer);
      return BitmapDescriptor.fromBytes(list);
    }

    // Загружаем стандартную иконку
    final ByteData data = await rootBundle.load(Paths.mapPointWithoutCrossPath);
    final Uint8List list = Uint8List.view(data.buffer);
    final ui.Codec codec = await ui.instantiateImageCodec(list);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    // Рисуем поверх цифру
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final paint = Paint();

    // Рисуем основное изображение
    canvas.drawImage(image, Offset.zero, paint);

    // Настройки текста
    final textPainter = TextPainter(
        text: TextSpan(
          text: count.toString(),
          style: TextStyle(
              color: UiConstants.white2Color,
              fontSize: image.height * 0.45,
              fontWeight: FontWeight.bold),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr);

    textPainter.layout();
    final offset = Offset(
      (image.width - textPainter.width) / 2,
      (image.height - textPainter.height) / 2,
    );

    // Рисуем текст на холсте
    textPainter.paint(canvas, offset);

    final ui.Image newImage =
        await recorder.endRecording().toImage(image.width, image.height);
    final ByteData? newData =
        await newImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List newList = newData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(newList);
  }

  static final Map<String, String> _monthsGenitive = {
    'January': 'января',
    'February': 'февраля',
    'March': 'марта',
    'April': 'апреля',
    'May': 'мая',
    'June': 'июня',
    'July': 'июля',
    'August': 'августа',
    'September': 'сентября',
    'October': 'октября',
    'November': 'ноября',
    'December': 'декабря',
  };

  static String formatActionDate(
      DateTime? createDttm, DateTime? endActionDate) {
    if (createDttm == null) return ''; // Не показываем виджет

    final DateFormat monthFormat =
        DateFormat('MMMM', 'en'); // Получаем месяц на английском
    final DateFormat dayFormat = DateFormat('d'); // Формат дня

    String month = _monthsGenitive[monthFormat.format(createDttm)] ??
        ''; // Склонение месяца
    String startDay = dayFormat.format(createDttm); // Начальный день

    // Если конечная дата есть — используем её
    if (endActionDate != null) {
      String endDay = dayFormat.format(endActionDate);
      return 'с $startDay по $endDay $month';
    }

    // Если конечной даты нет — берём последнее число месяца
    DateTime lastDayOfMonth =
        DateTime(createDttm.year, createDttm.month + 1, 0);
    String endDay = dayFormat.format(lastDayOfMonth);

    return 'с $startDay по $endDay $month';
  }

  static void openJivoChat() {
    // Configure for authorized user
    Jivo.session.setContactInfo(
        name: sl<SharedPreferences>().getString(SharedPreferencesKeys.fullName),
        email: sl<SharedPreferences>().getString(SharedPreferencesKeys.email),
        phone: sl<SharedPreferences>().getString(SharedPreferencesKeys.phone),
        brief: "Pharmacy mobile app user");

    // ... or, configure for anonymous user
    Jivo.session.setup(
        channelId: dotenv.env['JIVO_CHANNEL_ID']!,
        userToken:
            sl<SharedPreferences>().getString(SharedPreferencesKeys.userId) ??
                '');

    Jivo.display.present();
  }

  static Future<void> openDocFile(String path, {String? name}) async {
    try {
      // Читаем файл из assets
      final ByteData data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();

      // Получаем временный каталог
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File(
          '${tempDir.path}/${name ?? Random().nextInt(1000000).toString()}.pdf');

      // Записываем файл
      await tempFile.writeAsBytes(bytes, flush: true);

      // Открываем файл
      final a = await OpenFile.open(tempFile.path);
      if (kDebugMode) {
        print(a);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при открытии файла: $e');
      }
    }
  }
}
