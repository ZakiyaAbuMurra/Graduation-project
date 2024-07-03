import 'dart:math' show asin, atan2, cos, sin, sqrt;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Graph {
  Map<LatLng, Map<LatLng, double>> adjacencyList = {};

  void addEdge(LatLng from, LatLng to, double distance) {
    if (adjacencyList[from] == null) {
      adjacencyList[from] = {};
    }
    if (adjacencyList[to] == null) {
      adjacencyList[to] = {};
    }
    adjacencyList[from]![to] = distance;
    adjacencyList[to]![from] = distance; // Assuming bidirectional edges
  }

  List<LatLng> findShortestPath(List<LatLng> locations) {
    // Create a copy of the locations list to modify
    List<LatLng> path = [...locations];

    // Starting location (assuming the first location in the list is the start)
    LatLng current = path[0];
    path.removeAt(0); // Remove the start location from the path list

    while (path.isNotEmpty) {
      // Find the nearest location to the current location
      LatLng nearest = _findNearestLocation(current, path);

      // Draw the shortest path between the current and nearest location
      _drawShortestPath(current, nearest);

      // Move to the nearest location and remove it from the path list
      current = nearest;
      path.remove(nearest);
    }

    // Draw the last segment back to the starting location to complete the loop
    _drawShortestPath(current, locations[0]);

    return locations;
  }

  LatLng _findNearestLocation(LatLng from, List<LatLng> locations) {
    LatLng nearest = locations[0];
    double minDistance = double.infinity;

    for (LatLng location in locations) {
      double distance = adjacencyList[from]![location]!;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }
    }

    return nearest;
  }

  void _drawShortestPath(LatLng from, LatLng to) {
    // Draw polyline between two points
    // This should be implemented based on your Google Maps integration
    // Example: polylines.add(Polyline(...));
    // Ensure you have polylines set in the GoogleMap widget
  }
}

double calculateDistance(LatLng from, LatLng to) {
  const double earthRadius = 6371e3; // meters
  double lat1 = from.latitude * (3.141592653589793 / 180);
  double lat2 = to.latitude * (3.141592653589793 / 180);
  double deltaLat = (to.latitude - from.latitude) * (3.141592653589793 / 180);
  double deltaLon = (to.longitude - from.longitude) * (3.141592653589793 / 180);

  double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
      (cos(lat1) * cos(lat2) *
          sin(deltaLon / 2) * sin(deltaLon / 2));
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

void createGraph(Graph graph, List<LatLng> locations) {
  for (int i = 0; i < locations.length; i++) {
    for (int j = i + 1; j < locations.length; j++) {
      double distance = calculateDistance(locations[i], locations[j]);
      graph.addEdge(locations[i], locations[j], distance);
    }
  }
}
