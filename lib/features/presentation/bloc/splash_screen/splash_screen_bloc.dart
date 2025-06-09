import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:inlek/core/shared_preferences_keys.dart';
import 'package:inlek/features/domain/usecases/profile/get_me.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'splash_screen_event.dart';
part 'splash_screen_state.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  final SharedPreferences sharedPreferences;
  final GetMeUC getMeUC;

  SplashScreenBloc({required this.sharedPreferences, required this.getMeUC})
      : super(SplashScreenInitial()) {
    on<SplashScreenStarted>((event, emit) async {
      await Future.delayed(Duration(seconds: 2));
      String? token =
          sharedPreferences.getString(SharedPreferencesKeys.accessToken);
      if (token != null) {
        bool isSuccessFetchData = await _getUserData();
        if (isSuccessFetchData) {
          emit(SplashScreenNavigateHome());
        } else {
          emit(SplashScreenNavigateLogin());
        }
      } else {
        emit(SplashScreenNavigateLogin());
      }
    });
  }

  Future<bool> _getUserData() async {
    sharedPreferences.remove(SharedPreferencesKeys.email);
    sharedPreferences.remove(SharedPreferencesKeys.phone);
    sharedPreferences.remove(SharedPreferencesKeys.fullName);
    sharedPreferences.remove(SharedPreferencesKeys.userId);
    final failureOrLoads = await getMeUC();

    return failureOrLoads.fold((_) => false, (_) => true);
  }
}
