class CourierNearestSearch {
  final String courierId;
  final double distanceKm;
  final double estimatedTimeMin;
  final double latitude;
  final double longitude;

  const CourierNearestSearch({
    required this.courierId,
    required this.distanceKm,
    required this.estimatedTimeMin,
    required this.latitude,
    required this.longitude,
  });
}
