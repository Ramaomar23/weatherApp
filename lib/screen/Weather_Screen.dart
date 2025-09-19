import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Model/Weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerNote = TextEditingController();

  String city = "mman";
  String _result = "";
  Map<String, String> favoriteCities = {};
  Map<String, String> cityNotes = {};
  Map<String, int> favoriteTemperatures = {};
  late Future<Weather> weatherFuture;

  @override
  void initState() {
    super.initState();
    weatherFuture = fetchWeather();
  }

  Future<Weather> fetchWeather() async {
    const apiKey = "73e275f2d88e6aa0d4abb6072082dac2";
    final response = await http.get(
      Uri.parse("http://api.weatherstack.com/current?access_key=$apiKey&query=$city"),
    );
    print("API response: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["error"] != null) {
        throw Exception(data["error"]["info"]);
      }

      return Weather.fromJson(data);
    } else {
      throw Exception("API Error");
    }
  }

  void _citySearch() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        city = _controller.text;
        weatherFuture = fetchWeather();
        _result = "Searching for $city...";
      });
    }
  }

  void _toggleFavorite(String cityName, int temp) {
    setState(() {
      if (favoriteCities.containsKey(cityName)) {
        favoriteCities.remove(cityName);
        favoriteTemperatures.remove(cityName);
        cityNotes.remove(cityName);
      } else {
        favoriteCities[cityName] = "";
        favoriteTemperatures[cityName] = temp;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFcaf0f8), Color(0xFF0077b6)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Weather",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Enter City Name",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onSubmitted: (_) => _citySearch(),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(_result),
              Expanded(
                child: Center(
                  child: FutureBuilder<Weather>(
                    future: weatherFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData) {
                        return const Text("No data");
                      } else {
                        final weather = snapshot.data!;
                        final isfav = favoriteCities.containsKey(weather.city);

                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // بطاقة الطقس الحالية
                              Container(
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.symmetric(horizontal: 30),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              weather.city,
                                              style: const TextStyle(
                                                  fontSize: 30, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 5),
                                            IconButton(
                                              onPressed: () => _toggleFavorite(
                                                  weather.city, weather.temperature),
                                              icon: Icon(
                                                isfav ? Icons.favorite : Icons.favorite_border,
                                                color: isfav ? Colors.red : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Text("${weather.temperature}°C",
                                            style: const TextStyle(
                                                fontSize: 30, fontWeight: FontWeight.bold)),
                                        Text("${weather.country} • ${weather.localtime}",
                                            style: const TextStyle(
                                                fontSize: 15, color: Colors.black54)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Image.network(weather.icon, width: 70, height: 70),
                                        const SizedBox(height: 40),
                                        Text(weather.description,
                                            style: const TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                               //........................Favorite..................................
                                Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                                  child: Text(
                                    "Favorite Cities:",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),

                              for (var fav in favoriteCities.keys)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 4),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fav,
                                        style: const TextStyle(
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 7,),
                                      Text("${favoriteTemperatures[fav]}°C",
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(height: 9,),
                                      Text(cityNotes[fav ]?? "No note yet",style:  TextStyle(
                                          color: Colors.grey[700],fontSize: 20)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _controllerNote.text =
                                                  cityNotes[fav] ?? "";
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor: Colors.white,
                                                    title: Text("Edit Note for $fav"),
                                                    content: TextField(
                                                        controller: _controllerNote),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            cityNotes[fav] =
                                                                _controllerNote.text;
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text("Save"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                favoriteCities.remove(fav);
                                                cityNotes.remove(fav);
                                                favoriteTemperatures.remove(fav);
                                              });
                                            },
                                            icon: const Icon(Icons.delete_outline,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height:25),
                      //............................Note...............................
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 17.0),
                                    child: Text(
                                      "Notes:",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _controllerNote,
                                    decoration: InputDecoration(
                                      hintText: "Enter your note here",
                                      prefixIcon: Icon(Icons.note, color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(55),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                   Center(
                                     child:ElevatedButton(
                                     onPressed: () {
                                       setState(() {
                                         if (favoriteCities.isNotEmpty) {
                                           String firstFavCity = favoriteCities.keys.first;
                                           cityNotes[firstFavCity] = _controllerNote.text;
                                         }
                                       });
                                       showModalBottomSheet(
                                         context: context,
                                         builder: (context) {
                                           return Container(
                                             height: 50,
                                             decoration: const BoxDecoration(
                                               color: Colors.grey,
                                               borderRadius: BorderRadius.only(
                                                 topRight: Radius.circular(20),
                                                 topLeft: Radius.circular(20),
                                               ),
                                             ),
                                             child: Center(
                                               child: Text(
                                                 "Your note has been added: ${_controllerNote.text}",
                                                 textAlign: TextAlign.center,
                                                 style: TextStyle(
                                                 ),
                                               ),
                                             ),
                                           );
                                         },
                                       );
                                     },
                                     child: const Text("Add Note"),
                                   ),
                                   ),

                                  const SizedBox(height: 15),
                                ],
                              ),
                              SizedBox(height: 15),
                            ],
                          ),
                        );
                      }
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        );
    }
}

