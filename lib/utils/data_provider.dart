import 'package:flutter/material.dart';
import 'package:teafarm_pro/models/employee.dart';
import 'package:teafarm_pro/models/labour.dart';
import 'package:teafarm_pro/models/production.dart';
import 'package:teafarm_pro/utils/api.dart';

class DataProvider with ChangeNotifier {
  List<Employee> _employees = [];
  List<Labour> _labours = [];
  List<Production> _productions = [];

  List<Employee> get employees => _employees;
  List<Labour> get labours => _labours;
  List<Production> get productions => _productions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await fetchEmployees();
      await fetchLabours();
      await fetchProductions();

      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _employees = [];
    _labours = [];
    _productions = [];
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await APIService().getEmployees();
      if (response.success) {
        _employees = List<Employee>.from(response.data);
      } else {
        _errorMessage = 'Failed to fetch employees';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLabours() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await APIService().getLabours();
      if (response.success) {
        _labours = List<Labour>.from(response.data);
      } else {
        _errorMessage = 'Failed to fetch labours';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await APIService().getProductions();

      if (response.success) {
        _productions = List<Production>.from(response.data);
      } else {
        _errorMessage = 'Failed to fetch productions';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
