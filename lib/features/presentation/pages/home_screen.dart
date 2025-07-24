import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/app_route_observer.dart';
import 'package:inlek/constants/extensions.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageStorageBucket bucket = PageStorageBucket();
  StreamSubscription? _sub;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    UiConstants.homeContext = context;

    _handleInitialUri();
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('Received URI from stream: $uri');
        _handleDeeplink(uri);
      }
    });
  }

  Future<void> _handleInitialUri() async {
    // Ждем инициализации UI перед обработкой диплинка
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _tryGetInitialUri();
    });
  }

  Future<void> _tryGetInitialUri() async {
    try {
      print('Trying to get initial app link...');
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        print('Got initial URI: $initialUri');
        _handleDeeplink(initialUri);
        return;
      }

      // Если не получили initial URI, пробуем еще раз через небольшую задержку
      // Это особенно важно для iOS
      await Future.delayed(Duration(milliseconds: 500));
      final retryUri = await _appLinks.getInitialAppLink();
      if (retryUri != null) {
        print('Got initial URI on retry: $retryUri');
        _handleDeeplink(retryUri);
        return;
      }

      print('No initial URI found');
    } catch (e) {
      print('Error handling initial URI: $e');
    }
  }

  Future<void> _handleDeeplink(Uri uri) async {
    if (!mounted) return;

    print('Handling deeplink: $uri');

    // Ждем полной инициализации UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Добавляем небольшую задержку для iOS, чтобы убедиться, что все готово
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            _processDeeplink(uri);
          }
        });
      }
    });
  }

  void _processDeeplink(Uri uri) {
    if (!mounted) return;

    print('Processing deeplink: $uri');

    final pathSegments = uri.pathSegments;
    if (pathSegments.length < 2) {
      print('Invalid deeplink format: insufficient path segments');
      return;
    }

    final type = pathSegments[0];
    final id = pathSegments[1];

    print('Deeplink type: $type, id: $id');

    // Получаем bloc через context для корректной работы
    final homeBloc = context.read<HomeScreenBloc>();
    final navigator =
        homeBloc.navigatorKeys[homeBloc.selectedPageIndex].currentState;

    // Проверяем, что navigator готов
    if (navigator == null) {
      print('Navigator not ready, retrying...');
      // Если navigator еще не готов, пробуем еще раз через небольшую задержку
      // Увеличиваем задержку для iOS
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          _processDeeplink(uri);
        }
      });
      return;
    }

    final routeMap = <String, Widget Function()>{
      'product': () => const ProductScreen(),
      'banner': () => const BannerScreen(),
      'article': () => const ArticleScreen(),
      'news': () => const NewsInternalScreen(),
      'sale': () => const SaleScreen(),
    };

    final screenBuilder = routeMap[type];
    if (screenBuilder != null) {
      final routeName = _getRouteName(type);
      final args = {'id': int.tryParse(id)};

      if (args['id'] != null) {
        print('Navigating to $routeName with args: $args');

        // Добавляем дополнительную проверку для iOS
        try {
          navigator.push(
            Routes.createRoute(
              screenBuilder(),
              settings: RouteSettings(
                name: routeName,
                arguments: args,
              ),
            ),
          );
          print('Navigation successful');
        } catch (e) {
          print('Navigation failed: $e');
          // Если навигация не удалась, пробуем еще раз через задержку
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              _processDeeplink(uri);
            }
          });
        }
      } else {
        print('Invalid ID in deeplink: $id');
      }
    } else {
      print('Unknown deeplink type: $type');
    }
  }

  String? _getRouteName(String type) {
    switch (type) {
      case 'product':
        return Routes.productScreen;
      case 'banner':
        return Routes.bannerScreen;
      case 'article':
        return Routes.articleScreen;
      case 'news':
        return Routes.newsInternalScreen;
      case 'sale':
        return Routes.saleScreen;
      default:
        return null;
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
          create: (context) => HomeScreenBloc(),
        ),
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

                  return WillPopScope(
                    onWillPop: () async {
                      if (selectedIndex == 0) {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      } else {
                        final isFirstRouteInCurrentTab = !await bloc
                            .navigatorKeys[selectedIndex].currentState!
                            .maybePop();
                        if (isFirstRouteInCurrentTab) {
                          bloc.add(ChangePageEvent(0));
                          return false;
                        }
                      }
                      return false;
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
                                top: 60.dp,
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
                                  height: 65.dp,
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
