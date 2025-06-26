import 'package:apply_google_maps/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class RouteTracking extends StatefulWidget {
  const RouteTracking({super.key});

  @override
  State<RouteTracking> createState() => _RouteTrackingState();
}

class _RouteTrackingState extends State<RouteTracking> {
  late CameraPosition cameraPosition;
  late GoogleMapController googleMapController;
  String? mapStyleString;
  late LocationService locationService;
  @override
  void initState() {
    super.initState();
    cameraPosition = CameraPosition(target: LatLng(0, 0));
    locationService = LocationService();
  }

  @override
  void dispose() {
    super.dispose();
    googleMapController.dispose();
  }

  Future<void> getUserLocation() async {
    LocationData locData = await locationService.getCurrentLocationData();
    await googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(locData.latitude!, locData.longitude!), zoom: 13),
      ),
    );
  }

  void updateLocationData() async {
    if (await locationService.checkAndRequestForLocationService()) {
      if (await locationService.checkAndRequestForLocationPermission()) {
        await getUserLocation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        zoomControlsEnabled: false,
        initialCameraPosition: cameraPosition,
        onMapCreated: (controller) {
          googleMapController = controller;
          updateLocationData();
        },
      ),
    );
  }
}
