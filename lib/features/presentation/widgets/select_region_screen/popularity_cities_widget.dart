import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/features/domain/entities/city_entity.dart';
import 'package:inlek/features/presentation/bloc/select_region_screen/select_region_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/search_history_item.dart';

class PopularityCitiesWidget extends StatelessWidget {
  const PopularityCitiesWidget(
      {super.key, required this.onTapRegion, required this.regions});

  final Function(CityEntity region) onTapRegion;
  final List<CityEntity> regions;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectRegionScreenBloc, SelectRegionScreenState>(
      builder: (context, state) {
        return BlockWidget(
          title: 'Популярные города',
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                regions.length,
                (index) => SearchHistoryItem(
                  title: regions[index].pagetitle,
                  onTap: () => onTapRegion(
                    regions[index],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
