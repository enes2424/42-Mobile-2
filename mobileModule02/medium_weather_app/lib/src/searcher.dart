import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'location.dart';

class Searcher {
  static Future<List<dynamic>> getSuggestions(
    BuildContext context,
    String query,
  ) async {
    try {
      final String geocodingUrl =
          'https://geocoding-api.open-meteo.com/v1/search?name=$query';

      final http.Response response;
      try {
        response = await http.get(Uri.parse(geocodingUrl));
      } catch (error) {
        return ["Error"];
      }

      if (response.statusCode != 200) {
        return ["Error"];
      }
      final data = jsonDecode(response.body);
      if (data['results'] == null) {
        return [];
      }
      List<dynamic> list = [];
      List<String> list2 = [];
      label:
      for (var suggestion in data['results']) {
        final city = suggestion['name'];
        String? region = suggestion['admin1'];
        String? country = suggestion['country'];

        if (city == region) {
          region = null;
        }
        if (city == country) {
          country = null;
        }

        String location = city ?? '';
        if (region != null) {
          location += (location.isNotEmpty ? ', ' : '') + region;
        }
        if (country != null) {
          location += (location.isNotEmpty ? ', ' : '') + country;
        }
        for (var elm in list2) {
          if (elm == location) {
            continue label;
          }
        }
        list2.add(location);
        suggestion["location"] = location;
        list.add(suggestion);
      }
      return list;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
      return [];
    }
  }

  static Future<Location?> getCoordinatesFromInput(
    BuildContext context,
    String input,
  ) async {
    input = input.toLowerCase();
    try {
      List<String> parts = input.split(',').map((part) => part.trim()).toList();

      String? cityName = parts[0];
      String? admin1 = parts.length > 1 ? parts[1] : null;
      String? country = parts.length > 2 ? parts[2] : null;

      if (cityName.isEmpty || parts.length > 3) {
        return null;
      }

      if (parts.length < 3) {
        String? latitude, longitude;
        if (parts.length == 2) {
          latitude = cityName;
          longitude = admin1;
        }
        try {
          double lat = double.parse(latitude!);
          double lon = double.parse(longitude!);

          if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
            return null;
          }
          return Location(lat, lon);
        } catch (error) {
          //continue
        }
      }

      String geocodingUrl =
          'https://geocoding-api.open-meteo.com/v1/search?name=$cityName';

      if (country != null && country.isNotEmpty) {
        geocodingUrl += '&country=$country';
      }
      if (admin1 != null && admin1.isNotEmpty) {
        geocodingUrl += '&admin1=$admin1';
      }
      final http.Response response;
      try {
        response = await http.get(Uri.parse(geocodingUrl));
      } catch (error) {
        return Location(-91, -181);
      }

      if (response.statusCode != 200) {
        return Location(-91, -181);
      }

      final data = jsonDecode(response.body);
      final results = data['results'];
      if (results == null || results.isEmpty) {
        return null;
      }
      for (var result in results) {
        if (result['name'].toString().toLowerCase() == cityName &&
            ((admin1 == null ||
                    admin1.isEmpty ||
                    result['admin1'] == null ||
                    result['admin1'].toString().toLowerCase() == admin1 ||
                    result['admin1'].toString().toLowerCase() == cityName) &&
                (country == null ||
                    country.isEmpty ||
                    result['country'] == null ||
                    result['country'].toString().toLowerCase() == country ||
                    result['country'].toString().toLowerCase() == admin1 ||
                    result['country'].toString().toLowerCase() == cityName))) {
          return Location(
            result['latitude'].toDouble(),
            result['longitude'].toDouble(),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    }
    return null;
  }
}
