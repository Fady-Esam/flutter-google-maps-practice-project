import 'package:apply_google_maps/data/place_model_list.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapCustomWidget extends StatefulWidget {
  const GoogleMapCustomWidget({super.key});

  @override
  State<GoogleMapCustomWidget> createState() => _GoogleMapCustomWidgetState();
}

class _GoogleMapCustomWidgetState extends State<GoogleMapCustomWidget> {
  late CameraPosition cameraPosition;
  late GoogleMapController googleMapController;
  String? mapStyleString;
  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};
  Set<Polygon> polygons = {};
  Set<Circle> circles = {};

  @override
  void initState() {
    super.initState();
    cameraPosition = CameraPosition(
      target: LatLng(30.037288986825594, 31.223923051707246),
      zoom: 4,
    );
    initMapStyle();
    initMarkers();
    initPolyLines();
    initPolygons();
    initCircles();
  }

  @override
  void dispose() {
    super.dispose();
    googleMapController.dispose();
  }

  void initMapStyle() async {
    String style = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/google_map_styles/night_style.json');
    setState(() {
      mapStyleString = style;
    });
  }

  void initMarkers() async {
    var markerIcon = await BitmapDescriptor.asset(
      ImageConfiguration(),
      'assets/images/google_map_marker.png',
      width: 30,
    );
    markers.addAll(
      places
          .map(
            (p) => Marker(
              icon: markerIcon,
              markerId: MarkerId(p.id.toString()),
              position: LatLng(p.lat, p.long),
              infoWindow: InfoWindow(title: p.name),
            ),
          )
          .toSet(),
    );
  }

  void initPolyLines() {
    polyLines.add(
      Polyline(
        geodesic: true,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        polylineId: PolylineId("1"),
        color: Colors.red,
        points: [
          LatLng(30.037288986825594, 31.223923051707246),
          LatLng(31.037288986825594, 31.223923051707246),
        ],
      ),
    );
  }

  void initPolygons() {
    polygons.add(
      Polygon(
        holes: [
          // Example hole (Great Sand Sea)
          [
            LatLng(26.0, 27.0),
            LatLng(26.0, 28.0),
            LatLng(25.5, 28.0),
            LatLng(25.5, 27.0),
            LatLng(26.0, 27.0),
          ],
          // Example hole (Another small desert region)
          [
            LatLng(29.5, 30.5),
            LatLng(29.5, 31.0),
            LatLng(29.0, 31.0),
            LatLng(29.0, 30.5),
            LatLng(29.5, 30.5),
          ],
        ],
        polygonId: PolygonId("1"),
        strokeWidth: 1,
        fillColor: Colors.red.withOpacity(0.4),
        strokeColor: Colors.red,
        points: [
          LatLng(22.0, 25.0), // Southernmost point
          LatLng(22.0, 36.0), // Border with Sudan
          LatLng(31.6, 34.2), // Northeasternmost point
          LatLng(31.6, 25.0), // Northern Mediterranean coast
          LatLng(22.0, 25.0), // Closing the polygon
        ],
      ),
    );
  }

  void initCircles() {
    var abuTarekService = Circle(
      circleId: CircleId('1'),
      center: LatLng(30.050813333294727, 31.236416031407156),
      radius: 10000,
      fillColor: Colors.black.withOpacity(0.4),
    );
    circles.add(abuTarekService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            circles: circles,
            //polygons: polygons,
            //polylines: polyLines,
            zoomControlsEnabled: false,
            //markers: markers,
            initialCameraPosition: cameraPosition,
            onMapCreated: (controller) {
              googleMapController = controller;
            },
            // cameraTargetBounds: CameraTargetBounds(
            //   LatLngBounds(
            //     southwest: LatLng(29.210076859345147, 29.049608745944017),
            //     northeast: LatLng(31.113995218733333, 32.92004005957482),
            //   ),
            // ),
            style: mapStyleString,
          ),
          // Positioned(
          //   right: 16,
          //   left: 16,
          //   bottom: 0,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       googleMapController.animateCamera(
          //         CameraUpdate.newLatLng(
          //           LatLng(31.044480089759052, 31.38203597790498),
          //         ),
          //       );
          //     },
          //     child: Text("change Location"),
          //   ),
          // ),
        ],
      ),
    );
  }
}
