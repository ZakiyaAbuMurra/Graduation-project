// import 'dart:convert';
// import 'dart:collection';

// import 'package:collection/collection.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class Graph{
//   final Map<LatLng,Map<LatLng,double>> adjacencyList;

//   Graph():adjacencyList = {};

//   void addVertex(LatLng vertex){
//     if(!adjacencyList.containsKey(vertex)){
//       adjacencyList[vertex] = {};
//     }
//   }

//   void addEdge(LatLng start,LatLng end, double weight){
//     addVertex(start);
//     addVertex(end);
//     adjacencyList[start]![end] = weight;
//     adjacencyList[end]![start] = weight;
//   }

//   List <LatLng> shortestPath(LatLng start){
//     var distance = <LatLng,double>{};
//     var proirtyQUEUE = HeapPriorityQueue<MapEntry<LatLng,double>>(
//             compare: (a, b) => a.value.compareTo(b.value),

//     );
//   }
// }