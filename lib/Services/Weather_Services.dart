import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/weather_model.dart';

class WeatherService {
  final String apiKey = "73e275f2d88e6aa0d4abb6072082dac2";
  final String baseUrl = "http://api.weatherstack.com";

  Map<String, String> favoriteCities = {};
  Map<String, String> cityNotes = {};
  Map<String, int> favoriteTemperatures = {};

  // GET
  Future<Weather> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse("$baseUrl/current?access_key=$apiKey&query=$city"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception("API Error");
    }
  }

  // PATCH (add or update note)
  Future<void> patchNote(String city, String note) async {
    cityNotes[city] = note;
  }

  // POST (dummy example)
  Future<Weather> addCity(String city) async {
    final response = await http.post(
      Uri.parse("$baseUrl/current?access_key=$apiKey&query=$city"),
      body: jsonEncode({"country": "New city has been created"}),
    );
    return fetchWeather(city);
  }

  // DELETE (dummy example)
  Future<Weather> deleteCity(String city) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/current?access_key=$apiKey&query=$city"),
    );
    return fetchWeather(city);
  }

  // Toggle favorite
  void toggleFavorite(String city, int temp) {
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
