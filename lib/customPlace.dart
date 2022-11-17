
import 'package:meta/meta.dart';
import 'dart:convert';

Place placeFromJson(String str) => Place.fromJson(json.decode(str));

String placeToJson(Place data) => json.encode(data.toJson());

class Place {
  Place({
    required this.htmlAttributions,
    required this.result,
    required this.status,
  });

  List<dynamic> htmlAttributions;
  Result result;
  String status;

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    htmlAttributions: List<dynamic>.from(json["html_attributions"].map((x) => x)),
    result: Result.fromJson(json["result"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "html_attributions": List<dynamic>.from(htmlAttributions.map((x) => x)),
    "result": result.toJson(),
    "status": status,
  };
}

class Result {
  Result({
    required this.addressComponents,
    required this.adrAddress,
    required this.businessStatus,
    required this.formattedAddress,
    required this.formattedPhoneNumber,
    required this.geometry,
    required this.icon,
    required this.internationalPhoneNumber,
    required this.name,
    required this.openingHours,
    required this.photos,
    required this.placeId,
    required this.plusCode,
    required this.rating,
    required this.reference,
    required this.reviews,
    required this.types,
    required this.url,
    required this.userRatingsTotal,
    required this.utcOffset,
    required this.vicinity,
    required this.website,
  });

  List<AddressComponent> addressComponents;
  String adrAddress;
  String businessStatus;
  String formattedAddress;
  String formattedPhoneNumber;
  Geometry geometry;
  String icon;
  String internationalPhoneNumber;
  String name;
  OpeningHours openingHours;
  List<Photo> photos;
  String placeId;
  PlusCode plusCode;
  double rating;
  String reference;
  List<Review> reviews;
  List<String> types;
  String url;
  int userRatingsTotal;
  int utcOffset;
  String vicinity;
  String website;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    addressComponents: List<AddressComponent>.from(json["address_components"].map((x) => AddressComponent.fromJson(x))),
    adrAddress: json["adr_address"],
    businessStatus: json["business_status"],
    formattedAddress: json["formatted_address"],
    formattedPhoneNumber: json["formatted_phone_number"],
    geometry: Geometry.fromJson(json["geometry"]),
    icon: json["icon"],
    internationalPhoneNumber: json["international_phone_number"],
    name: json["name"],
    openingHours: OpeningHours.fromJson(json["opening_hours"]),
    photos: List<Photo>.from(json["photos"].map((x) => Photo.fromJson(x))),
    placeId: json["place_id"],
    plusCode: PlusCode.fromJson(json["plus_code"]),
    rating: json["rating"].toDouble(),
    reference: json["reference"],
    reviews: List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))),
    types: List<String>.from(json["types"].map((x) => x)),
    url: json["url"],
    userRatingsTotal: json["user_ratings_total"],
    utcOffset: json["utc_offset"],
    vicinity: json["vicinity"],
    website: json["website"],
  );

  Map<String, dynamic> toJson() => {
    "address_components": List<dynamic>.from(addressComponents.map((x) => x.toJson())),
    "adr_address": adrAddress,
    "business_status": businessStatus,
    "formatted_address": formattedAddress,
    "formatted_phone_number": formattedPhoneNumber,
    "geometry": geometry.toJson(),
    "icon": icon,
    "international_phone_number": internationalPhoneNumber,
    "name": name,
    "opening_hours": openingHours.toJson(),
    "photos": List<dynamic>.from(photos.map((x) => x.toJson())),
    "place_id": placeId,
    "plus_code": plusCode.toJson(),
    "rating": rating,
    "reference": reference,
    "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
    "types": List<dynamic>.from(types.map((x) => x)),
    "url": url,
    "user_ratings_total": userRatingsTotal,
    "utc_offset": utcOffset,
    "vicinity": vicinity,
    "website": website,
  };
}

class AddressComponent {
  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  String longName;
  String shortName;
  List<String> types;

