import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/constants/extensions.dart';
import 'package:inlek/constants/paths.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/core/formatters/date_input_formatter.dart';
import 'package:inlek/features/presentation/bloc/personal_data_screen/personal_data_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';
import 'package:inlek/features/presentation/widgets/custom_radio_button.dart';

class GeneralInformationBlock extends StatelessWidget {
  const GeneralInformationBlock({super.key, required this.screenContext});

  final BuildContext screenContext;

  @override
  Widget build(BuildContext context) {
    final personalDataBloc = screenContext.read<PersonalDataScreenBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Общая информация',
          style:
              UiConstants.textStyle5.copyWith(color: UiConstants.darkBlueColor),
        ),
        SizedBox(height: 8.dp),
        Container(
          padding: getMarginOrPadding(all: 16),
          decoration: BoxDecoration(
            color: UiConstants.whiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              AppTextFieldWidget(
                title: 'Имя',
                hintText: 'Введите имя',
                controller: personalDataBloc.fNameController,
                validator: (p0) =>
                    Utils.nameValidate(p0, isSensitiveEmptyValue: false),
              ),
              SizedBox(height: 24.dp),
              AppTextFieldWidget(
                title: 'Фамилия',
                hintText: 'Введите фамилию',
                controller: personalDataBloc.sNameController,
                validator: (p0) =>
                    Utils.nameValidate(p0, isSensitiveEmptyValue: false),
              ),
              SizedBox(height: 24.dp),
              AppTextFieldWidget(
                title: 'Дата рождения',
                hintText: 'ДД / ММ / ГГГГ',
                controller: personalDataBloc.birthdayController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  DateInputFormatter()
                ],
                suffixWidget: Padding(
                  padding: getMarginOrPadding(top: 10, bottom: 10),
                  child: SvgPicture.asset(Paths.calendarIconPath),
                ),
                validator: Utils.dateValidate,
                onChangedField: (p0) =>
                    personalDataBloc.birthdayController.text = p0,
              ),
              SizedBox(height: 24.dp),
              Row(
                children: [
                  CustomRadioButton(
                    title: 'Мужской',
                    value: GenderType.male,
                    groupValue: personalDataBloc.state.gender,
                    onChanged: () => personalDataBloc.add(
                      ChangeGenderEvent(GenderType.male),
                    ),
                  ),
                  SizedBox(width: 24.dp),
                  CustomRadioButton(
                    title: 'Женский',
                    value: GenderType.female,
                    groupValue: personalDataBloc.state.gender,
                    onChanged: () => personalDataBloc.add(
                      ChangeGenderEvent(GenderType.female),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
