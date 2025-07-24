part of 'home_screen_bloc.dart';

abstract class HomeScreenEvent extends Equatable {
  const HomeScreenEvent();

  @override
  List<Object> get props => [];
}

class InitHomeEvent extends HomeScreenEvent {
  final bool initPersonalDataScreen;

  const InitHomeEvent({required this.initPersonalDataScreen});
}

class ChangePageEvent extends HomeScreenEvent {
  final int pageIndex;
  final bool forcePopToRoot;

  const ChangePageEvent(this.pageIndex, {this.forcePopToRoot = false});

  @override
  List<Object> get props => [pageIndex];
}

class CheckInternetConnection extends HomeScreenEvent {}

class UploadContext extends HomeScreenEvent {
  final BuildContext context;

  const UploadContext({required this.context});

  @override
  List<Object> get props => [context];
}
