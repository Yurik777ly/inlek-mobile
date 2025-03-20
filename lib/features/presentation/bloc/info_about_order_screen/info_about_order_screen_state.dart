part of 'info_about_order_screen_bloc.dart';

class InfoAboutOrderScreenState extends Equatable {
  final bool isLoading;
  final List<MapMarkerModel>? points;

  const InfoAboutOrderScreenState({
    this.isLoading = true,
    this.points,
  });

  InfoAboutOrderScreenState copyWith({
    bool? isLoading,
    List<MapMarkerModel>? points,
  }) {
    return InfoAboutOrderScreenState(
      isLoading: isLoading ?? this.isLoading,
      points: points ?? this.points,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        points,
      ];
}
