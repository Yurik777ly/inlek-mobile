part of 'select_region_screen_bloc.dart';

abstract class SelectRegionScreenEvent extends Equatable {
  const SelectRegionScreenEvent();

  @override
  List<Object> get props => [];
}

class LoadDataEvent extends SelectRegionScreenEvent {
  @override
  List<Object> get props => [];
}

class RegionChangedEvent extends SelectRegionScreenEvent {
  final String region;

  const RegionChangedEvent(this.region);

  @override
  List<Object> get props => [region];
}

class ConfirmRegionEvent extends SelectRegionScreenEvent {
  final BuildContext context;
  const ConfirmRegionEvent({required this.context});

  @override
  List<Object> get props => [context];
}

class DetectCurrentCityEvent extends SelectRegionScreenEvent {}
