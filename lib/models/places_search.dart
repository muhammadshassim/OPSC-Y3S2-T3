class PlaceSearch {
  final String placeID;
  final String description;

  PlaceSearch({required this.placeID, required this.description});

  factory PlaceSearch.fromJson(Map<String, dynamic> json) {
    return PlaceSearch(
      placeID: json['place_id'],
      description: json['description']
    );
  }
}