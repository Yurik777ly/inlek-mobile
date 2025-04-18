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
}
