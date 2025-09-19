class Weather {
  final String city;
  final String country;
  final int temperature;
  final String description;
  final String icon;
  final String localtime;
  String note;

  Weather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.localtime,
    this.note = '',
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['location']['name'],
      country: json['location']['country'],
      temperature: json['current']['temperature'],
      description: json['current']['weather_descriptions'][0],
      icon: json['current']['weather_icons'][0],
      localtime: json['location']['localtime'],
    );
  }
}
