import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/app_route_observer.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/core/uni_links_manager.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/route_observer/route_observer_bloc.dart';
import 'package:inlek/features/presentation/bloc/search_screen/search_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
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

  @override
  void initState() {
    super.initState();
    UiConstants.homeContext = context;

    sl<UniLinksManager>().uriStream.listen((uri) {
      if (uri.host == 'product') {
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        if (id != null) {
          _redirectToProduct(id);
        }
      }
    });
  }

  void _redirectToProduct(String id) {
    // Переход в нужный таб (например, Home)
    final bloc = context.read<HomeScreenBloc>();
    const homeTabIndex = 0;

    bloc.onChangePage(homeTabIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = bloc.navigatorKeys[homeTabIndex].currentState;
      navigator?.push(
        Routes.createRoute(
          ProductScreen(),
          settings: RouteSettings(name: Routes.productsScreen, arguments: id),
        ),
      );
    });
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
                )..add(LoadCartDataEvent(isFirstLoading: true))),
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
                          bloc.onChangePage(0);
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
                                              onTap: () {
                                                bloc
                                                    .navigatorKeys[
                                                        selectedIndex]
                                                    .currentState!
                                                    .popUntil((route) =>
                                                        route.isFirst);
                                                bloc.onChangePage(index);
                                              },
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
