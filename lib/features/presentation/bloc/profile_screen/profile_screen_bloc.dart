import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inlek/features/domain/usecases/auth/logout.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_screen_event.dart';
part 'profile_screen_state.dart';

class ProfileScreenBloc extends Bloc<ProfileScreenEvent, ProfileScreenState> {
  final LogoutUC logoutUC;
  final SharedPreferences sharedPreferences;

  ProfileScreenBloc({required this.logoutUC, required this.sharedPreferences})
      : super(ProfileScreenState()) {
    on<LogoutEvent>(_onLogout); // выход из профиля
  }

  // выход из профиля
  void _onLogout(LogoutEvent event, Emitter<ProfileScreenState> emit) async {
    logoutUC();
    sharedPreferences.clear();

    emit(NavigateLoginState());
  }
}
