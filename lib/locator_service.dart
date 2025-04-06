import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:inlek/core/geocoder_manager.dart';
import 'package:inlek/core/platform/error_handler.dart';
import 'package:inlek/core/platform/network_info.dart';
import 'package:inlek/features/data/datasources/auth_remote_data_source_impl.dart';
import 'package:inlek/features/data/datasources/cart_remote_data_source_impl.dart';
import 'package:inlek/features/data/datasources/category_remote_data_source_impl.dart';
import 'package:inlek/features/data/datasources/content_remote_data_source_impl.dart';
import 'package:inlek/features/data/datasources/order_remote_data_source_impl.dart';
import 'package:inlek/features/data/datasources/product_remote_data_source_impl.dart';
import 'package:inlek/features/data/datasources/profile_remote_data_source_impl.dart';
import 'package:inlek/features/data/repositories/auth_repository_impl.dart';
import 'package:inlek/features/data/repositories/cart_repository_impl.dart';
import 'package:inlek/features/data/repositories/category_repository_impl.dart';
import 'package:inlek/features/data/repositories/content_repository_impl.dart';
import 'package:inlek/features/data/repositories/order_repository_impl.dart';
import 'package:inlek/features/data/repositories/product_repository_impl.dart';
import 'package:inlek/features/data/repositories/profile_repository_impl.dart';
import 'package:inlek/features/domain/repositories/auth_repository.dart';
import 'package:inlek/features/domain/repositories/cart_repository.dart';
import 'package:inlek/features/domain/repositories/category_repository.dart';
import 'package:inlek/features/domain/repositories/content_repository.dart';
import 'package:inlek/features/domain/repositories/order_repository.dart';
import 'package:inlek/features/domain/repositories/product_repository.dart';
import 'package:inlek/features/domain/repositories/profile_repository.dart';
import 'package:inlek/features/domain/usecases/auth/is_phone_exists.dart';
import 'package:inlek/features/domain/usecases/auth/login.dart';
import 'package:inlek/features/domain/usecases/auth/logout.dart';
import 'package:inlek/features/domain/usecases/auth/registration.dart';
import 'package:inlek/features/domain/usecases/auth/request_code.dart';
import 'package:inlek/features/domain/usecases/auth/update_password.dart';
import 'package:inlek/features/domain/usecases/cart/add_cart.dart';
import 'package:inlek/features/domain/usecases/cart/clear_cart.dart';
import 'package:inlek/features/domain/usecases/cart/delete_cart.dart';
import 'package:inlek/features/domain/usecases/cart/get_cart.dart';
import 'package:inlek/features/domain/usecases/category/get_brands.dart';
import 'package:inlek/features/domain/usecases/category/get_categories.dart';
import 'package:inlek/features/domain/usecases/category/get_countries.dart';
import 'package:inlek/features/domain/usecases/category/get_forms.dart';
import 'package:inlek/features/domain/usecases/category/get_subcategories.dart';
import 'package:inlek/features/domain/usecases/content/get_actions.dart';
import 'package:inlek/features/domain/usecases/content/get_articles.dart';
import 'package:inlek/features/domain/usecases/content/get_banners.dart';
import 'package:inlek/features/domain/usecases/content/get_cities.dart';
import 'package:inlek/features/domain/usecases/content/get_news.dart';
import 'package:inlek/features/domain/usecases/content/get_one_action.dart';
import 'package:inlek/features/domain/usecases/content/get_one_article.dart';
import 'package:inlek/features/domain/usecases/content/get_one_news.dart';
import 'package:inlek/features/domain/usecases/content/get_pharmacies.dart';
import 'package:inlek/features/domain/usecases/orders/create_order.dart';
import 'package:inlek/features/domain/usecases/orders/get_one_order.dart';
import 'package:inlek/features/domain/usecases/orders/get_order_history.dart';
import 'package:inlek/features/domain/usecases/products/get_daily_products.dart';
import 'package:inlek/features/domain/usecases/products/get_one_product.dart';
import 'package:inlek/features/domain/usecases/products/get_product_pharmacies.dart';
import 'package:inlek/features/domain/usecases/products/search_products.dart';
import 'package:inlek/features/domain/usecases/products/search_products_v2.dart';
import 'package:inlek/features/domain/usecases/profile/delete_me.dart';
import 'package:inlek/features/domain/usecases/profile/get_me.dart';
import 'package:inlek/features/domain/usecases/profile/update_me.dart';
import 'package:inlek/features/presentation/bloc/article_screen/article_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/articles_screen/articles_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/catalog_screen/catalog_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/category_screen/category_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/code_screen/code_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/info_about_order_screen/info_about_order_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/login_screen/login_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/main_screen/main_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/news_internal_screen/news_internal_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/news_screen/news_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/order_screen/order_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/orders_screen/orders_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/passwrod_screen/password_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/personal_data_screen/personal_data_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/product_screen/product_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/products_screen/products_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/profile_screen/profile_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/sales_screen/sales_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/search_screen/search_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/select_region_screen/select_region_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/sign_up_screen/sign_up_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/splash_screen/splash_screen_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //// BLoC / Cubit
  sl.registerFactory(
    () => SplashScreenBloc(
      sharedPreferences: sl<SharedPreferences>(),
      getMeUC: sl<GetMeUC>(),
    ),
  );
  sl.registerFactory(
    () => LoginScreenBloc(
      loginUC: sl<LoginUC>(),
    ),
  );
  sl.registerFactory(
    () => SignUpScreenBloc(
      isPhoneExistsUC: sl<IsPhoneExistsUC>(),
    ),
  );
  sl.registerFactory(
    () => CodeScreenBloc(
      requestCodeUC: sl<RequestCodeUC>(),
    ),
  );
  sl.registerFactory(
    () => PasswordScreenBloc(
      updatePasswordUC: sl<UpdatePasswordUC>(),
      registrationUC: sl<RegistrationUC>(),
      loginUC: sl<LoginUC>(),
    ),
  );
  sl.registerFactory(
    () => ProfileScreenBloc(
      logoutUC: sl<LogoutUC>(),
    ),
  );
  sl.registerFactory(
    () => PersonalDataScreenBloc(
        getMeUC: sl<GetMeUC>(),
        updateMeUC: sl<UpdateMeUC>(),
        deleteMeUC: sl<DeleteMeUC>()),
  );
  sl.registerFactory(
    () => NewsScreenBloc(
      getNewsUC: sl<GetNewsUC>(),
    ),
  );
  sl.registerFactory(
    () => NewsInternalScreenBloc(
      getOneNewsUC: sl<GetOneNewsUC>(),
    ),
  );
  sl.registerFactory(
    () => ArticlesScreenBloc(
      getArticlesUC: sl<GetArticlesUC>(),
    ),
  );
  sl.registerFactory(
    () => ArticleScreenBloc(
      getOneArticleUC: sl<GetOneArticleUC>(),
    ),
  );
  sl.registerFactory(
    () => CatalogScreenBloc(
      getCategoriesUC: sl<GetCategoriesUC>(),
    ),
  );
  sl.registerFactory(
    () => CategoryScreenBloc(
      getSubcategoriesUC: sl<GetSubcategoriesUC>(),
      getBrandsUC: sl<GetBrandsUC>(),
      getCountriesUC: sl<GetCountriesUC>(),
      getFormsUC: sl<GetFormsUC>(),
    ),
  );
  sl.registerFactory(
    () => MainScreenBloc(
      getBannersUC: sl<GetBannersUC>(),
      getCategoriesUC: sl<GetCategoriesUC>(),
      getDailyProductsUC: sl<GetDailyProductsUC>(),
      getActionsUC: sl<GetActionsUC>(),
    ),
  );
  sl.registerFactory(
    () => ProductsScreenBloc(
      searchProductsUC: sl<SearchProductsUC>(),
      getBrandsUC: sl<GetBrandsUC>(),
      getCountriesUC: sl<GetCountriesUC>(),
      getFormsUC: sl<GetFormsUC>(),
    ),
  );
  sl.registerFactory(
    () => ProductScreenBloc(
      getOneProductUC: sl<GetOneProductUC>(),
      getProductPharmaciesUC: sl<GetProductPharmaciesUC>(),
    ),
  );
  sl.registerFactory(
    () => OrdersScreenBloc(
      getOrderHistoryUC: sl<GetOrderHistoryUC>(),
    ),
  );
  sl.registerFactory(
    () => OrderScreenBloc(
      getOneOrderUC: sl<GetOneOrderUC>(),
    ),
  );
  sl.registerFactory(
    () => InfoAboutOrderScreenBloc(
      getPharmaciesUC: sl<GetPharmaciesUC>(),
    ),
  );
  sl.registerFactory(
    () => SalesScreenBloc(
      getActionsUC: sl<GetActionsUC>(),
    ),
  );
  sl.registerFactory(
    () => CartScreenBloc(
      getCartUC: sl<GetCartUC>(),
      addCartUC: sl<AddCartUC>(),
      deleteCartUC: sl<DeleteCartUC>(),
      clearCartUC: sl<ClearCartUC>(),
      createOrderUC: sl<CreateOrderUC>(),
      getPharmaciesUC: sl<GetPharmaciesUC>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );
  sl.registerFactory(
    () => SelectRegionScreenBloc(
      getCitiesUC: sl<GetCitiesUC>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );
  sl.registerFactory(
    () => SearchScreenBloc(
      searchProductsV2UC: sl<SearchProductsV2UC>(),
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  //// UseCases
  // Auth
  sl.registerLazySingleton(() => LoginUC(sl()));
  sl.registerLazySingleton(() => LogoutUC(sl()));
  sl.registerLazySingleton(() => RegistrationUC(sl()));
  sl.registerLazySingleton(() => RequestCodeUC(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUC(sl()));
  sl.registerLazySingleton(() => IsPhoneExistsUC(sl()));

  // Profile
  sl.registerLazySingleton(() => GetMeUC(sl()));
  sl.registerLazySingleton(() => UpdateMeUC(sl()));
  sl.registerLazySingleton(() => DeleteMeUC(sl()));

  // Content
  sl.registerLazySingleton(() => GetActionsUC(sl()));
  sl.registerLazySingleton(() => GetArticlesUC(sl()));
  sl.registerLazySingleton(() => GetBannersUC(sl()));
  sl.registerLazySingleton(() => GetNewsUC(sl()));
  sl.registerLazySingleton(() => GetOneActionUC(sl()));
  sl.registerLazySingleton(() => GetOneArticleUC(sl()));
  sl.registerLazySingleton(() => GetOneNewsUC(sl()));
  sl.registerLazySingleton(() => GetPharmaciesUC(sl()));
  sl.registerLazySingleton(() => GetCitiesUC(sl()));

  // Product
  sl.registerLazySingleton(() => GetDailyProductsUC(sl()));
  sl.registerLazySingleton(() => GetOneProductUC(sl()));
  sl.registerLazySingleton(() => SearchProductsUC(sl()));
  sl.registerLazySingleton(() => SearchProductsV2UC(sl()));
  sl.registerLazySingleton(() => GetProductPharmaciesUC(sl()));

  // Category
  sl.registerLazySingleton(() => GetCategoriesUC(sl()));
  sl.registerLazySingleton(() => GetSubcategoriesUC(sl()));
  sl.registerLazySingleton(() => GetCountriesUC(sl()));
  sl.registerLazySingleton(() => GetBrandsUC(sl()));
  sl.registerLazySingleton(() => GetFormsUC(sl()));

  // Order
  sl.registerLazySingleton(() => GetOrderHistoryUC(sl()));
  sl.registerLazySingleton(() => GetOneOrderUC(sl()));
  sl.registerLazySingleton(() => CreateOrderUC(sl()));

  // Cart
  sl.registerLazySingleton(() => GetCartUC(sl()));
  sl.registerLazySingleton(() => AddCartUC(sl()));
  sl.registerLazySingleton(() => DeleteCartUC(sl()));
  sl.registerLazySingleton(() => ClearCartUC(sl()));

  //// Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      networkInfo: sl(),
      errorHandler: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      profileRemoteDataSource: sl(),
      networkInfo: sl(),
      errorHandler: sl(),
    ),
  );
  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(
      contentRemoteDataSource: sl(),
      networkInfo: sl(),
      errorHandler: sl(),
    ),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      productRemoteDataSource: sl(),
      networkInfo: sl(),
      errorHandler: sl(),
    ),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      categoryRemoteDataSource: sl(),
      networkInfo: sl(),
      errorHandler: sl(),
    ),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      orderRemoteDataSource: sl(),
      networkInfo: sl(),
      errorHandler: sl(),
    ),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      cartRemoteDataSource: sl(),
      networkInfo: sl(),
      errorHandler: sl(),
    ),
  );

  //// DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(
      client: sl(),
      sharedPreferences: sl(),
    ),
  );

  //// Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
  sl.registerLazySingleton<ErrorHandler>(
    () => ErrorHandlerImpl(sl()),
  );

  //// External
  await dotenv.load(fileName: ".env");
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton(
      () => YandexGeocoder(apiKey: dotenv.env['YANDEX_GEOCODER_API_KEY']!));
  sl.registerLazySingleton(() => GeocoderManager(sl<YandexGeocoder>()));
}
