import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/search_screen/search_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/products/products_screen.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/main_screen/daily_products_list_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/popularity_requests_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/search_products_widget.dart';
import 'package:inlek/locator_service.dart';

class SearchScreenPage extends StatelessWidget {
  const SearchScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchScreenBloc(
        searchProductsV2UC: sl(),
        getDailyProductsUC: sl(),
        sharedPreferences: sl(),
      )..add(LoadSearchDataEvent()),
      child: const _SearchScreenPageContent(),
    );
  }
}

class _SearchScreenPageContent extends StatefulWidget {
  const _SearchScreenPageContent();

  @override
  State<_SearchScreenPageContent> createState() =>
      _SearchScreenPageContentState();
}

class _SearchScreenPageContentState extends State<_SearchScreenPageContent> {
  @override
  void initState() {
    super.initState();
    // Устанавливаем фокус на текстовое поле после построения виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchBloc = context.read<SearchScreenBloc>();
      searchBloc.focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiConstants.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: UiConstants.whiteColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: BlocBuilder<SearchScreenBloc, SearchScreenState>(
          builder: (context, state) {
            final searchBloc = context.read<SearchScreenBloc>();
            return Column(
              children: [
                Container(
                  color: UiConstants.whiteColor,
                  padding: getMarginOrPadding(
                      top: 8, bottom: 8, right: 20, left: 20),
                  child: Row(
                    children: [
                      Padding(
                        padding: getMarginOrPadding(right: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(Paths.arrowBackIconPath,
                              color: UiConstants.darkBlue2Color.withOpacity(.6),
                              width: 24.dp,
                              height: 24.dp),
                        ),
                      ),
                      Expanded(
                        child: AppTextFieldWidget(
                          focusNode: searchBloc.focusNode,
                          hintText: 'Искать препараты',
                          controller: searchBloc.searchController,
                          fillColor: UiConstants.white2Color,
                          hintMaxLines: 1,
                          textInputAction: TextInputAction.search,
                          prefixWidget: SvgPicture.asset(Paths.searchIconPath),
                          suffixWidget: searchBloc
                                  .searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () =>
                                      searchBloc.add(ClearQueryEvent()),
                                  child: SvgPicture.asset(Paths.closeIconPath),
                                )
                              : null,
                          onFieldSubmitted: !state.isLoading
                              ? (p0) => Navigator.push(
                                    context,
                                    Routes.createRoute(
                                      const ProductsScreen(),
                                      settings: RouteSettings(
                                        name: Routes.productsScreen,
                                        arguments: {
                                          'title': 'Результаты поиска',
                                          'products':
                                              state.searchResult?.products ?? []
                                        },
                                      ),
                                    ),
                                  )
                              : null,
                          onChangedField: (p0) =>
                              searchBloc.add(ChangeQueryEvent(p0)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: UiConstants.pink2Color,
                          ),
                        );
                      }

                      final hasQuery = state.query.length >= 3;
                      final products = state.searchResult?.products ?? [];

                      if (hasQuery && products.isEmpty) {
                        return Column(
                          children: [
                            Padding(
                              padding: getMarginOrPadding(
                                  left: 20, right: 20, top: 16),
                              child: Text(
                                'Ничего не найдено по запросу «${state.query}»',
                                style: UiConstants.textStyle5.copyWith(
                                    color: UiConstants.darkBlue2Color
                                        .withOpacity(.6)),
                              ),
                            ),
                            32.ph,
                            if ((state.recommendedProducts).isNotEmpty)
                              BlockWidget(
                                contentPadding:
                                    getMarginOrPadding(left: 20, right: 20),
                                title: 'Рекомендуемые продукты',
                                //clickableText: 'Все товары',
                                onTap: () => Navigator.of(context).push(
                                  Routes.createRoute(
                                    ProductsScreen(),
                                    settings: RouteSettings(
                                      name: Routes.productsScreen,
                                      arguments: {
                                        'title': 'Рекомендуемые продукты',
                                        'products': state.recommendedProducts,
                                      },
                                    ),
                                  ),
                                ),
                                child: ProductsListWidget(
                                    products: state.recommendedProducts),
                              ),
                          ],
                        );
                      }

                      return ListView(
                        padding: getMarginOrPadding(
                          top: 16,
                          bottom: 94,
                          left: 20,
                          right: 20,
                        ),
                        children: [
                          if (!hasQuery && state.historyRequests.isNotEmpty)
                            _buildHistoryBlock(state, searchBloc),
                          if (hasQuery)
                            _buildSuggestionsBlock(state, searchBloc),
                          hasQuery
                              ? _buildSearchResults(state, searchBloc)
                              : _buildPopularBlock(state, searchBloc),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryBlock(
      SearchScreenState state, SearchScreenBloc searchBloc) {
    return Column(
      children: [
        PopularityRequestsWidget(
          title: 'История поиска',
          popularityRequests: state.historyRequests,
          onTap: (value) {
            searchBloc.add(ChangeQueryEvent(value));
            searchBloc.searchController.text = value;
          },
          onTapDelete: (request) =>
              searchBloc.add(DeleteHistoryRequestsEvent([request])),
          clearHistory: () =>
              searchBloc.add(DeleteHistoryRequestsEvent(state.historyRequests)),
        ),
        _divider(),
      ],
    );
  }

  Widget _buildSuggestionsBlock(
      SearchScreenState state, SearchScreenBloc searchBloc) {
    final suggestions = (state.searchResult?.categories ?? []).take(5).toList();
    final queries = state.searchResult?.queries ?? [];

    if (suggestions.isEmpty && queries.isEmpty) return const SizedBox();

    return Column(
      children: [
        // Результаты поиска (queries)
        if (queries.isNotEmpty) ...[
          BlockWidget(
            title: 'Результаты поиска',
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: queries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final query = queries[index];
                return GestureDetector(
                  onTap: () {
                    searchBloc.add(ChangeQueryEvent(query));
                    searchBloc.searchController.text = query;
                  },
                  child: Text(
                    query,
                    style: UiConstants.textStyle3
                        .copyWith(color: UiConstants.darkBlueColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          _divider(),
        ],

        // Категории
        if (suggestions.isNotEmpty) ...[
          BlockWidget(
            title: 'Категории',
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return GestureDetector(
                  onTap: () {
                    //searchBloc.add(SelectSuggestionsEvent(suggestion.categoryId!));
                    Navigator.push(
                      context,
                      Routes.createRoute(
                        const ProductsScreen(),
                        settings: RouteSettings(
                          name: Routes.productsScreen,
                          arguments: {
                            'title': suggestion.pageTitle,
                            'productParam': ProductParam(
                              categoryId: suggestion.categoryId,
                            ),
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    suggestion.pageTitle ?? '-',
                    style: UiConstants.textStyle3
                        .copyWith(color: UiConstants.darkBlueColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          _divider(),
        ],
      ],
    );
  }

  Widget _buildPopularBlock(
      SearchScreenState state, SearchScreenBloc searchBloc) {
    return PopularityRequestsWidget(
      title: 'Популярные запросы',
      popularityRequests: state.popularityRequests,
      onTap: (value) => searchBloc.add(ChangeQueryEvent(value)),
    );
  }

  Widget _buildSearchResults(
      SearchScreenState state, SearchScreenBloc searchBloc) {
    return BlocBuilder<CartScreenBloc, CartScreenState>(
      builder: (context, _) {
        return SearchProductsWidget(
          products: state.searchResult?.products ?? [],
          onProductTap: (id) {
            Navigator.push(
              context,
              Routes.createRoute(
                const ProductScreen(),
                settings: RouteSettings(
                  name: Routes.productScreen,
                  arguments: {'id': id},
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: getMarginOrPadding(bottom: 16),
      child: Text(
        title,
        style: UiConstants.textStyle5.copyWith(
          color: UiConstants.darkBlueColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _divider() => Padding(
        padding: getMarginOrPadding(top: 16, bottom: 16),
        child: Divider(
          color: UiConstants.white5Color,
          thickness: 2.dp,
          height: 34.dp,
        ),
      );
}
