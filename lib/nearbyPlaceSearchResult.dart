// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

NearbyPlacesSearchResult welcomeFromJson(String str) => NearbyPlacesSearchResult.fromJson(json.decode(str));

String welcomeToJson(NearbyPlacesSearchResult data) => json.encode(data.toJson());


class NearbyPlacesSearchResult {
  Geometry? geometry;
  String? icon, name, placeId, scope, vicinity, reference;
  List<Photo>? photos;
  List<String>? types;

  NearbyPlacesSearchResult({
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

  factory NearbyPlacesSearchResult.fromJson(Map<String, dynamic> json) => NearbyPlacesSearchResult(
    geometry: json["geometry"] == null ? null : Geometry.fromJson(json["geometry"]),
    icon: json["icon"] == null ? null : json["icon"],
    name: json["name"] == null ? null : json["name"],
    photos: json["photos"] == null ? null : List<Photo>.from(json["photos"].map((x) => Photo.fromJson(x))),
    placeId: json["place_id"] == null ? null : json["place_id"],
    reference: json["reference"] == null ? null : json["reference"],
    scope: json["scope"] == null ? null : json["scope"],
    types: json["types"] == null ? null : List<String>.from(json["types"].map((x) => x)),
    vicinity: json["vicinity"] == null ? null : json["vicinity"],
  );

  Map<String, dynamic> toJson() => {
    "geometry": geometry == null ? null : geometry?.toJson(),
    "icon": icon == null ? null : icon,
    "name": name == null ? null : name,
    "photos": photos == null ? null : List<dynamic>.from(photos!.map((x) => x.toJson())),
    "place_id": placeId == null ? null : placeId,
    "reference": reference == null ? null : reference,
    "scope": scope == null ? null : scope,
    "types": types == null ? null : List<dynamic>.from(types!.map((x) => x)),
    "vicinity": vicinity == null ? null : vicinity,
  };
}

class Geometry {
  Location? location;
  Viewport? viewport;
  Geometry({
    this.location,
    this.viewport,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    location: json["location"] == null ? null : Location.fromJson(json["location"]),
    viewport: json["viewport"] == null ? null : Viewport.fromJson(json["viewport"]),
  );

  Map<String, dynamic> toJson() => {
    "location": location == null ? null : location?.toJson(),
    "viewport": viewport == null ? null : viewport?.toJson(),
  };
}

class Location {
  double? lat;
  double? lng;
  Location({
    this.lat,
    this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"] == null ? null : json["lat"].toDouble(),
    lng: json["lng"] == null ? null : json["lng"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat == null ? null : lat,
    "lng": lng == null ? null : lng,
  };
}

class Viewport {
  Location? northeast;
  Location? southwest;
  Viewport({
    this.northeast,
    this.southwest,
  });

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
    northeast: json["northeast"] == null ? null : Location.fromJson(json["northeast"]),
    southwest: json["southwest"] == null ? null : Location.fromJson(json["southwest"]),
  );

  Map<String, dynamic> toJson() => {
    "northeast": northeast == null ? null : northeast?.toJson(),
    "southwest": southwest == null ? null : southwest?.toJson(),
  };
}

class Photo {
  int? height, width;
  List<String>? htmlAttributions;
  String? photoReference;
  Photo({
    this.height,
    this.htmlAttributions,
    this.photoReference,
    this.width,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    height: json["height"] == null ? null : json["height"],
    htmlAttributions: json["html_attributions"] == null ? null : List<String>.from(json["html_attributions"].map((x) => x)),
    photoReference: json["photo_reference"] == null ? null : json["photo_reference"],
    width: json["width"] == null ? null : json["width"],
  );

  Map<String, dynamic> toJson() => {
    "height": height == null ? null : height,
    "html_attributions": htmlAttributions == null ? null : List<dynamic>.from(htmlAttributions!.map((x) => x)),
    "photo_reference": photoReference == null ? null : photoReference,
    "width": width == null ? null : width,
  };
}
