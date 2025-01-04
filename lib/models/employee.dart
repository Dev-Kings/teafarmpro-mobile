import 'package:teafarm_pro/models/labour.dart';

class Employee {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? password;
  final String labourId;

  Employee({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.labourId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      labourId: json['labour_id'],
    );
  }

  String? getLabourType(List<Labour> labourList) {
    final labour = labourList.firstWhere(
      (labour) => labour.id == labourId,
      orElse: () => Labour(id: 'unknown', name: 'Unknown'),
    );
    return labour.name;
  }
}
