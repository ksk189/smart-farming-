// permission_handler.dart

import 'package:permission_handler/permission_handler.dart';

class LocationPermissionHandler {
  // Request location permission
  Future<bool> requestLocationPermission() async {
    // Check if location permission is granted
    var status = await Permission.location.status;

    // Request permission if not granted
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      status = await Permission.location.request();
    }

    // Return true if permission is granted
    return status.isGranted;
  }

  // Check if location permission is permanently denied
  Future<bool> isLocationPermanentlyDenied() async {
    var status = await Permission.location.status;
    return status.isPermanentlyDenied;
  }

  // Open app settings if permission is permanently denied
  Future<void> openAppSettingsIfDenied() async {
    if (await isLocationPermanentlyDenied()) {
      await openAppSettings();
    }
  }
}