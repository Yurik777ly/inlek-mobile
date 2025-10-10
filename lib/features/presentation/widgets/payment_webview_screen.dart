import 'package:flutter/material.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final VoidCallback? onPaymentCompleted;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    this.onPaymentCompleted,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            print(1);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final link = request.url;
            debugPrint('[WebView] redirect → $link');

            // Проверяем редирект на бэкенд после успешной оплаты
            if (link.startsWith("https://test.mobile.apteka-online.by/main")) {
              final uri = Uri.parse(link);

              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalNonBrowserApplication,
                );
              }

              // Вызываем callback для обновления заказа
              if (widget.onPaymentCompleted != null) {
                widget.onPaymentCompleted!();
              }

              if (mounted) Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Оплата заказа',
              showBack: true,
              backgroundColor: UiConstants.backgroundColor,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}

