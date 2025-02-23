import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'permission.dart';

class WhereAreWe {
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    try {
      if (!(await Permission.obtainPermission(context))) {
        return null;
      }
      return await Geolocator.getCurrentPosition();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }
}
