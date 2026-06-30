import 'package:equatable/equatable.dart';
import 'package:inlek/constants/enums.dart';
import 'package:inlek/features/domain/entities/base_product_entity.dart';
import 'package:inlek/features/domain/entities/category_entity.dart';
import 'package:inlek/features/domain/entities/product_prices_entity.dart';
import 'package:inlek/features/domain/entities/product_totals_entity.dart';

class ProductEntity extends BaseProductEntity {
  final String? mnn;
  final String? mnnLat;
  final String? description;
  final String? code;
  final String? dose;
  final String? form;
  final String? brand;
  final String? recipe;
  final bool isRecipe;
  final bool isAlcohol;
  final String? country;
  final TypeReceiving? delivery;
  final double? price;
  final double? oldPrice;
  final int? discount;
  final int? parent;
  final String? termin;
  final String? temperature;
  final String? releaseForm;
  final String? productInsert;
  final String? productSticker;
  final String? productRegister;
  final dynamic productTrademark;
  final String? productDateRegister;
  final String? productTimeRegister;
  final int? count;
  final int? requiredQuantity;
  final String? availability;
  final String? pagetitle;
  final List<ProductEntity>? brandProducts;
  final List<ProductEntity>? relatedProducts;
  final List<ProductEntity>? similarProducts;
  final List<ProductEntity>? analogProducts;
  final int? stockCount;
  final int? quantity;
  final List<PromocodeEntity>? promocodesJson;
  final PropertiesEntity? properties;
  final bool isLoading;
  final ProductPricesEntity? prices;
  final ProductTotalsEntity? totals;
  final String? instruction;
  final int? otherPharmacy;
  final List<CategoryEntity>? categoriesJson;
  final int? availableSomewhere;
  final int? requestedQuantity;

  const ProductEntity({
    super.productId = 0,
    super.name = '',
    super.image = '',
    this.mnn,
    this.mnnLat,
    this.description,
    this.code,
    this.dose,
    this.form,
    this.brand,
    this.recipe,
    this.isRecipe = false,
    this.isAlcohol = false,
    this.country,
    this.delivery,
    this.price,
    this.oldPrice,
    this.discount,
    this.parent,
    this.termin,
    this.temperature,
    this.releaseForm,
    this.productInsert,
    this.productSticker,
    this.productRegister,
    this.productTrademark,
    this.productDateRegister,
    this.productTimeRegister,
    this.count,
    this.requiredQuantity,
    this.availability,
    this.pagetitle,
    this.brandProducts,
    this.relatedProducts,
    this.similarProducts,
    this.analogProducts,
    this.stockCount,
    this.quantity,
    this.promocodesJson,
    this.properties,
    this.isLoading = false,
    this.prices,
    this.totals,
    this.instruction,
    this.otherPharmacy,
    this.categoriesJson,
    this.availableSomewhere,
    this.requestedQuantity,
  });

