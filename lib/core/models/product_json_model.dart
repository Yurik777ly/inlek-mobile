import 'dart:convert';

class ProductJsonModel {
  final int? id;
  final double? price;
  final double? oldPrice;
  final int? salePercent;
  final bool? isRecipe;
  final String? type;
  final String? contentType;
  final String? pagetitle;
  final String? longtitle;
  final String? description;
  final String? alias;
  final String? linkAttributes;
  final String? published;
  final String? pubDate;
  final String? unpubDate;
  final int? parent;
  final String? isfolder;
  final String? introtext;
  final String? content;
  final String? richtext;
  final String? template;
  final String? menuindex;
  final String? searchable;
  final String? cacheable;
  final String? createdby;
  final String? createdon;
  final String? editedby;
  final String? editedon;
  final String? deleted;
  final String? deletedon;
  final String? deletedby;
  final String? publishedon;
  final String? publishedby;
  final String? menutitle;
  final String? hideFromTree;
  final String? privateweb;
  final String? privatemgr;
  final String? contentDispo;
  final String? hidemenu;
  final String? aliasVisible;
  final String? tvProductImage;
  final String? tvProductProperties;
  final String? tvProductUid1C;
  final String? tvProductCode;
  final String? tvProductMnn;
  final String? tvProductItemType;
  final String? tvProductTrademark;
  final String? tvProductForm;
  final String? tvProductNomenclatureId;
  final String? tvProductPrice;
  final String? tvProductPriceOld;
  final String? tvProductPricePercent;
  final String? tvProductAvailability;
  final String? tvProductGallery;
  final String? tvProductIsRecipe;
  final String? tvProductStickers;
  final String? tvProductRelated;
  final String? tvProductStockCount;
  final String? tvProductStockPrice;
  final String? tvProductStockPriceOld;
  final String? tvProductVariantCode;
  final String? tvProductVariable;
  final String? tvProductSimilar;
  final String? tvProductIsAlcohol;
  final String? date;
  final String? title;
  final String? url;
  final String? ePagetitle;
  final dynamic productCode;
  final String? productGallery;
  final String? productImage;
  final String? productPrice;
  final String? productPriceOld;
  final String? productPricePercent;
  final String? productIsRecipe;
  final String? productIsAlcohol;
  final dynamic productIsDietarySupplement;
  final String? productStickers;
  final String? productProperties;
  final String? productRelated;
  final String? productSimilar;
  final String? productStockCount;
  final String? productStockPrice;
  final String? productStockPriceOld;
  final String? productMnn;
  final String? productAvailability;
  final String? productVariable;
  final String? productVariantCode;
  final int? productTrademark;
  final int? productNomenclatureId;
  final dynamic shu;
  final String? image;
  final List<dynamic>? gallery;
  final bool? isAlcohol;
  final bool? isDietarySupplement;
  final bool? isAvailable;
  final List<dynamic>? stickers;
  final Properties? properties;
  final String? productUid1C;