  factory AddressComponent.fromJson(Map<String, dynamic> json) => AddressComponent(
    longName: json["long_name"],
    shortName: json["short_name"],
    types: List<String>.from(json["types"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "long_name": longName,
    "short_name": shortName,
    "types": List<dynamic>.from(types.map((x) => x)),
  };
}

class Geometry {
  Geometry({
    required this.location,
    required this.viewport,
  });

  Location location;
  Viewport viewport;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    location: Location.fromJson(json["location"]),
    viewport: Viewport.fromJson(json["viewport"]),
  );

  Map<String, dynamic> toJson() => {
    "location": location.toJson(),
    "viewport": viewport.toJson(),
  };
}

class Location {
  Location({
    required this.lat,
    required this.lng,
  });

  double lat;
  double lng;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
  };
}

class Viewport {
  Viewport({
    required this.northeast,
    required this.southwest,
  });

  Location northeast;
  Location southwest;

  factory Viewport.fromJson(Map<String, dynamic> json) => Viewport(
    northeast: Location.fromJson(json["northeast"]),
    southwest: Location.fromJson(json["southwest"]),
  );

  Map<String, dynamic> toJson() => {
    "northeast": northeast.toJson(),
    "southwest": southwest.toJson(),
  };
}

class OpeningHours {
  OpeningHours({
    required this.openNow,
    required this.periods,
    required this.weekdayText,
  });

  bool openNow;
  List<Period> periods;
  List<String> weekdayText;

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
    openNow: json["open_now"],
    periods: List<Period>.from(json["periods"].map((x) => Period.fromJson(x))),
    weekdayText: List<String>.from(json["weekday_text"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "open_now": openNow,
    "periods": List<dynamic>.from(periods.map((x) => x.toJson())),
    "weekday_text": List<dynamic>.from(weekdayText.map((x) => x)),
  };
}

class Period {
  Period({
    required this.open,
  });

  Open open;

  factory Period.fromJson(Map<String, dynamic> json) => Period(
    open: Open.fromJson(json["open"]),
  );

  Map<String, dynamic> toJson() => {
    "open": open.toJson(),
  };
}

class Open {
  Open({
    required this.day,
    required this.time,
  });

  int day;
  String time;

  factory Open.fromJson(Map<String, dynamic> json) => Open(
    day: json["day"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "day": day,
    "time": time,
  };
}

class Photo {
  Photo({
    required this.height,
    required this.htmlAttributions,
    required this.photoReference,
    required this.width,
  });

  int height;
  List<String> htmlAttributions;
  String photoReference;
  int width;

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
    height: json["height"],
    htmlAttributions: List<String>.from(json["html_attributions"].map((x) => x)),
    photoReference: json["photo_reference"],
    width: json["width"],
  );

  Map<String, dynamic> toJson() => {
    "height": height,
    "html_attributions": List<dynamic>.from(htmlAttributions.map((x) => x)),
    "photo_reference": photoReference,
    "width": width,
  };
}

class PlusCode {
  PlusCode({
    required this.compoundCode,
    required this.globalCode,
  });

  String compoundCode;
  String globalCode;

  factory PlusCode.fromJson(Map<String, dynamic> json) => PlusCode(
    compoundCode: json["compound_code"],
    globalCode: json["global_code"],
  );

  Map<String, dynamic> toJson() => {
    "compound_code": compoundCode,
    "global_code": globalCode,
  };
}

class Review {
  Review({
    required this.authorName,
    required this.authorUrl,
    required this.language,
    required this.profilePhotoUrl,
    required this.rating,
    required this.relativeTimeDescription,
    required this.text,
    required this.time,
  });

  String authorName;
  String authorUrl;
  String language;
  String profilePhotoUrl;
  int rating;
  String relativeTimeDescription;
  String text;
  int time;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    authorName: json["author_name"],
    authorUrl: json["author_url"],
    language: json["language"],
    profilePhotoUrl: json["profile_photo_url"],
    rating: json["rating"],
    relativeTimeDescription: json["relative_time_description"],
    text: json["text"],
    time: json["time"],
  );

  Map<String, dynamic> toJson() => {
    "author_name": authorName,
    "author_url": authorUrl,
    "language": language,
    "profile_photo_url": profilePhotoUrl,
    "rating": rating,
    "relative_time_description": relativeTimeDescription,
    "text": text,
    "time": time,
  };
}
