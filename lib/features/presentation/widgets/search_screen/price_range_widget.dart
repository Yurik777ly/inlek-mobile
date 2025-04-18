import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/features/presentation/bloc/products_screen/products_screen_bloc.dart';
import 'package:inlek/features/presentation/widgets/app_text_field_widget.dart';

class PriceRangeWidget extends StatefulWidget {
  const PriceRangeWidget({super.key, required this.screenContext});

  final BuildContext screenContext;

  @override
  State<PriceRangeWidget> createState() => _PriceRangeWidgetState();
}

class _PriceRangeWidgetState extends State<PriceRangeWidget> {
  List<BoxShadow> boxShadow = [
    BoxShadow(
        offset: Offset(-1, 4),
        color: Color(0xFF00A0E3).withOpacity(.1),
        blurRadius: 10.r,
        spreadRadius: -4.r),
  ];

  @override
  Widget build(BuildContext context) {
    ProductsScreenBloc productsBloc =
        widget.screenContext.read<ProductsScreenBloc>();
    return BlocBuilder<ProductsScreenBloc, ProductsScreenState>(
      bloc: productsBloc,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Цена',
              style: UiConstants.textStyle3.copyWith(
                  color: UiConstants.darkBlueColor,
                  fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppTextFieldWidget(
                      fillColor: UiConstants.whiteColor,
                      controller: productsBloc.minValueController,
                      onChangedField: (value) {
                        productsBloc.add(
                          ChangePriceEvent(double.tryParse(value), true),
                        );
                      },
                      boxShadow: boxShadow),
                ),
                Container(
                  margin: getMarginOrPadding(right: 8, left: 8),
                  height: 1.h,
                  width: 12.w,
                  color: Color(0xFF222222).withOpacity(.6),
                ),
                Expanded(
                  child: AppTextFieldWidget(
                      fillColor: UiConstants.whiteColor,
                      controller: productsBloc.maxValueController,
                      onChangedField: (value) {
                        productsBloc.add(
                          ChangePriceEvent(double.tryParse(value), false),
                        );
                      },
                      boxShadow: boxShadow),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.h,
                overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                rangeThumbShape: RoundRangeSliderThumbShape(
                    enabledThumbRadius: 6.r, disabledThumbRadius: 6.r),
              ),
              child: RangeSlider(
                values:
                    RangeValues(state.minSelectedPrice, state.maxSelectedPrice),
                min: state.minAllowedPrice,
                max: state.maxAllowedPrice,
                activeColor: UiConstants.purpleColor,
                inactiveColor: UiConstants.white5Color,
                onChanged: (RangeValues values) {
                  productsBloc.add(
                    ChangePriceEvent(values.start.roundToDouble(), true),
                  );
                  productsBloc.add(
                    ChangePriceEvent(values.end.roundToDouble(), false),
                  );
                },
                labels: RangeLabels(
                  state.minSelectedPrice.round().toString(),
                  state.maxSelectedPrice.round().toString(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
