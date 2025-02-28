import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'location.dart';
import 'dart:convert';
import 'utils.dart';

class FillTheViews {
  static late Future<List<Widget>?> _locationInfo;
  static late Future<List<Widget>?> currentlyViewInfo;
  static late Future<List<Widget>?> todayViewInfo;
  static late Future<List<Widget>?> weeklyViewInfo;
  static final Map<int, String> _weatherDescriptions = {
    0: 'Clear sky',
    1: 'Mainly clear',
    2: 'Partly cloudy',
    3: 'Overcast',
    45: 'Fog',
    48: 'Depositing rime fog',
    51: 'Light drizzle',
    53: 'Moderate drizzle',
    55: 'Dense drizzle',
    56: 'Freezing light drizzle',
    57: 'Freezing dense drizzle',
    61: 'Slight rain',
    63: 'Moderate rain',
    65: 'Heavy rain',
    66: 'Freezing light rain',
    67: 'Freezing heavy rain',
    71: 'Slight snow fall',
    73: 'Moderate snow fall',
    75: 'Heavy snow fall',
    77: 'Snow grains',
    80: 'Slight rain showers',
    81: 'Moderate rain showers',
    82: 'Violent rain showers',
    85: 'Slight snow showers',
    86: 'Heavy snow showers',
    95: 'Thunderstorm',
    96: 'Thunderstorm with slight hail',
    99: 'Thunderstorm with heavy hail',
  };

  static void init(BuildContext context, double? width, Location? location) {
    if (context.mounted) {
      _locationInfo = _getLocationInfo(context, width, location);
      currentlyViewInfo = _getCurrentlyViewInfo(context, width, location);
      todayViewInfo = _getTodayViewInfo(context, width, location);
      weeklyViewInfo = _getWeeklyViewINfo(context, width, location);
    }
  }

  static Future<List<Widget>?> _getLocationInfo(
    BuildContext context,
    double? width,
    Location? location,
  ) async {
    if (location == null) {
      return [];
    }
    try {
      List<Widget> listLocationInfo = [];

      final String geoUrl =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&accept-language=en';

      final http.Response geoResponse;
      try {
        geoResponse = await http.get(
          Uri.parse(geoUrl),
          headers: {'User-Agent': 'Mozilla/5.0 (compatible; MyFlutterApp/1.0)'},
        );
      } catch (error) {
        return null;
      }

      if (geoResponse.statusCode != 200) {
        return null;
      }
      while (width == null) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      final geoData = jsonDecode(geoResponse.body);
      if (geoData["address"] == null) {
        return [
          Utils.layoutBuilder(
            width,
            "Unknown location (${location.latitude}, ${location.longitude})",
            25,
            null,
          ),
        ];
      }

      String? city =
          geoData["address"]["city"] ??
          geoData["address"]["town"] ??
          geoData["address"]["village"];
      String? state =
          geoData["address"]["state"] ?? geoData["address"]["province"];
      if (state == city) {
        state = null;
      }
      String? country = geoData["address"]["country"];

      if (city != null && city.isNotEmpty) {
        listLocationInfo.add(Utils.layoutBuilder(width, city, 25, null));
      }
      if (state != null && state.isNotEmpty) {
        listLocationInfo.add(Utils.layoutBuilder(width, state, 25, null));
      }
      if (country != null && country.isNotEmpty) {
        listLocationInfo.add(Utils.layoutBuilder(width, country, 25, null));
      }

      if (listLocationInfo.isEmpty) {
        return [
          Utils.layoutBuilder(
            width,
            "Unknown location (${location.latitude}, ${location.longitude})",
            25,
            null,
          ),
        ];
      }

      return listLocationInfo;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
      return [];
    }
  }

  static Future<List<Widget>> getTotalInfo(
    BuildContext context,
    double width,
    Location? location,
    Future<List<Widget>?> weatherInfo,
  ) async {
    var info = await _locationInfo;
    if (info == null) {
      return [Text("Error")];
    }
    List<Widget> totalInfo = [...info];
    info = await weatherInfo;
    if (info == null) {
      return [Text("Error")];
    }
    totalInfo.addAll(info);
    return totalInfo;
  }

