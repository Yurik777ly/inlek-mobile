part of 'sale_screen_bloc.dart';

class SaleScreenState extends Equatable {
  final bool isLoading;
  final ActionEntity? action;

  const SaleScreenState({
    this.isLoading = true,
    this.action,
  });

  SaleScreenState copyWith({
    bool? isLoading,
    ActionEntity? action,
  }) {
    return SaleScreenState(
      isLoading: isLoading ?? this.isLoading,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        action,
      ];
}
