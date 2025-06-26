import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<bool> checkAndRequestForLocationService() async {
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  Future<bool> checkAndRequestForLocationPermission() async {
    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }
    return permissionGranted != PermissionStatus.denied &&
        permissionGranted != PermissionStatus.deniedForever;
  }

  Future<void> getRealTimeLocationData(void Function(LocationData)? onData) async {
    await location.changeSettings(distanceFilter: 5);
    location.onLocationChanged.listen(onData);
  }
  Future<LocationData> getCurrentLocationData()async{
    return await location.getLocation();
  }
}
