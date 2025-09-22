import 'package:flutter/material.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';
import 'package:inlek/features/presentation/pages/catalog/category_screen.dart';
import 'package:inlek/features/presentation/widgets/main_screen/category_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CategoriesGridWidget extends StatelessWidget {
  const CategoriesGridWidget({
    super.key,
    required this.categories,
    this.contentPadding,
  });

  final List<CategoryEntity> categories;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    double itemHeight = 128.dp;
    double itemWidth = 156.dp;
    return Skeleton.shade(
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: contentPadding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.dp,
          mainAxisSpacing: 8.dp,
          childAspectRatio: itemWidth / itemHeight,
        ),
        itemCount: categories.length,
        // Количество элементов
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              Routes.createRoute(
                CategoryScreen(
                  categoryId: category.categoryId,
                  categoryTitle: category.pageTitle,
                ),
                settings: RouteSettings(name: Routes.categoryScreen),
              ),
            ),
            child: CategoryWidget(
                imagePath: category.image ?? '',
                title: category.pageTitle ?? ''),
          );
        },
      ),
    );
  }
}
