/********************************************************************
* TITLE: Location Popup — On-Site Punch Verification
* FILENAME: Locationpopup.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   The name of the job site the employee is punching into
*           (locationId, like "Premier Office").
* OUTPUTS:  true ONLY if: permission granted + real GPS fix + the
*           employee is within the allowed distance of the site +
*           they tap Confirm. Anything else = false, punch blocked.
* DESCRIPTION: The old version showed the GPS numbers and approved
*           no matter where you stood. This version downloads the
*           site's saved coordinates from our server, measures how
*           far away the employee is, and refuses the punch if they
*           are too far (or faking their location).
* NOTES:    Needs geolocator and http. The site must have lat/lng
*           saved in the database or the punch is blocked (flip
*           allowIfSiteUnknown to change that). If your geolocator
*           version complains about LocationSettings, tell me and
*           I'll give you the older syntax.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* For TimeoutException — what gets thrown if GPS takes too long. */
import 'dart:async';

/* Translates the server's JSON text into Dart lists and maps. */
import 'dart:convert';

/* Flutter's standard UI toolkit (dialogs, snackbars). */
import 'package:flutter/material.dart';

/* The GPS package — permissions, position, and distance math. */
import 'package:geolocator/geolocator.dart';

/* How we talk to our server. */
import 'package:http/http.dart' as http;

/* Our server address (baseUrl) lives in here. */
import '../shift_model.dart';

/********************************************************************************/
/* THE CLASS — one static method the punch page calls                           */
/********************************************************************************/

class LocationPopup {
  /* How close (in meters) the employee must be to the site.
     150 m is about a block and a half. */
  static const double radiusMeters = 150;

  /* If a site has no coordinates saved in the database, do we let
     the punch through anyway? false = blocked (the safe choice). */
  static const bool allowIfSiteUnknown = false;

/********************************************************************************/
/* MAIN FLOW — ask, locate, VERIFY, then confirm                                */
/********************************************************************************/

  /* Returns true only if every step passes. The punch page should
     only send the punch to the server when this comes back true. */
  static Future<bool> confirmOnSite(
    BuildContext context, {
    required String locationId,
  }) async {
    /* STEP 1 — be polite: ask in-app before touching the GPS. */
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

    /* Tapped No, or closed the dialog → stop right here. */
    if (allow != true) return false;

    try {
      /* STEP 2 — the system-level permission (the phone/browser popup). */
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      /* Flipped from the old version: instead of listing the BAD
         answers, we only accept the two GOOD ones. Anything else
         (denied, denied forever, undetermined, dismissed popup)
         falls through to "blocked". */
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return false;
      }

      /* STEP 3 — demand a FRESH, high-accuracy GPS fix. The old code
         took whatever the device had lying around, which could be an
         old cached position. 20 second limit so we don't hang forever. */
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!context.mounted) return false;

      /* STEP 3.5 — fake GPS check. On Android, "mock location" apps
         get flagged here. No spoofing a punch from the couch. */
      if (pos.isMocked) {
        await _blockDialog(context, 'Fake location detected',
            'Your device is reporting a mock GPS position. Turn off any fake-location apps and try again.');
        return false;
      }

/********************************************************************************/
/* STEP 4 — THE ACTUAL VERIFY: are they really at the site?                     */
/********************************************************************************/

      /* Ask our server for this site's saved coordinates. */
      final site = await _fetchSite(locationId);
      if (!context.mounted) return false;

      double? distance;

      if (site == null) {
        /* Site has no coordinates in the database → we cannot verify. */
        if (!allowIfSiteUnknown) {
          await _blockDialog(context, 'Cannot verify location',
              '"$locationId" has no GPS coordinates saved in the system. Ask a manager to add them.');
          return false;
        }
      } else {
        /* Straight-line distance (in meters) between the employee
           and the site. The geolocator package does the math. */
        distance = Geolocator.distanceBetween(
            pos.latitude, pos.longitude, site['lat']!, site['lng']!);

        /* Give a little slack for GPS error: allowed radius + however
           fuzzy the device says this reading is. */
        final double allowed = radiusMeters + pos.accuracy;

        /* TOO FAR → blocked. This is the line that stops the
           "approves no matter what" problem. */
        if (distance > allowed) {
          await _blockDialog(
              context,
              'Too far from $locationId',
              'You are about ${distance.round()} m '
                  '(${(distance * 3.28084).round()} ft) away from the site. '
                  'You must be on site to punch in.');
          return false;
        }
      }

/********************************************************************************/
/* STEP 5 — passed the check, last human confirmation                           */
/********************************************************************************/

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm punch in'),
          content: Text(distance == null
              ? 'Location captured. Punch in at $locationId now?'
              : 'You are on site at $locationId '
                  '(about ${distance.round()} m from the entrance pin).\n\n'
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

      /* Only an actual tap on Confirm counts. */
      return confirmed == true;
    } on TimeoutException {
      /* GPS took longer than 20 seconds. */
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('GPS took too long — step outside and retry')),
        );
      }
      return false;
    } catch (e) {
      /* Anything else went wrong (no signal, GPS off, etc.). */
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
      return false;
    }
  }

/********************************************************************************/
/* HELPERS — fetching the site + the "you're blocked" dialog                    */
/********************************************************************************/

  /* Downloads all locations from the server and picks out the one
     matching this name. Returns null if it's missing or has no
     coordinates saved. */
  static Future<Map<String, double>?> _fetchSite(String name) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/getLocations'));
      if (res.statusCode != 200) return null;

      final List<dynamic> all = jsonDecode(res.body);
      for (final loc in all) {
        if (loc['name'] == name && loc['lat'] != null && loc['lng'] != null) {
          return {
            'lat': (loc['lat'] as num).toDouble(),
            'lng': (loc['lng'] as num).toDouble(),
          };
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /* A one-button dialog that explains WHY the punch was refused. */
  static Future<void> _blockDialog(
      BuildContext context, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}
