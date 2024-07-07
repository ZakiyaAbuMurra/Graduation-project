import 'dart:math';

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

  Map<LatLng, double> dijkstra(LatLng start) {
    Map<LatLng, double> distances = {};
    Map<LatLng, LatLng?> previous = {};
    List<LatLng> nodes = [];

    for (LatLng vertex in adjacencyList.keys) {
      if (vertex == start) {
        distances[vertex] = 0;
      } else {
        distances[vertex] = double.infinity;
      }
      nodes.add(vertex);
      previous[vertex] = null;
    }

    while (nodes.isNotEmpty) {
      nodes.sort((a, b) => distances[a]!.compareTo(distances[b]!));
      LatLng smallest = nodes.removeAt(0);

      if (distances[smallest] == double.infinity) {
        break;
      }

      if (adjacencyList[smallest] != null) {
        for (LatLng neighbor in adjacencyList[smallest]!.keys) {
          double? alt = distances[smallest]! + adjacencyList[smallest]![neighbor]!;
          if (alt < distances[neighbor]!) {
            distances[neighbor] = alt;
            previous[neighbor] = smallest;
          }
        }
      }
    }

    return distances;
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

void createGraph(Graph graph, LatLng currentLocation, List<LatLng> locations) {
  for (LatLng location in locations) {
    double distance = calculateDistance(currentLocation, location);
    graph.addEdge(currentLocation, location, distance);
  }
}
