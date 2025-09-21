import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/Weather_model.dart';

class WeatherService {
  final String apiKey = "55ed8a6ec6554cf1ab902157252109";
  final String baseUrl = "http://api.weatherapi.com/v1";

  Map<String, String> favoriteCities = {};
  Map<String, String> cityNotes = {};
  Map<String, double> favoriteTemperatures = {};

  // GET
  Future<Weather> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse("$baseUrl/current.json?key=$apiKey&q=$city&aqi=no"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception("API Error");
    }
  }

  // PATCH
  Future<void> patchNote(String city, String note) async {
    cityNotes[city] = note;
  }

  // POST
  Future<Weather> addCity(String city) async {
    final response = await http.post(
      Uri.parse("$baseUrl/current.json?key=$apiKey&q=$city&aqi=no"),
      body: jsonEncode({"country": "New city has been created"}),
    );
    return fetchWeather(city);
  }

  // DELETE
  Future<Weather> deleteCity(String city) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/current.json?key=$apiKey&q=$city&aqi=no"),
    );
    return fetchWeather(city);
  }

  //  favorite
  void toggleFavorite(String city,double temp) {
    if (favoriteCities.containsKey(city)) {
      favoriteCities.remove(city);
      favoriteTemperatures.remove(city);
      cityNotes.remove(city);
    } else {
      favoriteCities[city] = "";
      favoriteTemperatures[city] = temp;
    }
  }
}
