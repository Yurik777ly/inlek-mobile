import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/domain/entities/search_products_v2_entity.dart';
import 'package:inlek/features/domain/usecases/products/search_products_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_screen_event.dart';
part 'search_screen_state.dart';

class SearchScreenBloc extends Bloc<SearchScreenEvent, SearchScreenState> {
  final SearchProductsV2UC searchProductsV2UC;
  final SharedPreferences sharedPreferences;

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  Timer? _debounceTimer;

  SearchScreenBloc(
      {required this.searchProductsV2UC, required this.sharedPreferences})
      : super(SearchScreenState()) {
    on<LoadDataEvent>(_onLoadData);
    on<ToggleExpandCollapseEvent>(_onToggleExpandCollapse);
    on<ClearQueryEvent>(_onClearQuery);
    on<ChangeQueryEvent>(_onChangeQuery);
    on<ExecuteSearchEvent>(_onExecuteSearch);
    on<SelectSuggestionsEvent>(_onSelectSuggestions);
    on<DeleteHistoryRequestsEvent>(_onDeleteHistoryRequests);
  }

  Future<void> _onLoadData(
      LoadDataEvent event, Emitter<SearchScreenState> emit) async {
    List<String> savedRequests = sharedPreferences
            .getStringList(SharedPreferencesKeys.popularRequests) ??
        [];

    emit(state.copyWith(historyRequests: savedRequests));
  }

  void _onChangeQuery(ChangeQueryEvent event, Emitter<SearchScreenState> emit) {
    searchController.text = event.text;

    emit(state.copyWith(query: event.text));

    _debounceTimer?.cancel(); // Отмена предыдущего таймера
    if (event.text.isEmpty) {
      emit(state.copyWith(isLoading: false, searchResult: null));
      return;
    }

    emit(state.copyWith(isLoading: true));

    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      _saveRequestToSharedPrefs(event.text);
      add(ExecuteSearchEvent(
          event.text)); // Вместо await выполняем через новое событие
    });
  }

  void _onExecuteSearch(
      ExecuteSearchEvent event, Emitter<SearchScreenState> emit) async {
    // заполняем в стейте historyRequests из SharedPreferencesKeys
    emit(state.copyWith(
        historyRequests: sharedPreferences
            .getStringList(SharedPreferencesKeys.popularRequests)));

    final failureOrLoads = await searchProductsV2UC(event.text);

    failureOrLoads.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (result) => emit(state.copyWith(searchResult: result, isLoading: false)),
    );
  }

  void _saveRequestToSharedPrefs(String query) async {
    List<String> savedRequests = sharedPreferences
            .getStringList(SharedPreferencesKeys.popularRequests) ??
        [];

    // Проверяем, есть ли уже такой запрос
    if (!savedRequests.contains(query)) {
      if (savedRequests.length >= 8) {
        savedRequests.removeLast(); // Удаляем последнее значение
      }
      savedRequests.insert(0, query); // Добавляем новое первым элементом
      await sharedPreferences.setStringList(
          SharedPreferencesKeys.popularRequests, savedRequests);
    }
  }

  void _onDeleteHistoryRequests(
      DeleteHistoryRequestsEvent event, Emitter<SearchScreenState> emit) async {
    List<String> savedRequests = sharedPreferences
            .getStringList(SharedPreferencesKeys.popularRequests) ??
        [];

    for (String request in event.requests) {
      savedRequests.remove(request);
    }

    await sharedPreferences.setStringList(
        SharedPreferencesKeys.popularRequests, savedRequests);

    emit(state.copyWith(historyRequests: savedRequests));
  }

  void _onSelectSuggestions(
      SelectSuggestionsEvent event, Emitter<SearchScreenState> emit) {
    searchController.clear();
    _debounceTimer?.cancel();
    emit(state.copyWith(
        isExpanded: false, query: '', searchResult: null, isLoading: false));
  }

  void _onClearQuery(ClearQueryEvent event, Emitter<SearchScreenState> emit) {
    searchController.clear();
    _debounceTimer?.cancel();
    emit(state.copyWith(
        isExpanded: false, query: '', searchResult: null, isLoading: false));
  }

  void _onToggleExpandCollapse(
      ToggleExpandCollapseEvent event, Emitter<SearchScreenState> emit) {
    emit(state.copyWith(isExpanded: event.isExpanded));
  }

  @override
  Future<void> close() {
    searchController.dispose();
    _debounceTimer?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
