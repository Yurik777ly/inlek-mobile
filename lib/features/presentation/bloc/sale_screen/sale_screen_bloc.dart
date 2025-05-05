import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:inlek/features/domain/usecases/content/get_one_action.dart';

part 'sale_screen_event.dart';
part 'sale_screen_state.dart';

class SaleScreenBloc extends Bloc<SaleScreenEvent, SaleScreenState> {
  final GetOneActionUC getOneActionUC;
  BuildContext? screenContext;

  ScrollController controller = ScrollController();

  SaleScreenBloc({required this.getOneActionUC, this.screenContext})
      : super(SaleScreenState()) {
    on<LoadActionEvent>(_onLoadAction);
  }

  void _onLoadAction(
      LoadActionEvent event, Emitter<SaleScreenState> emit) async {
    final failureOrLoads = await getOneActionUC(event.id);

    failureOrLoads.fold(
      (_) => Utils.showCustomDialog(
        screenContext: screenContext!,
        text: 'Ошибка загрузки акции',
        action: (context) {
          Navigator.of(context).pop();
          Navigator.of(screenContext!).pop();
        },
      ),
      (action) => emit(
        SaleScreenState(isLoading: false, action: action),
      ),
    );
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}
