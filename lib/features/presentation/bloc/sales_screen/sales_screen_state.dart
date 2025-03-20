part of 'sales_screen_bloc.dart';

class SalesScreenState extends Equatable {
  final bool isLoading;
  final List<ActionEntity>? actions;

  const SalesScreenState({
    this.isLoading = true,
    this.actions,
  });

  SalesScreenState copyWith({
    bool? isLoading,
    List<ActionEntity>? actions,
  }) {
    return SalesScreenState(
      isLoading: isLoading ?? this.isLoading,
      actions: actions ?? this.actions,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        actions,
      ];
}
