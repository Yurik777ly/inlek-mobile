import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/core/routes.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/pages/cart/cart_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/catalog_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/category_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/pharmacies_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/products/product_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/products/products_screen.dart';
import 'package:inlek/features/presentation/pages/home_screen.dart';
import 'package:inlek/features/presentation/pages/main/banner_screen.dart';
import 'package:inlek/features/presentation/pages/main/main_screen.dart';
import 'package:inlek/features/presentation/pages/profile/about_us_screen.dart';
import 'package:inlek/features/presentation/pages/profile/articles/article_screen.dart';
import 'package:inlek/features/presentation/pages/profile/articles/articles_screen.dart';
import 'package:inlek/features/presentation/pages/profile/how_place_order_screen.dart';
import 'package:inlek/features/presentation/pages/profile/info_about_order_screen.dart';
import 'package:inlek/features/presentation/pages/profile/news/news_internal_screen.dart';
import 'package:inlek/features/presentation/pages/profile/news/news_screen.dart';
import 'package:inlek/features/presentation/pages/profile/orders/order_screen.dart';
import 'package:inlek/features/presentation/pages/profile/orders/orders_screen.dart';
import 'package:inlek/features/presentation/pages/profile/personal_data_screen.dart';
import 'package:inlek/features/presentation/pages/profile/profile_screen.dart';
import 'package:inlek/features/presentation/pages/profile/sales/sale_screen.dart';
import 'package:inlek/features/presentation/pages/profile/sales/sales_screen.dart';
import 'package:inlek/features/presentation/pages/starts/account_not_found_screen.dart';
import 'package:inlek/features/presentation/pages/starts/code_screen.dart';
import 'package:inlek/features/presentation/pages/starts/login_screen.dart';
import 'package:inlek/features/presentation/pages/starts/password_screen.dart';
import 'package:inlek/features/presentation/pages/starts/select_region_screen.dart';
import 'package:inlek/features/presentation/pages/starts/sign_up_screen.dart';
import 'package:inlek/features/presentation/pages/starts/splash_screen.dart';
import 'package:inlek/firebase_options.dart';
import 'package:inlek/locator_service.dart' as di;
import 'package:intl/date_symbol_data_local.dart';
import 'package:uni_links5/uni_links.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await initializeDateFormatting('ru', null);
  await di.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
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

    switch (pathSegments[0]) {
      case 'product':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          navigatorKey.currentState
              ?.pushNamed(Routes.productScreen, arguments: id);
        }
        break;
      case 'banner':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          navigatorKey.currentState
              ?.pushNamed(Routes.bannerScreen, arguments: id);
        }
        break;
      case 'article':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          navigatorKey.currentState
              ?.pushNamed(Routes.articleScreen, arguments: id);
        }
        break;
      case 'news':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          navigatorKey.currentState
              ?.pushNamed(Routes.newsInternalScreen, arguments: id);
        }
        break;
      case 'sale':
        if (pathSegments.length > 1) {
          final id = pathSegments[1];
          navigatorKey.currentState
              ?.pushNamed(Routes.saleScreen, arguments: id);
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
    Size designSize =
        const Size(360, 728 + kToolbarHeight + kBottomNavigationBarHeight);
    return ScreenUtilInit(
      designSize: designSize,
      fontSizeResolver: (fontSize, instance) {
        final display = View.of(context).display;
        final screenSize = display.size / display.devicePixelRatio;
        final scaleWidth = screenSize.width / designSize.width;

        return fontSize * scaleWidth;
      },
      //inTextAdapt: true,
      //splitScreenMode: true,
      builder: (_, child) {
        return BlocProvider(
          create: (context) => HomeScreenBloc(),
          child: MaterialApp(
              navigatorKey: navigatorKey,
              title: 'InLek',
              theme: ThemeData(
                  scaffoldBackgroundColor: UiConstants.whiteColor,
                  fontFamily: 'Nunito'),
              //home: SplashScreen(),
              routes: {
                Routes.splashScreen: (context) => const SplashScreen(),
                Routes.codeScreen: (context) => const CodeScreen(),
                Routes.loginScreen: (context) => const LoginScreen(),
                Routes.signUpScreen: (context) => const SignUpScreen(),
                Routes.passwordScreen: (context) => const PasswordScreen(),
                Routes.accountNotFoundScreen: (context) =>
                    const AccountNotFoundScreen(),
                Routes.homeScreen: (context) => const HomeScreen(),
                Routes.mainScreen: (context) => const MainScreen(),
                Routes.catalogScreen: (context) => const CatalogScreen(),
                Routes.cartScreen: (context) => const CartScreen(),
                Routes.categoryScreen: (context) => const CategoryScreen(),
                Routes.productsScreen: (context) => const ProductsScreen(),
                Routes.bannerScreen: (context) => const BannerScreen(),
                Routes.productScreen: (context) => const ProductScreen(),
                Routes.pharmaciesScreen: (context) => const PharmaciesScreen(),
                Routes.profileScreen: (context) => const ProfileScreen(),
                Routes.personalDataScreen: (context) =>
                    const PersonalDataScreen(),
                Routes.ordersScreen: (context) => const OrdersScreen(),
                Routes.orderScreen: (context) => const OrderScreen(),
                Routes.articlesScreen: (context) => const ArticlesScreen(),
                Routes.articleScreen: (context) => const ArticleScreen(),
                Routes.newsScreen: (context) => const NewsScreen(),
                Routes.newsInternalScreen: (context) =>
                    const NewsInternalScreen(),
                Routes.salesScreen: (context) => const SalesScreen(),
                Routes.saleScreen: (context) => const SaleScreen(),
                Routes.aboutUsScreen: (context) => const AboutUsScreen(),
                Routes.howPlaceOrderScreen: (context) =>
                    const HowPlaceOrderScreen(),
                Routes.infoAboutOrderScreen: (context) =>
                    const InfoAboutOrderScreen(),
                Routes.selectRegionScreen: (context) =>
                    const SelectRegionScreen(),
              },
              initialRoute: Routes.splashScreen,
              navigatorObservers: [routeObserver],
              debugShowCheckedModeBanner: false),
        );
      },
    );
  }
}

// На случай, если Пятисотый забыл сертификаты обновить

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
