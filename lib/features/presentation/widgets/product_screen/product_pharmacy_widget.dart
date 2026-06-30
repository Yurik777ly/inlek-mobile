import 'package:flutter/material.dart';
import 'package:inlek/constants/size_utils.dart';
import 'package:inlek/constants/ui_constants.dart';
import 'package:inlek/constants/utils.dart';
import 'package:inlek/features/domain/entities/pharmacy_entity.dart';

class ProductPharmacyWidget extends StatelessWidget {
  const ProductPharmacyWidget({super.key, required this.pharmacy});

  final PharmacyEntity pharmacy;

  String _displayPharmacyName(PharmacyEntity pharmacy) {
    final name = pharmacy.pharmacyName.trim();
    if (name.isNotEmpty) {
      return name;
    }

    final pageTitle = pharmacy.pageTitle?.trim();
    if (pageTitle != null && pageTitle.isNotEmpty) {
      return pageTitle;
    }

    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: getMarginOrPadding(top: 16, bottom: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        color: UiConstants.whiteColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayPharmacyName(pharmacy),
            style: UiConstants.textStyle3.copyWith(
                color: UiConstants.darkBlueColor,
                fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16),
          Text(
            pharmacy.address ?? '-',
            style: UiConstants.textStyle2
                .copyWith(color: UiConstants.darkBlueColor),
          ),
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: Text(
              pharmacy.expirationDate ?? '-',
              style: UiConstants.textStyle8.copyWith(
                color: UiConstants.darkBlueColor.withOpacity(.6),
              ),
            ),
          ),
          Padding(
            padding: getMarginOrPadding(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'В наличии ${pharmacy.stockCount} шт.',
                    style: UiConstants.textStyle2.copyWith(
                        color: UiConstants.darkBlueColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '1 шт.',
                      style: UiConstants.textStyle8.copyWith(
                        color: UiConstants.darkBlue2Color.withOpacity(.6),
                      ),
                    ),
                    Text(
                      Utils.formatPrice(pharmacy.price),
                      style: UiConstants.textStyle5
                          .copyWith(color: UiConstants.darkBlueColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
