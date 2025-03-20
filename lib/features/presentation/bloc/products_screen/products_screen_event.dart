part of 'products_screen_bloc.dart';

abstract class ProductsScreenEvent extends Equatable {
  const ProductsScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadDataEvent extends ProductsScreenEvent {}

class ChangeProductSortTypeEvent extends ProductsScreenEvent {
  final ProductSortType productSortType;

  const ChangeProductSortTypeEvent(this.productSortType);

  @override
  List<Object> get props => [productSortType];
}