  ProductJsonModel({
    this.id,
    this.type,
    this.contentType,
    this.pagetitle,
    this.longtitle,
    this.description,
    this.alias,
    this.linkAttributes,
    this.published,
    this.pubDate,
    this.unpubDate,
    this.parent,
    this.isfolder,
    this.introtext,
    this.content,
    this.richtext,
    this.template,
    this.menuindex,
    this.searchable,
    this.cacheable,
    this.createdby,
    this.createdon,
    this.editedby,
    this.editedon,
    this.deleted,
    this.deletedon,
    this.deletedby,
    this.publishedon,
    this.publishedby,
    this.menutitle,
    this.hideFromTree,
    this.privateweb,
    this.privatemgr,
    this.contentDispo,
    this.hidemenu,
    this.aliasVisible,
    this.tvProductImage,
    this.tvProductProperties,
    this.tvProductUid1C,
    this.tvProductCode,
    this.tvProductMnn,
    this.tvProductItemType,
    this.tvProductTrademark,
    this.tvProductForm,
    this.tvProductNomenclatureId,
    this.tvProductPrice,
    this.tvProductPriceOld,
    this.tvProductPricePercent,
    this.tvProductAvailability,
    this.tvProductGallery,
    this.tvProductIsRecipe,
    this.tvProductStickers,
    this.tvProductRelated,
    this.tvProductStockCount,
    this.tvProductStockPrice,
    this.tvProductStockPriceOld,
    this.tvProductVariantCode,
    this.tvProductVariable,
    this.tvProductSimilar,
    this.tvProductIsAlcohol,
    this.date,
    this.title,
    this.url,
    this.ePagetitle,
    this.productCode,
    this.productGallery,
    this.productImage,
    this.productPrice,
    this.productPriceOld,
    this.productPricePercent,
    this.productIsRecipe,
    this.productIsAlcohol,
    this.productIsDietarySupplement,
    this.productStickers,
    this.productProperties,
    this.productRelated,
    this.productSimilar,
    this.productStockCount,
    this.productStockPrice,
    this.productStockPriceOld,
    this.productMnn,
    this.productAvailability,
    this.productVariable,
    this.productVariantCode,
    this.productTrademark,
    this.productNomenclatureId,
    this.shu,
    this.image,
    this.gallery,
    this.price,
    this.oldPrice,
    this.salePercent,
    this.isRecipe,
    this.isAlcohol,
    this.isDietarySupplement,
    this.isAvailable,
    this.stickers,
    this.properties,
    this.productUid1C,
  });

