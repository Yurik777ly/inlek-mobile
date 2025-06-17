import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/custom_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomFlutterHtml extends StatelessWidget {
  const CustomFlutterHtml(
      {super.key, required this.isLoading, required this.content});

  final bool isLoading;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Html(
      extensions: [
        TagExtension(
          tagsToExtend: {"img"},
          builder: (context) {
            final attributes = context.attributes;
            String? src = attributes['src'];

            // Обработка относительных ссылок
            if (src != null && !src.startsWith('http')) {
              src = '${dotenv.env['PUBLIC_URL']!}$src';
            }

            return src != null
                ? CachedNetworkImage(
                    imageUrl: src,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    cacheManager: CustomCacheManager(),
                    errorWidget: (context, url, error) => Icon(Icons.image,
                        size: 56.w, color: UiConstants.whiteColor),
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child: CircularProgressIndicator(
                        color: UiConstants.pink2Color,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
      data: isLoading ? Utils.mockHtml : content,
      style: {
        "p": Utils.htmlStyle,
        "li": Utils.htmlStyle,
        "*": Style(
          margin: Margins(
            blockStart: Margin(0),
            blockEnd: Margin(0),
            left: Margin(0),
            right: Margin(0),
          ),
          padding: HtmlPaddings(
            blockStart: HtmlPadding(0),
            blockEnd: HtmlPadding(0),
          ),
        ),
      },
      onLinkTap: (url, attributes, element) async {
        String? formatterUrl = url;
        if (formatterUrl != null) {
          // Если URL не начинается с http:// или https:// — добавим PUBLIC_URL
          if (!formatterUrl.startsWith('http://') &&
              !formatterUrl.startsWith('https://')) {
            formatterUrl = '${dotenv.env['PUBLIC_URL']!}$formatterUrl';
          }

          final uri = Uri.parse(formatterUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
    );
  }
}
