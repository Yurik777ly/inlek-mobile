part of 'search_screen_bloc.dart';

class SearchScreenState extends Equatable {
  final bool isLoading;
  final bool isExpanded;
  final String query;
  final SearchProductsV2Entity? searchResult;
  final List<String> historyRequests;
  final List<String> popularityRequests;
  final List<ProductEntity> recommendedProducts;

  const SearchScreenState({
    this.isLoading = false,
    this.isExpanded = false,
    this.query = '',
    this.searchResult,
    this.historyRequests = const [],
    this.popularityRequests = const [
      'Терафлю',
      'Виши',
      'Солгар',
      'Термометр',
      'Хлоргексидина биклюконат',
    ],
    this.recommendedProducts = const [],
  });

  SearchScreenState copyWith({
    bool? isLoading,
    bool? isExpanded,
    String? query,
    SearchProductsV2Entity? searchResult,
    List<String>? historyRequests,
    List<String>? popularityRequests,
    List<ProductEntity>? recommendedProducts,
  }) {
    return SearchScreenState(
      isLoading: isLoading ?? this.isLoading,
      isExpanded: isExpanded ?? this.isExpanded,
      query: query ?? this.query,
      searchResult: searchResult ?? this.searchResult,
      historyRequests: historyRequests ?? this.historyRequests,
      popularityRequests: popularityRequests ?? this.popularityRequests,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isExpanded,
        query,
        searchResult,
        historyRequests,
        popularityRequests,
        recommendedProducts,
      ];
}
