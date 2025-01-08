class Labour {
  final String? id;
  final String? name;
  String? details;
  final double rate;

  Labour({required this.rate, this.id, this.name, this.details});

  factory Labour.fromJson(Map<String, dynamic> json) {
    return Labour(
      id: json['id'] ?? '',
      name: json['type'] ?? '',
      details: json['description'] ?? '',
      rate: json['rate'] ?? 0.0,
    );
  }
}
