import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPopup {
  /// Asks permission, grabs the device location, and has the employee
  /// confirm they are punching in on site. Returns true only if all
  /// steps succeed.
  static Future<bool> confirmOnSite(BuildContext context) async {
    // Step 1 — ask the employee before touching the device location
    final allow = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location check'),
        content: const Text(
            'To punch in we need your location to confirm you are on site. Allow?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Allow')),
        ],
      ),
    );
    if (allow != true) return false;

    try {
      // Step 2 — system-level permission (browser/phone popup)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return false;
      }

      // Step 3 — get position and confirm the punch
      final pos = await Geolocator.getCurrentPosition();
      if (!context.mounted) return false;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm punch in'),
          content: Text('Location captured:\n'
              'Lat ${pos.latitude.toStringAsFixed(5)}, '
              'Lng ${pos.longitude.toStringAsFixed(5)}\n\n'
              'Punch in now?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm')),
          ],
        ),
      );
      return confirmed == true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
      return false;
    }
  }
}
