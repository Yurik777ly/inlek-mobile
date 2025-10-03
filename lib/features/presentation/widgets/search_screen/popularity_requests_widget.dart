import 'package:flutter/material.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/search_history_item.dart';

class PopularityRequestsWidget extends StatelessWidget {
  const PopularityRequestsWidget({
    super.key,
    required this.title,
    required this.popularityRequests,
    required this.onTap,
    this.onTapDelete,
    this.clearHistory,
  });

  final String title;
  final List<String> popularityRequests;
  final Function(String request) onTap;
  final Function(String request)? onTapDelete;
  final Function()? clearHistory;

  @override
  Widget build(BuildContext context) {
    return BlockWidget(
      title: title,
      clickableText: clearHistory != null ? 'Очистить' : null,
      onTap: clearHistory,
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            popularityRequests.length,
            (index) {
              String request = popularityRequests[index];
              return SearchHistoryItem(
                  title: request,
                  onTap: () => onTap(request),
                  onTapDelete:
                      onTapDelete != null ? () => onTapDelete!(request) : null);
            },
          ),
        ),
      ),
    );
  }
}
