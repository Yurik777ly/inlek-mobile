import 'package:flutter/material.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/search_history_item.dart';

class SearchHistoryWidget extends StatelessWidget {
  const SearchHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlockWidget(
      title: 'История поиска',
      clickableText: 'Очистить',
      onTap: () {},
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 8.dp,
          runSpacing: 8.dp,
          children: [
            SearchHistoryItem(
              title: 'Терафлю',
              onTap: () {},
              onTapDelete: () {},
            ),
            SearchHistoryItem(
              title: 'Виши',
              onTap: () {},
              onTapDelete: () {},
            ),
            SearchHistoryItem(
              title: 'Солгар',
              onTap: () {},
              onTapDelete: () {},
            ),
            SearchHistoryItem(
              title: 'Термометр',
              onTap: () {},
              onTapDelete: () {},
            ),
            SearchHistoryItem(
              title: 'Хлоргексидина биклюконат',
              onTap: () {},
              onTapDelete: () {},
            ),
          ],
        ),
      ),
    );
  }
}
