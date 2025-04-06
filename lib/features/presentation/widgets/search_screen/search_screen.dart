import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/params/product_param.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/search_screen/search_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/products/products_screen.dart';
import 'package:inlek/features/presentation/widgets/search_screen/popularity_requests_widget.dart';
import 'package:inlek/features/presentation/widgets/search_screen/search_products_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen(
      {super.key, required this.homeContext, required this.onRedirect});

  final BuildContext homeContext;
  final Function() onRedirect;

  @override
  Widget build(BuildContext context) {
    HomeScreenBloc homeBloc = homeContext.read<HomeScreenBloc>();
    return BlocBuilder<SearchScreenBloc, SearchScreenState>(
      builder: (searchContext, searchState) {
        final SearchScreenBloc searchBloc = context.read<SearchScreenBloc>();
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: UiConstants.backgroundColor,
          child: searchState.isLoading
              ? Center(
                  child:
                      CircularProgressIndicator(color: UiConstants.pink2Color),
                )
              : ListView(
                  padding: getMarginOrPadding(
                      top: 16, bottom: 140, left: 20, right: 20),
                  children: [
                    if (searchState.query.isEmpty)
                      searchState.historyRequests.isNotEmpty
                          ? Column(
                              children: [
                                PopularityRequestsWidget(
                                  title: 'История поиска',
                                  popularityRequests:
                                      searchState.historyRequests,
                                  onTap: (value) => searchBloc.add(
                                    ChangeQueryEvent(value),
                                  ),
                                  onTapDelete: (request) => searchBloc.add(
                                    DeleteHistoryRequestsEvent(
                                      [request],
                                    ),
                                  ),
                                  clearHistory: () => searchBloc.add(
                                    DeleteHistoryRequestsEvent(
                                        searchState.historyRequests),
                                  ),
                                ),
                                Container(
                                  padding:
                                      getMarginOrPadding(top: 16, bottom: 16),
                                  height: 34.h,
                                  child: Divider(
                                      color: UiConstants.white5Color,
                                      thickness: 2.h),
                                ),
                              ],
                            )
                          : Container()
                    else
                      Builder(
                        builder: (context) {
                          List<CategoryEntity> filteredSuggestions =
                              (searchState.searchResult?.categories ?? [])
                                  .take(5)
                                  .toList();
                          if (filteredSuggestions.isNotEmpty) {
                            return Column(
                              children: [
                                ListView.separated(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final suggestion =
                                          filteredSuggestions[index];

                                      return GestureDetector(
                                        onTap: () async {
                                          await onRedirect();

                                          searchBloc.add(
                                            SelectSuggestionsEvent(
                                                suggestion.categoryId!),
                                          );

                                          homeBloc
                                              .navigatorKeys[
                                                  homeBloc.selectedPageIndex]
                                              .currentState
                                              ?.push(
                                            Routes.createRoute(
                                              const ProductsScreen(),
                                              settings: RouteSettings(
                                                name: Routes.productsScreen,
                                                arguments: {
                                                  'title': suggestion.pageTitle,
                                                  'productParam': ProductParam(
                                                      categoryId:
                                                          suggestion.categoryId)
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(suggestion.pageTitle ?? '-',
                                            style: UiConstants.textStyle3
                                                .copyWith(
                                                    color: UiConstants
                                                        .darkBlueColor),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                      );
                                    },
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 16),
                                    itemCount: filteredSuggestions.length),
                                Container(
                                  padding:
                                      getMarginOrPadding(top: 16, bottom: 16),
                                  height: 34.h,
                                  child: Divider(
                                      color: UiConstants.white5Color,
                                      thickness: 2.h),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    if (searchState.query.isEmpty)
                      PopularityRequestsWidget(
                        title: 'Популярные запросы',
                        popularityRequests: searchState.popularityRequests,
                        onTap: (value) => searchBloc.add(
                          ChangeQueryEvent(value),
                        ),
                      )
                    else
                      BlocBuilder<CartScreenBloc, CartScreenState>(
                        builder: (context, state) {
                          return SearchProductsWidget(
                              products:
                                  searchState.searchResult?.products ?? [],
                              onProductTap: (int id) {
                                onRedirect();

                                searchBloc
                                    .add(ToggleExpandCollapseEvent(false));

                                homeBloc
                                    .navigatorKeys[homeBloc.selectedPageIndex]
                                    .currentState
                                    ?.push(
                                  Routes.createRoute(
                                    const ProductScreen(),
                                    settings: RouteSettings(
                                        name: Routes.productScreen,
                                        arguments: id),
                                  ),
                                );
                              });
                        },
                      ),
                  ],
                ),
        );
      },
    );
  }
}
