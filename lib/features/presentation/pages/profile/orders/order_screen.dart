import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/geocoder_manager.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/domain/entities/order_entity.dart';
import 'package:inlek/features/presentation/bloc/cart_screen/cart_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/home_screen/home_screen_bloc.dart';
import 'package:inlek/features/presentation/bloc/order_screen/order_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_button_widget.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/info_border_plate.dart';
import 'package:inlek/features/presentation/widgets/cart_screen/products_list_widget.dart';
import 'package:inlek/features/presentation/widgets/custom_app_bar.dart';
import 'package:inlek/features/presentation/widgets/main_screen/block_widget.dart';
import 'package:inlek/features/presentation/widgets/main_screen/internet_no_internet_connection_widget.dart';
import 'package:inlek/features/presentation/widgets/order_screen/order_progress_indicator.dart';
import 'package:inlek/features/presentation/widgets/order_screen/order_status_widget.dart';
import 'package:inlek/features/presentation/widgets/orders_screen/order_info_list.dart';
import 'package:inlek/locator_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int? orderId = ModalRoute.of(context)?.settings.arguments! as int?;

    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, homeState) {
        final homeBloc = context.read<HomeScreenBloc>();
        return BlocProvider(
          create: (context) =>
              OrderScreenBloc(getOneOrderUC: sl(), repeatOrderUC: sl())
                ..add(LoadOrderEvent(orderId)),
          child: BlocBuilder<OrderScreenBloc, OrderScreenState>(
            builder: (context, orderState) {
              //OrderScreenBloc orderBloc = context.read<OrderScreenBloc>();
              return Scaffold(
                backgroundColor: UiConstants.backgroundColor,
                body: SafeArea(
                  child: Skeletonizer(
                    ignorePointers: false,
                    enabled: orderState.isLoading,
                    child: Builder(
                      builder: (context) {
                        return Column(
                          children: [
                            CustomAppBar(
                              title: 'Заказ #$orderId',
                              showBack: true,
                              backgroundColor: UiConstants.backgroundColor,
                            ),
                            Expanded(
                              child: homeState is InternetUnavailable
                                  ? InternetNoInternetConnectionWidget()
                                  : orderState.error != null
                                      ? Center(
                                          child: Text(
                                            orderState.error ?? '',
                                            style: UiConstants.textStyle3
                                                .copyWith(
                                                    color: UiConstants
                                                        .darkBlueColor,
                                                    fontWeight:
                                                        FontWeight.w800),
                                          ),
                                        )
                                      : ListView(
                                          shrinkWrap: true,
                                          padding: getMarginOrPadding(
                                              bottom: 94,
                                              right: 20,
                                              left: 20,
                                              top: 16),
                                          children: [
                                            if (!orderState.isLoading)
                                              OrderStatusWidget(
                                                  orderStatus:
                                                      orderState.order!.status!,
                                                  date: orderState
                                                      .order!.createdAt!),
                                            if (!orderState.isLoading)
                                              Padding(
                                                padding:
                                                    getMarginOrPadding(top: 16),
                                                child: OrderProgressIndicator(
                                                    orderStatus: orderState
                                                        .order!.status!,
                                                    paymentType: orderState
                                                        .order!.paymentType!,
                                                    typeReceipt: orderState
                                                        .order!.typeReceipt!),
                                              ),
                                            if (orderState.order?.status ==
                                                OrderStatus.awaitingPayment)
                                              Padding(
                                                padding:
                                                    getMarginOrPadding(top: 16),
                                                child: AppButtonWidget(
                                                  text: 'Оплатить',
                                                  onTap: () async {
                                                    final url =
                                                        orderState.order?.link;
                                                    if (url == null ||
                                                        url.isEmpty) {
                                                      return;
                                                    }

                                                    final uri = Uri.parse(url);

                                                    if (await canLaunchUrl(
                                                        uri)) {
                                                      // Открываем ссылку во внешнем приложении (не во WebView)
                                                      await launchUrl(
                                                        uri,
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    } else {
                                                      // Можно вывести сообщение пользователю
                                                      debugPrint(
                                                          'Cannot open URL: $url');
                                                      if (!await canLaunchUrl(
                                                          uri)) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Не удалось открыть ссылку'),
                                                            duration: Duration(
                                                                seconds: 3),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                    /*await Navigator.of(
                                                            navigatorKey
                                                                .currentContext!)
                                                        .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PaymentWebViewScreen(
                                                          url: orderState.order
                                                                  ?.link ??
                                                              '',
                                                          onPaymentCompleted:
                                                              () {},
                                                        ),
                                                      ),
                                                    );
                                                    // Обновляем заказы
                                                    final orderBloc =
                                                        context.read<
                                                            OrderScreenBloc>();
                                                    orderBloc.add(
                                                        LoadOrderEvent(
                                                            orderId));

                                                    // Обновляем список заказов
                                                    final ordersBloc =
                                                        context.read<
                                                            OrdersScreenBloc>();
                                                    ordersBloc
                                                        .add(LoadDataEvent());*/
                                                  },
                                                ),
                                              ),
                                            if ((orderState.order?.products ??
                                                    [])
                                                .any((e) =>
                                                    e.recipe
                                                        ?.replaceAll(' ', '') ==
                                                    'Рецептурный'))
                                              Padding(
                                                padding:
                                                    getMarginOrPadding(top: 16),
                                                child: InfoBorderPlate(
                                                    imagePath:
                                                        Paths.infoIconPath,
                                                    title:
                                                        'В вашем заказе есть рецептурные препараты. Пожалуйста, не забудьте взять с собой рецепт.'),
                                              ),
                                            SizedBox(height: 32),
                                            ProductsListWidget(
                                                title: 'Товары',
                                                products: orderState
                                                        .order?.products ??
                                                    [],
                                                productsListScreenType:
                                                    ProductsListScreenType
                                                        .order),
                                            SizedBox(height: 32),
                                            BlockWidget(
                                              title: 'Информация о заказе',
                                              spacing: 8,
                                              child: OrderInfoList(
                                                order: orderState.order,
                                                address: orderState.order
                                                        ?.fullDeliveryAddress ??
                                                    [
                                                      orderState
                                                          .order?.deliveryCity,
                                                      orderState
                                                          .order?.deliveryStreet
                                                    ].join(', '),
                                              ),
                                            ),
                                            SizedBox(height: 32),
                                            if (orderState.order?.status ==
                                                OrderStatus.canceled)
                                              Padding(
                                                padding: getMarginOrPadding(
                                                    bottom: 8),
                                                child: AppButtonWidget(
                                                  isLoading: orderState
                                                      .isRepeatingOrder,
                                                  text: 'Повторить заказ',
                                                  onTap: () => _onRepeatOrder(
                                                    context,
                                                    homeBloc,
                                                    orderState,
                                                    orderId!,
                                                  ),
                                                ),
                                              ),
                                            Skeleton.replace(
                                              child: AppButtonWidget(
                                                  text: 'Связаться с нами',
                                                  showBorder: true,
                                                  textColor:
                                                      UiConstants.purpleColor,
                                                  backgroundColor: UiConstants
                                                      .backgroundColor,
                                                  onTap: Utils.openJivoChat),
                                            ),
                                          ],
                                        ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _onRepeatOrder(
    BuildContext context,
    HomeScreenBloc homeBloc,
    OrderScreenState orderState,
    int orderId,
  ) async {
    final orderBloc = context.read<OrderScreenBloc>();
    final cartBloc = context.read<CartScreenBloc>();

    orderBloc.add(
      RepeatOrderEvent(
        orderId,
        (isSuccess) async {
          if (!isSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Не удалось повторить заказ')),
              );
            cartBloc.add(LoadCartDataEvent());
            return;
          }

          // Устанавливаем флаг повтора заказа перед переходом на экран корзины
          cartBloc.add(SetRepeatingOrderEvent(true));

          // переводим на экран корзины
          homeBloc.add(ChangePageEvent(2, forcePopToRoot: true));

          final orderType = orderState.order?.typeReceipt;
          if (orderType != null && orderType != cartBloc.state.cartType) {
            cartBloc.add(ChangeCartTypeEvent(orderType));
          }

          if (orderType == TypeReceiving.pickup) {
            cartBloc.add(
              SelectPharmacy(orderState.order?.pharmacyId ?? 0),
            );
          } else {
            sl<SharedPreferences>().setString(
                SharedPreferencesKeys.savedApartment,
                orderState.order?.deliveryApartment ?? '');
            sl<SharedPreferences>().setString(
                SharedPreferencesKeys.savedEntrance,
                orderState.order?.deliveryEntrance ?? '');
            sl<SharedPreferences>().setString(SharedPreferencesKeys.savedFloor,
                orderState.order?.deliveryFloor ?? '');
            sl<SharedPreferences>().setString(
                SharedPreferencesKeys.savedIntercom,
                orderState.order?.deliveryIntercom ?? '');
            sl<SharedPreferences>().setString(
                SharedPreferencesKeys.savedComment,
                orderState.order?.comment ?? '');

            await _setSelectedAddress(cartBloc, orderState.order);
          }

          cartBloc.add(LoadCartDataEvent(isFirstLoading: true));
        },
      ),
    );
  }

  Future<void> _setSelectedAddress(
    CartScreenBloc cartBloc,
    OrderEntity? order,
  ) async {
    if (order?.deliveryCity == null || order?.deliveryStreet == null) {
      return;
    }

    final geocodeResponse = await sl<GeocoderManager>().getGeocodeFromAddress(
        [order?.deliveryCity, order?.deliveryStreet].join(', '));

    cartBloc.selectedAddress = geocodeResponse
        ?.response?.geoObjectCollection?.featureMember?.firstOrNull?.geoObject;
  }
}