  ProductJsonModel copyWith({
    int? id,
    String? type,
    String? contentType,
    String? pagetitle,
    String? longtitle,
    String? description,
    String? alias,
    String? linkAttributes,
    String? published,
    String? pubDate,
    String? unpubDate,
    int? parent,
    String? isfolder,
    String? introtext,
    String? content,
    String? richtext,
    String? template,
    String? menuindex,
    String? searchable,
    String? cacheable,
    String? createdby,
    String? createdon,
    String? editedby,
    String? editedon,
    String? deleted,
    String? deletedon,
    String? deletedby,
    String? publishedon,
    String? publishedby,
    String? menutitle,
    String? hideFromTree,
    String? privateweb,
    String? privatemgr,
    String? contentDispo,
    String? hidemenu,
    String? aliasVisible,
    String? tvProductImage,
    String? tvProductProperties,
    String? tvProductUid1C,
    String? tvProductCode,
    String? tvProductMnn,
    String? tvProductItemType,
    String? tvProductTrademark,
    String? tvProductForm,
    String? tvProductNomenclatureId,
    String? tvProductPrice,
    String? tvProductPriceOld,
    String? tvProductPricePercent,
    String? tvProductAvailability,
    String? tvProductGallery,
    String? tvProductIsRecipe,
    String? tvProductStickers,
    String? tvProductRelated,
    String? tvProductStockCount,
    String? tvProductStockPrice,
    String? tvProductStockPriceOld,
    String? tvProductVariantCode,
    String? tvProductVariable,
    String? tvProductSimilar,
    String? tvProductIsAlcohol,
    String? date,
    String? title,
    String? url,
    String? ePagetitle,
    dynamic productCode,
    String? productGallery,
    String? productImage,
    String? productPrice,
    String? productPriceOld,
    String? productPricePercent,
    String? productIsRecipe,
    String? productIsAlcohol,
    dynamic productIsDietarySupplement,
    String? productStickers,
    String? productProperties,
    String? productRelated,
    String? productSimilar,
    String? productStockCount,
    String? productStockPrice,
    String? productStockPriceOld,
    String? productMnn,
    String? productAvailability,
    String? productVariable,
    String? productVariantCode,
    int? productTrademark,
    int? productNomenclatureId,
    dynamic shu,
    String? image,
    List<dynamic>? gallery,
    double? price,
    double? oldPrice,
    int? salePercent,
    bool? isRecipe,
    bool? isAlcohol,
    bool? isDietarySupplement,
    bool? isAvailable,
    List<dynamic>? stickers,
    Properties? properties,
    String? productUid1C,
  }) =>
      ProductJsonModel(
        id: id ?? this.id,
        type: type ?? this.type,
        contentType: contentType ?? this.contentType,
        pagetitle: pagetitle ?? this.pagetitle,
        longtitle: longtitle ?? this.longtitle,
        description: description ?? this.description,
        alias: alias ?? this.alias,
        linkAttributes: linkAttributes ?? this.linkAttributes,
        published: published ?? this.published,
        pubDate: pubDate ?? this.pubDate,
        unpubDate: unpubDate ?? this.unpubDate,
        parent: parent ?? this.parent,
        isfolder: isfolder ?? this.isfolder,
        introtext: introtext ?? this.introtext,
        content: content ?? this.content,
        richtext: richtext ?? this.richtext,
        template: template ?? this.template,
        menuindex: menuindex ?? this.menuindex,
        searchable: searchable ?? this.searchable,
        cacheable: cacheable ?? this.cacheable,
        createdby: createdby ?? this.createdby,
        createdon: createdon ?? this.createdon,
        editedby: editedby ?? this.editedby,
        editedon: editedon ?? this.editedon,
        deleted: deleted ?? this.deleted,
        deletedon: deletedon ?? this.deletedon,
        deletedby: deletedby ?? this.deletedby,
        publishedon: publishedon ?? this.publishedon,
        publishedby: publishedby ?? this.publishedby,
        menutitle: menutitle ?? this.menutitle,
        hideFromTree: hideFromTree ?? this.hideFromTree,
        privateweb: privateweb ?? this.privateweb,
        privatemgr: privatemgr ?? this.privatemgr,
        contentDispo: contentDispo ?? this.contentDispo,
        hidemenu: hidemenu ?? this.hidemenu,
        aliasVisible: aliasVisible ?? this.aliasVisible,
        tvProductImage: tvProductImage ?? this.tvProductImage,
        tvProductProperties: tvProductProperties ?? this.tvProductProperties,
        tvProductUid1C: tvProductUid1C ?? this.tvProductUid1C,
        tvProductCode: tvProductCode ?? this.tvProductCode,
        tvProductMnn: tvProductMnn ?? this.tvProductMnn,
        tvProductItemType: tvProductItemType ?? this.tvProductItemType,
        tvProductTrademark: tvProductTrademark ?? this.tvProductTrademark,
        tvProductForm: tvProductForm ?? this.tvProductForm,
        tvProductNomenclatureId:
            tvProductNomenclatureId ?? this.tvProductNomenclatureId,
        tvProductPrice: tvProductPrice ?? this.tvProductPrice,
        tvProductPriceOld: tvProductPriceOld ?? this.tvProductPriceOld,
        tvProductPricePercent:
            tvProductPricePercent ?? this.tvProductPricePercent,
        tvProductAvailability:
            tvProductAvailability ?? this.tvProductAvailability,
        tvProductGallery: tvProductGallery ?? this.tvProductGallery,
        tvProductIsRecipe: tvProductIsRecipe ?? this.tvProductIsRecipe,
        tvProductStickers: tvProductStickers ?? this.tvProductStickers,
        tvProductRelated: tvProductRelated ?? this.tvProductRelated,
        tvProductStockCount: tvProductStockCount ?? this.tvProductStockCount,
        tvProductStockPrice: tvProductStockPrice ?? this.tvProductStockPrice,
        tvProductStockPriceOld:
            tvProductStockPriceOld ?? this.tvProductStockPriceOld,
        tvProductVariantCode: tvProductVariantCode ?? this.tvProductVariantCode,
        tvProductVariable: tvProductVariable ?? this.tvProductVariable,
        tvProductSimilar: tvProductSimilar ?? this.tvProductSimilar,
        tvProductIsAlcohol: tvProductIsAlcohol ?? this.tvProductIsAlcohol,
        date: date ?? this.date,
        title: title ?? this.title,
        url: url ?? this.url,
        ePagetitle: ePagetitle ?? this.ePagetitle,
        productCode: productCode ?? this.productCode,
        productGallery: productGallery ?? this.productGallery,
        productImage: productImage ?? this.productImage,
        productPrice: productPrice ?? this.productPrice,
        productPriceOld: productPriceOld ?? this.productPriceOld,
        productPricePercent: productPricePercent ?? this.productPricePercent,
        productIsRecipe: productIsRecipe ?? this.productIsRecipe,
        productIsAlcohol: productIsAlcohol ?? this.productIsAlcohol,
        productIsDietarySupplement:
            productIsDietarySupplement ?? this.productIsDietarySupplement,
        productStickers: productStickers ?? this.productStickers,
        productProperties: productProperties ?? this.productProperties,
        productRelated: productRelated ?? this.productRelated,
        productSimilar: productSimilar ?? this.productSimilar,
        productStockCount: productStockCount ?? this.productStockCount,
        productStockPrice: productStockPrice ?? this.productStockPrice,
        productStockPriceOld: productStockPriceOld ?? this.productStockPriceOld,
        productMnn: productMnn ?? this.productMnn,
        productAvailability: productAvailability ?? this.productAvailability,
        productVariable: productVariable ?? this.productVariable,
        productVariantCode: productVariantCode ?? this.productVariantCode,
        productTrademark: productTrademark ?? this.productTrademark,
        productNomenclatureId:
            productNomenclatureId ?? this.productNomenclatureId,
        shu: shu ?? this.shu,
        image: image ?? this.image,
        gallery: gallery ?? this.gallery,
        price: price ?? this.price,
        oldPrice: oldPrice ?? this.oldPrice,
        salePercent: salePercent ?? this.salePercent,
        isRecipe: isRecipe ?? this.isRecipe,
        isAlcohol: isAlcohol ?? this.isAlcohol,
        isDietarySupplement: isDietarySupplement ?? this.isDietarySupplement,
        isAvailable: isAvailable ?? this.isAvailable,
        stickers: stickers ?? this.stickers,
        properties: properties ?? this.properties,
        productUid1C: productUid1C ?? this.productUid1C,
      );