  static Future<List<Widget>?> _getCurrentlyViewInfo(
    BuildContext context,
    double? width,
    Location? location,
  ) async {
    try {
      List<Widget> currentlyViewInfo = [];
      int ctrl = 0;
      while (location == null) {
        if (ctrl++ == 10) {
          return [];
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
      final String url =
          'https://api.open-meteo.com/v1/forecast?latitude=${location.latitude}&longitude=${location.longitude}&current_weather=true';

      final http.Response response;
      try {
        response = await http.get(Uri.parse(url));
      } catch (error) {
        return null;
      }

      if (response.statusCode != 200) {
        return null;
      }

      while (width == null) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      Map<String, dynamic> weather = json.decode(response.body);
      currentlyViewInfo.add(
        Utils.layoutBuilder(
          width,
          "${weather["current_weather"]["temperature"]}°C",
          25,
          null,
        ),
      );
      currentlyViewInfo.add(
        Utils.layoutBuilder(
          width,
          _weatherDescriptions[weather["current_weather"]["weathercode"]] ??
              'Unknown weather condition',
          25,
          null,
        ),
      );
      currentlyViewInfo.add(
        Utils.layoutBuilder(
          width,
          "${weather["current_weather"]["windspeed"]} km/h",
          25,
          null,
        ),
      );
      return currentlyViewInfo;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
      return [];
    }
  }

  static Future<List<Widget>?> _getTodayViewInfo(
    BuildContext context,
    double? width,
    Location? location,
  ) async {
    try {
      List<Widget> todayViewInfo = [];
      int ctrl = 0;
      while (location == null) {
        if (ctrl++ == 10) {
          return [];
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
      final String url =
          'https://api.open-meteo.com/v1/forecast?latitude=${location.latitude}&longitude=${location.longitude}&hourly=temperature_2m,windspeed_10m,weathercode&timezone=auto';

      final http.Response response;
      try {
        response = await http.get(Uri.parse(url));
      } catch (error) {
        return null;
      }

      if (response.statusCode != 200) {
        return null;
      }

      while (width == null) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      String hour;
      String temperature;
      String weatherDescription;
      String windspeed;
      Map<String, dynamic> weather = json.decode(response.body);

      for (int number = 0; number < 24; number++) {
        hour = " ${number.toString().padLeft(2, '0')}:00 ";
        temperature = " ${weather['hourly']['temperature_2m'][number]}°C ";
        weatherDescription =
            " ${_weatherDescriptions[weather["hourly"]["weathercode"][number]] ?? 'Unknown weather condition'} ";
        windspeed = " ${weather['hourly']['windspeed_10m'][number]} km/h ";

        todayViewInfo.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Utils.layoutBuilder(width / 4, hour, 15, null)),
              Expanded(
                child: Utils.layoutBuilder(width / 4, temperature, 15, null),
              ),
              Expanded(
                child: Utils.layoutBuilder(
                  width / 4,
                  weatherDescription,
                  15,
                  null,
                ),
              ),
              Expanded(
                child: Utils.layoutBuilder(width / 4, windspeed, 15, null),
              ),
            ],
          ),
        );
      }
      return todayViewInfo;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
      return [];
    }
  }

  static Future<List<Widget>?> _getWeeklyViewINfo(
    BuildContext context,
    double? width,
    Location? location,
  ) async {
    try {
      List<Widget> weeklyViewInfo = [];
      int ctrl = 0;
      while (location == null) {
        if (ctrl++ == 10) {
          return [];
        }
        await Future.delayed(Duration(milliseconds: 100));
      }
      final String url =
          'https://api.open-meteo.com/v1/forecast?latitude=${location.latitude}&longitude=${location.longitude}&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto';

      final http.Response response;
      try {
        response = await http.get(Uri.parse(url));
      } catch (error) {
        return null;
      }

      if (response.statusCode != 200) {
        return null;
      }

      while (width == null) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      String date;
      String maxTemp;
      String minTemp;
      String weatherDescription;
      Map<String, dynamic> weather = json.decode(response.body);

      for (int number = 0; number < 7; number++) {
        date = " ${weather['daily']['time'][number]} ";
        maxTemp = " ${weather['daily']['temperature_2m_max'][number]}°C ";
        minTemp = " ${weather['daily']['temperature_2m_min'][number]}°C ";
        weatherDescription =
            " ${_weatherDescriptions[weather["daily"]["weathercode"][number]] ?? 'Unknown weather condition'} ";

        weeklyViewInfo.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Utils.layoutBuilder(width / 4, date, 15, null)),
              Expanded(
                child: Utils.layoutBuilder(width / 4, minTemp, 15, null),
              ),
              Expanded(
                child: Utils.layoutBuilder(width / 4, maxTemp, 15, null),
              ),
              Expanded(
                child: Utils.layoutBuilder(
                  width / 4,
                  weatherDescription,
                  15,
                  null,
                ),
              ),
            ],
          ),
        );
      }
      return weeklyViewInfo;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
      return [];
    }
  }
}
