part of 'home_screen_bloc.dart';

abstract class HomeScreenState extends Equatable {
  final BuildContext? context;

  const HomeScreenState({this.context});

  // Базовый copyWith — только для context
  HomeScreenState copyWith({BuildContext? context});

  @override
  List<Object?> get props => [context];
}

class HomeScreenInitial extends HomeScreenState {
  @override
  final BuildContext? context;

  @override
  const HomeScreenInitial({this.context});

  @override
  HomeScreenInitial copyWith({BuildContext? context}) {
    return HomeScreenInitial(context: context ?? this.context);
  }

  @override
  List<Object?> get props => [context];
}

class HomeScreenPageChanged extends HomeScreenState {
  final int selectedPageIndex;

  const HomeScreenPageChanged(this.selectedPageIndex, {super.context});

  @override
  HomeScreenPageChanged copyWith(
      {int? selectedPageIndex, BuildContext? context}) {
    return HomeScreenPageChanged(
      selectedPageIndex ?? this.selectedPageIndex,
      context: context ?? this.context,
    );
  }

  @override
  List<Object?> get props => [selectedPageIndex, context];
}

class InternetUnavailable extends HomeScreenState {
  const InternetUnavailable({super.context});

  @override
  InternetUnavailable copyWith({BuildContext? context}) {
    return InternetUnavailable(context: context ?? this.context);
  }
}