  factory ProductJsonModel.fromRawJson(String str) =>
      ProductJsonModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductJsonModel.fromJson(Map<String, dynamic> json) =>
      ProductJsonModel(
        id: json["id"],
        type: json["type"],
        contentType: json["contentType"],
        pagetitle: json["pagetitle"],
        longtitle: json["longtitle"],
        description: json["description"],
        alias: json["alias"],
        linkAttributes: json["link_attributes"],
        published: json["published"],
        pubDate: json["pub_date"],
        unpubDate: json["unpub_date"],
        parent: json["parent"],
        isfolder: json["isfolder"],
        introtext: json["introtext"],
        content: json["content"],
        richtext: json["richtext"],
        template: json["template"],
        menuindex: json["menuindex"],
        searchable: json["searchable"],
        cacheable: json["cacheable"],
        createdby: json["createdby"],
        createdon: json["createdon"],
        editedby: json["editedby"],
        editedon: json["editedon"],
        deleted: json["deleted"],
        deletedon: json["deletedon"],
        deletedby: json["deletedby"],
        publishedon: json["publishedon"],
        publishedby: json["publishedby"],
        menutitle: json["menutitle"],
        hideFromTree: json["hide_from_tree"],
        privateweb: json["privateweb"],
        privatemgr: json["privatemgr"],
        contentDispo: json["content_dispo"],
        hidemenu: json["hidemenu"],
        aliasVisible: json["alias_visible"],
        tvProductImage: json["tv_product_image"],
        tvProductProperties: json["tv_product_properties"],
        tvProductUid1C: json["tv_product_uid_1c"],
        tvProductCode: json["tv_product_code"],
        tvProductMnn: json["tv_product_mnn"],
        tvProductItemType: json["tv_product_item_type"],
        tvProductTrademark: json["tv_product_trademark"],
        tvProductForm: json["tv_product_form"],
        tvProductNomenclatureId: json["tv_product_nomenclature_id"],
        tvProductPrice: json["tv_product_price"],
        tvProductPriceOld: json["tv_product_price_old"],
        tvProductPricePercent: json["tv_product_price_percent"],
        tvProductAvailability: json["tv_product_availability"],
        tvProductGallery: json["tv_product_gallery"],
        tvProductIsRecipe: json["tv_product_is_recipe"],
        tvProductStickers: json["tv_product_stickers"],
        tvProductRelated: json["tv_product_related"],
        tvProductStockCount: json["tv_product_stock_count"],
        tvProductStockPrice: json["tv_product_stock_price"],
        tvProductStockPriceOld: json["tv_product_stock_price_old"],
        tvProductVariantCode: json["tv_product_variant_code"],
        tvProductVariable: json["tv_product_variable"],
        tvProductSimilar: json["tv_product_similar"],
        tvProductIsAlcohol: json["tv_product_is_alcohol"],
        date: json["date"],
        title: json["title"],
        url: json["url"],
        ePagetitle: json["e_pagetitle"],
        productCode: json["product_code"],
        productGallery: json["product_gallery"],
        productImage: json["product_image"],
        productPrice: json["product_price"],
        productPriceOld: json["product_price_old"],
        productPricePercent: json["product_price_percent"],
        productIsRecipe: json["product_is_recipe"],
        productIsAlcohol: json["product_is_alcohol"],
        productIsDietarySupplement: json["product_is_dietary_supplement"],
        productStickers: json["product_stickers"],
        productProperties: json["product_properties"],
        productRelated: json["product_related"],
        productSimilar: json["product_similar"],
        productStockCount: json["product_stock_count"],
        productStockPrice: json["product_stock_price"],
        productStockPriceOld: json["product_stock_price_old"],
        productMnn: json["product_mnn"],
        productAvailability: json["product_availability"],
        productVariable: json["product_variable"],
        productVariantCode: json["product_variant_code"],
        productTrademark: json["product_trademark"],
        productNomenclatureId: json["product_nomenclature_id"],
        shu: json["shu"],
        image: json["image"],
        gallery: json["gallery"] == null
            ? []
            : List<dynamic>.from(json["gallery"]!.map((x) => x)),
        price: json["price"]?.toDouble(),
        oldPrice: json["oldPrice"]?.toDouble(),
        salePercent: json["salePercent"],
        isRecipe: json["isRecipe"],
        isAlcohol: json["isAlcohol"],
        isDietarySupplement: json["isDietarySupplement"],
        isAvailable: json["isAvailable"],
        stickers: json["stickers"] == null
            ? []
            : List<dynamic>.from(json["stickers"]!.map((x) => x)),
        properties: json["properties"] == null
            ? null
            : Properties.fromJson(json["properties"]),
        productUid1C: json["product_uid_1c"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "contentType": contentType,
        "pagetitle": pagetitle,
        "longtitle": longtitle,
        "description": description,
        "alias": alias,
        "link_attributes": linkAttributes,
        "published": published,
        "pub_date": pubDate,
        "unpub_date": unpubDate,
        "parent": parent,
        "isfolder": isfolder,
        "introtext": introtext,
        "content": content,
        "richtext": richtext,
        "template": template,
        "menuindex": menuindex,
        "searchable": searchable,
        "cacheable": cacheable,
        "createdby": createdby,
        "createdon": createdon,
        "editedby": editedby,
        "editedon": editedon,
        "deleted": deleted,
        "deletedon": deletedon,
        "deletedby": deletedby,
        "publishedon": publishedon,
        "publishedby": publishedby,
        "menutitle": menutitle,
        "hide_from_tree": hideFromTree,
        "privateweb": privateweb,
        "privatemgr": privatemgr,
        "content_dispo": contentDispo,
        "hidemenu": hidemenu,
        "alias_visible": aliasVisible,
        "tv_product_image": tvProductImage,
        "tv_product_properties": tvProductProperties,
        "tv_product_uid_1c": tvProductUid1C,
        "tv_product_code": tvProductCode,
        "tv_product_mnn": tvProductMnn,
        "tv_product_item_type": tvProductItemType,
        "tv_product_trademark": tvProductTrademark,
        "tv_product_form": tvProductForm,
        "tv_product_nomenclature_id": tvProductNomenclatureId,
        "tv_product_price": tvProductPrice,
        "tv_product_price_old": tvProductPriceOld,
        "tv_product_price_percent": tvProductPricePercent,
        "tv_product_availability": tvProductAvailability,
        "tv_product_gallery": tvProductGallery,
        "tv_product_is_recipe": tvProductIsRecipe,
        "tv_product_stickers": tvProductStickers,
        "tv_product_related": tvProductRelated,
        "tv_product_stock_count": tvProductStockCount,
        "tv_product_stock_price": tvProductStockPrice,
        "tv_product_stock_price_old": tvProductStockPriceOld,
        "tv_product_variant_code": tvProductVariantCode,
        "tv_product_variable": tvProductVariable,
        "tv_product_similar": tvProductSimilar,
        "tv_product_is_alcohol": tvProductIsAlcohol,
        "date": date,
        "title": title,
        "url": url,
        "e_pagetitle": ePagetitle,
        "product_code": productCode,
        "product_gallery": productGallery,
        "product_image": productImage,
        "product_price": productPrice,
        "product_price_old": productPriceOld,
        "product_price_percent": productPricePercent,
        "product_is_recipe": productIsRecipe,
        "product_is_alcohol": productIsAlcohol,
        "product_is_dietary_supplement": productIsDietarySupplement,
        "product_stickers": productStickers,
        "product_properties": productProperties,
        "product_related": productRelated,
        "product_similar": productSimilar,
        "product_stock_count": productStockCount,
        "product_stock_price": productStockPrice,
        "product_stock_price_old": productStockPriceOld,
        "product_mnn": productMnn,
        "product_availability": productAvailability,
        "product_variable": productVariable,
        "product_variant_code": productVariantCode,
        "product_trademark": productTrademark,
        "product_nomenclature_id": productNomenclatureId,
        "shu": shu,
        "image": image,
        "gallery":
            gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "price": price,
        "oldPrice": oldPrice,
        "salePercent": salePercent,
        "isRecipe": isRecipe,
        "isAlcohol": isAlcohol,
        "isDietarySupplement": isDietarySupplement,
        "isAvailable": isAvailable,
        "stickers":
            stickers == null ? [] : List<dynamic>.from(stickers!.map((x) => x)),
        "properties": properties?.toJson(),
        "product_uid_1c": productUid1C,
      };
}

class Properties {
  final Brand? mnn;
  final Brand? code;
  final Brand? brand;
  final Brand? country;
  final Brand? releaseForm;
  final Brand? insert;
  final Brand? termin;

