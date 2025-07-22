import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/core/connectivity_service.dart';
import 'package:inlek/features/presentation/pages/cart/cart_screen.dart';
import 'package:inlek/features/presentation/pages/catalog/catalog_screen.dart';
import 'package:inlek/features/presentation/pages/main/main_screen.dart';
import 'package:inlek/features/presentation/pages/profile/profile_screen.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final ConnectivityService connectivityService = ConnectivityService();
  final List<GlobalKey<NavigatorState>> navigatorKeys =
      List.generate(4, (index) => GlobalKey<NavigatorState>());

  Timer? _timer;
  int selectedPageIndex = 0;

  // Упрощённый список экранов без навигационных стеков
  final List<Widget> screens = [
    MainScreen(),
    CatalogScreen(),
    CartScreen(),
    ProfileScreen()
  ];

  List<String> iconsPaths = [
    Paths.homeIconPath,
    Paths.catalogIconPath,
    Paths.cartIconPath,
    Paths.profileIconPath,
  ];
  List<String> iconsNames = ['Главная', 'Каталог', 'Корзина', 'Профиль'];

  HomeScreenBloc() : super(HomeScreenInitial()) {
    on<CheckInternetConnection>((event, emit) async {
      final hasConnection = await connectivityService.hasInternetConnection();
      if (hasConnection) {
        emit(HomeScreenInitial());
      } else {
        emit(InternetUnavailable());
      }
    });

    _startPeriodicCheck();

    on<ChangePageEvent>(_onPageChanged);
    on<UploadContext>(_onUploadContext);
  }

  void _onPageChanged(ChangePageEvent event, Emitter<HomeScreenState> emit) {
    if (event.pageIndex == selectedPageIndex || event.forcePopToRoot) {
      navigatorKeys[event.pageIndex]
          .currentState!
          .popUntil((route) => route.isFirst);
    }
    selectedPageIndex = event.pageIndex;
    emit(HomeScreenPageChanged(selectedPageIndex));
  }

  void _startPeriodicCheck() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      add(CheckInternetConnection());
    });
  }

  void _onUploadContext(UploadContext event, Emitter<HomeScreenState> emit) {
    emit(HomeScreenInitial().copyWith(context: event.context));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
