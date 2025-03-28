part of 'products_screen_bloc.dart';

abstract class ProductsScreenEvent extends Equatable {
  const ProductsScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadDataEvent extends ProductsScreenEvent {
  final int? page;

  const LoadDataEvent({this.page});

  @override
  List<Object?> get props => [page];
}

class ChangeProductSortTypeEvent extends ProductsScreenEvent {
  final ProductSortType productSortType;

  const ChangeProductSortTypeEvent(this.productSortType);

  @override
  List<Object> get props => [productSortType];
}
