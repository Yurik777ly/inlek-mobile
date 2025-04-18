import 'dart:async';

import 'package:uni_links5/uni_links.dart';

class UniLinksManager {
  static final StreamController<Uri> _uriStreamController =
      StreamController<Uri>.broadcast();

  static StreamSubscription<String?>? _sub;

  Stream<Uri> get uriStream => _uriStreamController.stream;

  Future<void> init() async {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleLink(initialLink);
    }

    _sub = linkStream.listen(
      (String? link) {
        if (link != null) _handleLink(link);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  static void _handleLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri != null) {
      print("Handle deep link: $uri");
      _uriStreamController.add(uri); // 👈 отправляем в стрим
    }
  }

  void dispose() {
    _sub?.cancel();
    _uriStreamController.close();
  }
}
