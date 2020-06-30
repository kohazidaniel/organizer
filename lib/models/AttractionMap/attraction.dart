import 'package:google_maps_flutter/google_maps_flutter.dart';

class Attraction {
  final CameraPosition cameraPosition;
  final String id;
  final String name;
  final String imageUrl;
  final String address;

  Attraction(
      {this.id, this.cameraPosition, this.name, this.imageUrl, this.address});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lat': cameraPosition.target.latitude,
      'lon': cameraPosition.target.longitude,
      'name': name,
      'image_url': imageUrl,
      'address': address
    };
  }
}
