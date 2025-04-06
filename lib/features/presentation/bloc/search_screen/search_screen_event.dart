part of 'search_screen_bloc.dart';

abstract class SearchScreenEvent extends Equatable {
  const SearchScreenEvent();

  @override
  List<Object?> get props => [];
}

class LoadDataEvent extends SearchScreenEvent {}

class ToggleExpandCollapseEvent extends SearchScreenEvent {
  final bool isExpanded;
  const ToggleExpandCollapseEvent(this.isExpanded);

  @override
  List<Object?> get props => [isExpanded];
}

class SelectSuggestionsEvent extends SearchScreenEvent {
  final int categoryId;
  const SelectSuggestionsEvent(this.categoryId);

  @override
  List<Object?> get props => [];
}

class ChangeQueryEvent extends SearchScreenEvent {
  final String text;
  const ChangeQueryEvent(this.text);

  @override
  List<Object?> get props => [];
}

class ExecuteSearchEvent extends SearchScreenEvent {
  final String text;
  const ExecuteSearchEvent(this.text);

  @override
  List<Object?> get props => [];
}

class DeleteHistoryRequestsEvent extends SearchScreenEvent {
  final List<String> requests;
  const DeleteHistoryRequestsEvent(this.requests);

  @override
  List<Object?> get props => [];
}

class ClearQueryEvent extends SearchScreenEvent {
  const ClearQueryEvent();

  @override
  List<Object?> get props => [];
}
