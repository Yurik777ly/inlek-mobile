import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/search_screen/search_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/products/products_screen.dart';
import 'package:inlek/features/presentation/widgets/search_screen/popularity_requests_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/search_products_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({
    super.key,
    required this.homeContext,
    required this.onRedirect,
  });

  final BuildContext homeContext;
  final Function() onRedirect;

  @override
  Widget build(BuildContext context) {
    final homeBloc = homeContext.read<HomeScreenBloc>();

    return BlocBuilder<SearchScreenBloc, SearchScreenState>(
      builder: (context, state) {
        final searchBloc = context.read<SearchScreenBloc>();

        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: UiConstants.backgroundColor,
          child: _buildBody(context, state, searchBloc, homeBloc),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SearchScreenState state,
      SearchScreenBloc searchBloc, HomeScreenBloc homeBloc) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: UiConstants.pink2Color,
        ),
      );
    }

    final hasQuery = state.query.isNotEmpty;
    final products = state.searchResult?.products ?? [];

    if (hasQuery && products.isEmpty) {
      return Center(
        child: Text(
          'Ничего не найдено',
          style: UiConstants.textStyle3.copyWith(
            color: UiConstants.darkBlueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return ListView(
      padding: getMarginOrPadding(top: 16, bottom: 140, left: 20, right: 20),
      children: [
        if (!hasQuery && state.historyRequests.isNotEmpty)
          _buildHistoryBlock(state, searchBloc),
        if (hasQuery) _buildSuggestionsBlock(state, searchBloc, homeBloc),
        hasQuery
            ? _buildSearchResults(state, searchBloc, homeBloc)
            : _buildPopularBlock(state, searchBloc),
      ],
    );
  }

  Widget _buildHistoryBlock(
      SearchScreenState state, SearchScreenBloc searchBloc) {
    return Column(
      children: [
        PopularityRequestsWidget(
          title: 'История поиска',
          popularityRequests: state.historyRequests,
          onTap: (value) => searchBloc.add(ChangeQueryEvent(value)),
          onTapDelete: (request) =>
              searchBloc.add(DeleteHistoryRequestsEvent([request])),
          clearHistory: () =>
              searchBloc.add(DeleteHistoryRequestsEvent(state.historyRequests)),
        ),
        _divider(),
      ],
    );
  }

  Widget _buildSuggestionsBlock(SearchScreenState state,
      SearchScreenBloc searchBloc, HomeScreenBloc homeBloc) {
    final suggestions = (state.searchResult?.categories ?? []).take(5).toList();
    if (suggestions.isEmpty) return const SizedBox();

    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return GestureDetector(
              onTap: () async {
                await onRedirect();
                searchBloc.add(SelectSuggestionsEvent(suggestion.categoryId!));
                homeBloc.navigatorKeys[homeBloc.selectedPageIndex].currentState
                    ?.push(
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
        _divider(),
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

  Widget _buildSearchResults(SearchScreenState state,
      SearchScreenBloc searchBloc, HomeScreenBloc homeBloc) {
    return BlocBuilder<CartScreenBloc, CartScreenState>(
      builder: (context, _) {
        return SearchProductsWidget(
          products: state.searchResult?.products ?? [],
          onProductTap: (id) {
            onRedirect();
            searchBloc.add(ToggleExpandCollapseEvent(false));

            homeBloc.navigatorKeys[homeBloc.selectedPageIndex].currentState
                ?.push(
              Routes.createRoute(
                const ProductScreen(),
                settings: RouteSettings(
                  name: Routes.productScreen,
                  arguments: id,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _divider() => Padding(
        padding: getMarginOrPadding(top: 16, bottom: 16),
        child: Divider(
          color: UiConstants.white5Color,
          thickness: 2.h,
          height: 34.h,
        ),
      );
}
