class CourierZoneModel {
  final String type;
  final Metadata metadata;
  final List<Feature> features;

  CourierZoneModel({
    required this.type,
    required this.metadata,
    required this.features,
  });

  factory CourierZoneModel.fromJson(Map<String, dynamic> json) {
    return CourierZoneModel(
      type: json['type'],
      metadata: Metadata.fromJson(json['metadata']),
      features: (json['features'] as List)
          .map((feature) => Feature.fromJson(feature))
          .toList(),
    );
  }
}

class Metadata {
  final String name;
  final String creator;
  final String description;

  Metadata({
    required this.name,
    required this.creator,
    required this.description,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      name: json['name'],
      creator: json['creator'],
      description: json['description'],
    );
  }
}

class Feature {
  final int id;
  final Geometry geometry;
  final Properties properties;

  Feature({
    required this.id,
    required this.geometry,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      geometry: Geometry.fromJson(json['geometry']),
      properties: Properties.fromJson(json['properties']),
    );
  }
}

class Geometry {
  final String type;
  final List<List<List<double>>> coordinates;

  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'],
      coordinates: (json['coordinates'] as List)
          .map((polygon) => (polygon as List)
              .map((point) => (point as List)
                  .map(
                    (coord) => (coord as double),
                  )
                  .toList())
              .toList())
          .toList(),
    );
  }
}

class Properties {
  final String fill;
  final double fillOpacity;
  final String stroke;
  final double strokeWidth;
  final double strokeOpacity;

  Properties({
    required this.fill,
    required this.fillOpacity,
    required this.stroke,
    required this.strokeWidth,
    required this.strokeOpacity,
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      fill: json['fill'],
      fillOpacity: (json['fill-opacity'] as num).toDouble(),
      stroke: json['stroke'],
      strokeWidth: double.parse(json['stroke-width']),
      strokeOpacity: (json['stroke-opacity'] as num).toDouble(),
    );
  }
}
