// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

NearbyPlaces welcomeFromJson(String str) => NearbyPlaces.fromJson(json.decode(str));

String welcomeToJson(NearbyPlaces data) => json.encode(data.toJson());

class NearbyPlaces {
  Geometry? geometry;
  String? icon;
  String? name;
  List<Photo>? photos;
  String? placeId;
  String? reference;
  String? scope;
  List<String>? types;
  String? vicinity;

  NearbyPlaces({
    this.geometry,
    this.icon,
    this.name,
    this.photos,
    this.placeId,
    this.reference,
    this.scope,
    this.types,
    this.vicinity,
  });

  factory NearbyPlaces.fromJson(Map<String?, dynamic>? json) => NearbyPlaces(
    geometry: Geometry.fromJson(json!["geometry"]),
    icon: json["icon"],
    name: json["name"],
    photos: List<Photo>.from(json["photos"].map((x) => Photo.fromJson(x))),
    placeId: json["place_id"],
    reference: json["reference"],
    scope: json["scope"],
    types: List<String>.from(json["types"].map((x) => x)),
    vicinity: json["vicinity"],
  );

  Map<String, dynamic> toJson() => {
    "geometry": geometry!.toJson(),
    "icon": icon,
    "name": name,
    "photos": List<dynamic>.from(photos!.map((x) => x.toJson())),
    "place_id": placeId,
    "reference": reference,
    "scope": scope,
    "types": List<dynamic>.from(types!.map((x) => x)),
    "vicinity": vicinity,
  };
}

class Geometry {
  jLocation? location;
  Viewport? viewport;
  Geometry({
    this.location,
    this.viewport,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    location: jLocation.fromJson(json["location"]),
    viewport: Viewport.fromJson(json["viewport"]),
  );

  Map<String, dynamic> toJson() => {
    "location": location!.toJson(),
    "viewport": viewport!.toJson(),
  };
}

class jLocation {
  double? lat;
  double? lng;
  jLocation({
    this.lat,
    this.lng,
  });

  factory jLocation.fromJson(Map<String, dynamic> json) => jLocation(
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
  };
}

class Viewport {
  jLocation? northeast;
  jLocation? southwest;
  Viewport({
    this.northeast,
    this.southwest,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
    northeast: jLocation.fromJson(json["northeast"]),
    southwest: jLocation.fromJson(json["southwest"]),
  );

  Map<String, dynamic> toJson() => {
    "northeast": northeast!.toJson(),
    "southwest": southwest!.toJson(),
  };
}

class Photo {
  int? height;
  List<String>? htmlAttributions;
  String? photoReference;
  int? width;
  Photo({
    this.height,
    this.htmlAttributions,
    this.photoReference,
    this.width,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    height: json["height"],
    htmlAttributions: List<String>.from(json["html_attributions"].map((x) => x)),
    photoReference: json["photo_reference"],
    width: json["width"],
  );

  Map<String, dynamic> toJson() => {
    "height": height,
    "html_attributions": List<dynamic>.from(htmlAttributions!.map((x) => x)),
    "photo_reference": photoReference,
    "width": width,
  };
}
