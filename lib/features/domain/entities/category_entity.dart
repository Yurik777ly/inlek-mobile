import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int? categoryId;

  final String? pageTitle;
  final String? alias;
  final String? image;

  const CategoryEntity({
    this.categoryId,
    this.pageTitle,
    this.alias,
    this.image,
  });

  CategoryEntity copyWith({
    int? categoryId,
    String? pageTitle,
    String? alias,
    String? image,
  }) =>
      CategoryEntity(
        categoryId: categoryId ?? this.categoryId,
        pageTitle: pageTitle ?? this.pageTitle,
        alias: alias ?? this.alias,
        image: image ?? this.image,
      );

  @override
  List<Object?> get props => [
        categoryId,
        pageTitle,
        alias,
        image,
      ];
}
