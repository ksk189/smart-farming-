// models/home_data.dart

class HomeData {
  final List<Map<String, dynamic>> commodities;

  HomeData({required this.commodities});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      commodities: (json['commodities'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }
}