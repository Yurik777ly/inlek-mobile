import 'package:inlek/constants/external_links.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlUtils {
  static Future<void> openTikTokProfile() async {
    // Попытка открыть через приложение TikTok
    final appUrl = Uri.parse(ExternalLinks.tiktokAppUrl);

    // Если приложение не установлено — откроется через браузер
    final webUrl = Uri.parse(ExternalLinks.tiktokWebUrl);

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openInstagramProfile() async {
    final appUrl = Uri.parse(ExternalLinks.instagramAppUrl);
    final webUrl = Uri.parse(ExternalLinks.instagramWebUrl);

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Не удалось запустить телефонное приложение для номера: $phoneNumber';
    }
  }

  static Future<void> sendEmail({
    required String toEmail,
    String? subject,
    String? body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }
          .entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&'),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Не удалось открыть приложение почты для адреса: $toEmail';
    }
  }
}