  Properties({
    this.mnn,
    this.code,
    this.brand,
    this.country,
    this.releaseForm,
    this.insert,
    this.termin,
  });

  Properties copyWith({
    Brand? mnn,
    Brand? code,
    Brand? brand,
    Brand? country,
    Brand? releaseForm,
    Brand? insert,
    Brand? termin,
  }) =>
      Properties(
        mnn: mnn ?? this.mnn,
        code: code ?? this.code,
        brand: brand ?? this.brand,
        country: country ?? this.country,
        releaseForm: releaseForm ?? this.releaseForm,
        insert: insert ?? this.insert,
        termin: termin ?? this.termin,
      );

  factory Properties.fromRawJson(String str) =>
      Properties.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mnn: json["mnn"] == null ? null : Brand.fromJson(json["mnn"]),
        code: json["code"] == null ? null : Brand.fromJson(json["code"]),
        brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
        country:
            json["country"] == null ? null : Brand.fromJson(json["country"]),
        releaseForm: json["release_form"] == null
            ? null
            : Brand.fromJson(json["release_form"]),
        insert: json["insert"] == null ? null : Brand.fromJson(json["insert"]),
        termin: json["termin"] == null ? null : Brand.fromJson(json["termin"]),
      );

  Map<String, dynamic> toJson() => {
        "mnn": mnn?.toJson(),
        "code": code?.toJson(),
        "brand": brand?.toJson(),
        "country": country?.toJson(),
        "release_form": releaseForm?.toJson(),
        "insert": insert?.toJson(),
        "termin": termin?.toJson(),
      };
}

class Brand {
  final String? id;
  final String? title;
  final String? value;

  Brand({
    this.id,
    this.title,
    this.value,
  });

  Brand copyWith({
    String? id,
    String? title,
    String? value,
  }) =>
      Brand(
        id: id ?? this.id,
        title: title ?? this.title,
        value: value ?? this.value,
      );

  factory Brand.fromRawJson(String str) => Brand.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json["id"],
        title: json["title"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "value": value,
      };
}
