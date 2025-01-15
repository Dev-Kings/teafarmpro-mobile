import 'package:teafarm_pro/models/employee.dart';
import 'package:teafarm_pro/models/labour.dart';

class Production {
  final String id;
  final String employeeId;
  final double rate;
  final double weight;
  final double? amountPaid;
  final String date;

  Production({
    required this.id,
    required this.employeeId,
    required this.rate,
    required this.weight,
    this.amountPaid,
    required this.date,
  });

  factory Production.fromJson(Map<String, dynamic> json) => Production(
        id: json['id'],
        employeeId: json['employee_id'],
        rate: json['rate'],
        weight: json['weight'],
        amountPaid: json['amount_paid'],
        date: json['date'],
      );

  Employee _findEmployee(List<Employee> employeeList) =>
      employeeList.firstWhere(
        (emp) => emp.id == employeeId,
        orElse: () => Employee(
          id: 'unknown',
          name: 'Unknown',
          phoneNumber: '',
          email: '',
          password: '',
          labourId: '',
        ),
      );

  String getEmployeeName(List<Employee> employeeList) =>
      _findEmployee(employeeList).name;

  String? getLabourType(List<Employee> employeeList, List<Labour> labourList) =>
      _findEmployee(employeeList).getLabourType(labourList);
}
