import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/domain/entities/product_entity.dart';
import 'package:inlek/features/domain/entities/search_products_v2_entity.dart';
import 'package:inlek/features/domain/usecases/products/get_daily_products.dart';
import 'package:inlek/features/domain/usecases/products/search_products_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_screen_event.dart';
part 'search_screen_state.dart';

class SearchScreenBloc extends Bloc<SearchScreenEvent, SearchScreenState> {
  final SearchProductsV2UC searchProductsV2UC;
  final SharedPreferences sharedPreferences;
  final GetDailyProductsUC getDailyProductsUC;

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  Timer? _debounceTimer;

  SearchScreenBloc(
      {required this.searchProductsV2UC,
      required this.getDailyProductsUC,
      required this.sharedPreferences})
      : super(SearchScreenState()) {
    on<LoadSearchDataEvent>(_onLoadData);
    on<ToggleExpandCollapseEvent>(_onToggleExpandCollapse);
    on<ClearQueryEvent>(_onClearQuery);
    on<ChangeQueryEvent>(_onChangeQuery);
    on<ExecuteSearchEvent>(_onExecuteSearch);
    on<SelectSuggestionsEvent>(_onSelectSuggestions);
    on<DeleteHistoryRequestsEvent>(_onDeleteHistoryRequests);
  }

  Future<void> _onLoadData(
      LoadSearchDataEvent event, Emitter<SearchScreenState> emit) async {
    // Сначала эмитим данные истории сразу (синхронно)
    List<String> savedRequests = sharedPreferences
            .getStringList(SharedPreferencesKeys.popularRequests) ??
        [];

    print('Loading history requests: $savedRequests');
    emit(state.copyWith(historyRequests: savedRequests));

    // Затем асинхронно загружаем daily продукты
    List<ProductEntity> recommendedProducts = [];
    final failureOrLoads = await getDailyProductsUC();

    failureOrLoads.fold((_) {}, (products) {
      recommendedProducts = products;
    });

    // Эмитим обновленное состояние с daily продуктами
    emit(state.copyWith(recommendedProducts: recommendedProducts));
  }

  void _onChangeQuery(ChangeQueryEvent event, Emitter<SearchScreenState> emit) {
    emit(state.copyWith(query: event.text));

    _debounceTimer?.cancel(); // Отмена предыдущего таймера
    if (event.text.length < 3) {
      emit(state.copyWith(isLoading: false, searchResult: null));
      return;
    }

    emit(state.copyWith(isLoading: true));

    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      add(ExecuteSearchEvent(event.text));
    });
  }

  void _onExecuteSearch(
      ExecuteSearchEvent event, Emitter<SearchScreenState> emit) async {
    emit(
      state.copyWith(
        searchResult:
            SearchProductsV2Entity(categories: [], products: [], queries: []),
      ),
    );

    final failureOrLoads = await searchProductsV2UC(event.text);

    failureOrLoads.fold(
      (_) => emit(
        state.copyWith(isLoading: false),
      ),
      (result) {
        if (result != null) {
          // Проверяем, есть ли результаты (продукты, категории или queries)
          final hasResults = (result.products.isNotEmpty ||
              result.categories.isNotEmpty ||
              result.queries.isNotEmpty);

          emit(state.copyWith(searchResult: result, isLoading: false));

          // Сохраняем запрос только если есть результаты
          if (hasResults) {
            _saveRequestToSharedPrefs(event.text, emit);
          }
        } else {
          emit(state.copyWith(isLoading: false));
        }
      },
    );
  }

  void _saveRequestToSharedPrefs(
      String query, Emitter<SearchScreenState> emit) async {
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

      // Обновляем стейт с новым списком истории
      print('Saving request to history: $query, new list: $savedRequests');
      emit(state.copyWith(historyRequests: savedRequests));
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
