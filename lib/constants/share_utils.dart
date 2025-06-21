import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inlek/constants/enums.dart';
import 'package:share_plus/share_plus.dart';

class ShareUtils {
  static Future<void> shareUrl(ShareUrlType shareUrlType, String id) async {
    final baseUrl = dotenv.env['SHARE_URL']!;
    final shareUrl = '$baseUrl${shareUrlType.name}/$id';

    await Share.share(shareUrl);
  }
}
