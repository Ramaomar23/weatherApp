class Weather {
  final String city;
  final String country;
  final double temperature;
  final String description;
  final String localtime;
  final String icon;

  Weather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.description,
    required this.localtime,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['location']['name'],
      country: json['location']['country'],
      temperature: json['current']['temp_c'].toDouble(),
      description: json['current']['condition']['text'],
      icon: "https:${json['current']['condition']['icon']}",
      localtime: json['location']['localtime'],
    );
  }
}