  ProductEntity copyWith({
    int? productId,
    String? name,
    String? image,
    String? mnn,
    String? mnnLat,
    String? description,
    String? code,
    String? dose,
    String? form,
    String? brand,
    String? recipe,
    bool? isRecipe,
    bool? isAlcohol,
    String? country,
    TypeReceiving? delivery,
    double? price,
    double? oldPrice,
    int? discount,
    int? parent,
    String? termin,
    String? temperature,
    String? releaseForm,
    String? productInsert,
    String? productSticker,
    String? productRegister,
    String? productTrademark,
    String? productDateRegister,
    String? productTimeRegister,
    int? count,
    int? requiredQuantity,
    String? availability,
    String? pagetitle,
    List<ProductEntity>? brandProducts,
    List<ProductEntity>? relatedProducts,
    List<ProductEntity>? similarProducts,
    List<ProductEntity>? analogProducts,
    int? stockCount,
    int? quantity,
    List<PromocodeEntity>? promocodesJson,
    PropertiesEntity? properties,
    bool? isLoading,
    ProductPricesEntity? prices,
    ProductTotalsEntity? totals,
    String? instruction,
    int? otherPharmacy,
    List<CategoryEntity>? categoriesJson,
    int? availableSomewhere,
    int? requestedQuantity,
  }) {
    return ProductEntity(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      mnn: mnn ?? this.mnn,
      mnnLat: mnnLat ?? this.mnnLat,
      description: description ?? this.description,
      code: code ?? this.code,
      dose: dose ?? this.dose,
      form: form ?? this.form,
      brand: brand ?? this.brand,
      recipe: recipe ?? this.recipe,
      isRecipe: isRecipe ?? this.isRecipe,
      isAlcohol: isAlcohol ?? this.isAlcohol,
      country: country ?? this.country,
      delivery: delivery ?? this.delivery,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      discount: discount ?? this.discount,
      parent: parent ?? this.parent,
      termin: termin ?? this.termin,
      temperature: temperature ?? this.temperature,
      releaseForm: releaseForm ?? this.releaseForm,
      productInsert: productInsert ?? this.productInsert,
      productSticker: productSticker ?? this.productSticker,
      productRegister: productRegister ?? this.productRegister,
      productTrademark: productTrademark ?? this.productTrademark,
      productDateRegister: productDateRegister ?? this.productDateRegister,
      productTimeRegister: productTimeRegister ?? this.productTimeRegister,
      count: count ?? this.count,
      requiredQuantity: requiredQuantity ?? this.requiredQuantity,
      availability: availability ?? this.availability,
      pagetitle: pagetitle ?? this.pagetitle,
      brandProducts: brandProducts ?? this.brandProducts,
      relatedProducts: relatedProducts ?? this.relatedProducts,
      similarProducts: similarProducts ?? this.similarProducts,
      analogProducts: analogProducts ?? this.analogProducts,
      stockCount: stockCount ?? this.stockCount,
      quantity: quantity ?? this.quantity,
      promocodesJson: promocodesJson ?? this.promocodesJson,
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      prices: prices ?? this.prices,
      totals: totals ?? this.totals,
      instruction: instruction ?? this.instruction,
      otherPharmacy: otherPharmacy ?? this.otherPharmacy,
      categoriesJson: categoriesJson ?? this.categoriesJson,
      availableSomewhere: availableSomewhere ?? this.availableSomewhere,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
    );
  }

  @override
  List<Object?> get props =>
      super.props +
      [
        mnn,
        mnnLat,
        description,
        code,
        dose,
        form,
        brand,
        recipe,
        isRecipe,
        isAlcohol,
        country,
        delivery,
        price,
        oldPrice,
        discount,
        parent,
        termin,
        temperature,
        releaseForm,
        productInsert,
        productSticker,
        productRegister,
        productTrademark,
        productDateRegister,
        productTimeRegister,
        count,
        requiredQuantity,
        availability,
        pagetitle,
        brandProducts,
        relatedProducts,
        similarProducts,
        analogProducts,
        stockCount,
        quantity,
        promocodesJson,
        properties,
        isLoading,
        prices,
        totals,
        instruction,
        otherPharmacy,
        categoriesJson,
        availableSomewhere,
        requestedQuantity,
      ];
}

class PromocodeEntity extends Equatable {
  final int? productId;
  final DateTime? end;
  final DateTime? begin;
  final int? usages;
  final String promocode;
  final int? minAmount;
  final int promotionId;
  final int promocodePercent;

  const PromocodeEntity({
    this.productId,
    this.end,
    this.begin,
    this.usages,
    required this.promocode,
    this.minAmount,
    required this.promotionId,
    required this.promocodePercent,
  });

  @override
  List<Object?> get props => [
        productId,
        end,
        begin,
        usages,
        promocode,
        minAmount,
        productId,
        promocodePercent
      ];
}

class PropertiesEntity extends Equatable {
  final String? brand;
  final String? country;
  final String? releaseForm;

  const PropertiesEntity({
    this.brand,
    this.country,
    this.releaseForm,
  });

  @override
  List<Object?> get props => [brand, country, releaseForm];
}
