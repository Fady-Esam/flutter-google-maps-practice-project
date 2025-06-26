import 'package:apply_google_maps/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveLocationTracker extends StatefulWidget {
  const LiveLocationTracker({super.key});

  @override
  State<LiveLocationTracker> createState() => _LiveLocationTrackerState();
}

class _LiveLocationTrackerState extends State<LiveLocationTracker> {
  late CameraPosition cameraPosition;
  GoogleMapController? googleMapController;
  String? mapStyleString;
  late LocationService locationService;
  Set<Marker> markers = {};
  @override
  void initState() {
    super.initState();
    cameraPosition = CameraPosition(
      target: LatLng(30.037288986825594, 31.223923051707246),
      zoom: 13,
    );
    locationService = LocationService();
    updateLocationData();
    initMapStyle();
  }

  Future<void> getUserLocation() async {
    await locationService.getRealTimeLocationData((locData) async {
      LatLng userLocationData = LatLng(locData.latitude!, locData.longitude!);
      Marker userLocationMarker = Marker(
        markerId: MarkerId('1'),
        position: userLocationData,
      );
      setState(() {
        markers.add(userLocationMarker);
      });
      await googleMapController?.animateCamera(
        CameraUpdate.newLatLng(userLocationData),
      );
    });
  }

  void updateLocationData() async {
    if (await locationService.checkAndRequestForLocationService()) {
      if (await locationService.checkAndRequestForLocationPermission()) {
        await getUserLocation();
      }
    }
  }


  void initMapStyle() async {
    String style = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/google_map_styles/night_style.json');
    setState(() {
      mapStyleString = style;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        markers: markers,
        zoomControlsEnabled: false,
        initialCameraPosition: cameraPosition,
        onMapCreated: (controller) {
          googleMapController = controller;
        },
        style: mapStyleString,
      ),
    );
  }
}

// request for location service enablement
// request permission to use location
// get location
// display the location with marker tracker
