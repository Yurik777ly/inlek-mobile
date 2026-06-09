import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/action_entity.dart';
import 'package:inlek/features/domain/usecases/content/get_actions.dart';

part 'sales_screen_event.dart';
part 'sales_screen_state.dart';

class SalesScreenBloc extends Bloc<SalesScreenEvent, SalesScreenState> {
  final GetActionsUC getActionsUC;
  BuildContext? screenContext;
  SalesScreenBloc({required this.getActionsUC, this.screenContext})
      : super(SalesScreenState()) {
    on<LoadSalesEvent>(_onLoadSales);
  }

  void _onLoadSales(
      LoadSalesEvent event, Emitter<SalesScreenState> emit) async {
    emit(state.copyWith(isLoading: true));
    final failureOrLoads = await getActionsUC();

    failureOrLoads.fold(
      (_) {
        emit(state.copyWith(isLoading: false, actions: []));
        if (screenContext != null) {
          Utils.showCustomDialog(
            screenContext: screenContext!,
            text: 'Ошибка загрузки акций',
            action: (context) {
              Navigator.of(context).pop();
              Navigator.of(screenContext!).pop();
            },
          );
        }
      },
      (actions) => emit(
        state.copyWith(isLoading: false, actions: actions),
      ),
    );
  }
}
