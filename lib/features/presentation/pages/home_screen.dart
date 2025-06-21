import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/app_route_observer.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/route_observer/route_observer_bloc.dart';
import 'package:inlek/features/presentation/bloc/search_screen/search_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
import 'package:inlek/features/presentation/pages/main/banner_screen.dart';
import 'package:inlek/features/presentation/pages/profile/articles/article_screen.dart';
import 'package:inlek/features/presentation/pages/profile/news/news_internal_screen.dart';
import 'package:inlek/features/presentation/pages/profile/sales/sale_screen.dart';
import 'package:inlek/features/presentation/widgets/bottom_navigation_bar_tile.dart';
import 'package:inlek/features/presentation/widgets/search_screen/search_screen.dart';
import 'package:inlek/locator_service.dart';
import 'package:uni_links5/uni_links.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageStorageBucket bucket = PageStorageBucket();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    UiConstants.homeContext = context;

    _handleInitialUri();
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeeplink(uri);
      }
    });
  }

  Future<void> _handleInitialUri() async {
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeeplink(initialUri);
    }
  }

  void _handleDeeplink(Uri uri) {
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return;

    final homeBloc = sl<HomeScreenBloc>();

    switch (pathSegments[0]) {
      case 'product':
        if (pathSegments.length > 1) {
          final id = int.tryParse(pathSegments[1]);
          if (id != null) {
            homeBloc.navigatorKeys[homeBloc.selectedPageIndex].currentState
                ?.push(
              Routes.createRoute(
                const ProductScreen(),
                settings:
                    RouteSettings(name: Routes.productScreen, arguments: id),
              ),
            );
          }
        }
        break;
      case 'banner':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          homeBloc.navigatorKeys[homeBloc.selectedPageIndex].currentState?.push(
            Routes.createRoute(
              const BannerScreen(),
              settings: RouteSettings(name: Routes.bannerScreen, arguments: id),
            ),
          );
        }
        break;
      case 'article':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          homeBloc.navigatorKeys[homeBloc.selectedPageIndex].currentState?.push(
            Routes.createRoute(
              const ArticleScreen(),
              settings:
                  RouteSettings(name: Routes.articleScreen, arguments: id),
            ),
          );
        }
        break;
      case 'news':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          homeBloc.navigatorKeys[homeBloc.selectedPageIndex].currentState?.push(
            Routes.createRoute(
              const NewsInternalScreen(),
              settings:
                  RouteSettings(name: Routes.newsInternalScreen, arguments: id),
            ),
          );
        }
        break;
      case 'sale':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          homeBloc.navigatorKeys[homeBloc.selectedPageIndex].currentState?.push(
            Routes.createRoute(
              const SaleScreen(),
              settings: RouteSettings(name: Routes.saleScreen, arguments: id),
            ),
          );
        }
        break;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => CartScreenBloc(
                  getCartUC: sl(),
                  addCartUC: sl(),
                  deleteCartUC: sl(),
                  clearCartUC: sl(),
                  createOrderUC: sl(),
                  sharedPreferences: sl(),
                  courierZoneManager: sl(),
                )..add(InitEvent())),
        BlocProvider(
          create: (context) => SearchScreenBloc(
              searchProductsV2UC: sl(), sharedPreferences: sl())
            ..add(LoadDataEvent()),
        ),
        BlocProvider(
          create: (context) => RouteObserverBloc(),
        ),
      ],
      child: BlocBuilder<RouteObserverBloc, RouteObserverState>(
        builder: (context, state) {
          final RouteObserverBloc observerBloc =
              context.read<RouteObserverBloc>();
          return BlocBuilder<HomeScreenBloc, HomeScreenState>(
            builder: (context, state) {
              final HomeScreenBloc bloc = context.read<HomeScreenBloc>();
              final int selectedIndex = bloc.selectedPageIndex;

              return BlocBuilder<SearchScreenBloc, SearchScreenState>(
                builder: (searchContext, searchState) {
                  //final SearchScreenBloc searchBloc =
                  //    context.read<SearchScreenBloc>();

                  return PopScope(
                    canPop: false, // Разрешает вызывать onPopInvoked
                    onPopInvokedWithResult: (didPop, _) {
                      if (didPop)
                        return; // если уже обработано системой, ничего не делаем

                      final navigatorState =
                          bloc.navigatorKeys[selectedIndex].currentState;

                      navigatorState?.maybePop().then((popped) {
                        final isFirstRouteInCurrentTab = !popped;

                        if (isFirstRouteInCurrentTab) {
                          if (selectedIndex != 0) {
                            bloc.add(ChangePageEvent(0));
                          } else {
                            // Закрыть приложение
                            SystemNavigator.pop();
                          }
                        }
                      });
                    },
                    child: Scaffold(
                      appBar: AppBar(
                          toolbarHeight: 0,
                          backgroundColor: UiConstants.whiteColor,
                          surfaceTintColor: Colors.transparent),
                      body: SafeArea(
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  child: PageStorage(
                                    bucket: bucket,
                                    child: IndexedStack(
                                      index: selectedIndex,
                                      children: bloc.screens.map((screen) {
                                        final int screenIndex =
                                            bloc.screens.indexOf(screen);
                                        return Navigator(
                                          key: bloc.navigatorKeys[screenIndex],
                                          observers: [
                                            AppRouteObserver(observerBloc)
                                          ],
                                          onGenerateRoute: (settings) {
                                            return MaterialPageRoute(
                                                builder: (context) => screen);
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (searchState.isExpanded)
                              Positioned(
                                top: 60.h,
                                child: SearchScreen(
                                  homeContext: context,
                                  onRedirect: () async => FocusScope.of(bloc
                                          .navigatorKeys[bloc.selectedPageIndex]
                                          .currentContext!)
                                      .requestFocus(
                                    FocusNode(),
                                  ),
                                ),
                              ),
                            if (!searchState.isExpanded)
                              Positioned(
                                child: Container(
                                  height: 65.h,
                                  margin: getMarginOrPadding(
                                      left: 20, right: 20, bottom: 8),
                                  padding: getMarginOrPadding(all: 8),
                                  decoration: BoxDecoration(
                                    color: UiConstants.whiteColor,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: BlocBuilder<CartScreenBloc,
                                      CartScreenState>(
                                    builder: (context, state) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          bloc.screens.length,
                                          (index) => BottomNavigationBarTile(
                                              icon: bloc.iconsPaths[index],
                                              title: bloc.iconsNames[index],
                                              countChatMessage: index == 2
                                                  ? (context
                                                              .read<
                                                                  CartScreenBloc>()
                                                              .state
                                                              .cartData
                                                              ?.products ??
                                                          [])
                                                      .length
                                                  : null,
                                              onTap: () => bloc
                                                  .add(ChangePageEvent(index)),
                                              isActive: selectedIndex == index),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
