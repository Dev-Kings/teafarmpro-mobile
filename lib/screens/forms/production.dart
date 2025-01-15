// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teafarm_pro/models/employee.dart';
import 'package:teafarm_pro/models/labour.dart';
import 'package:teafarm_pro/models/production.dart';
import 'package:teafarm_pro/utils/api.dart';

class ProductionFormScreen extends StatefulWidget {
  const ProductionFormScreen(
      {super.key,
      required this.employees,
      required this.labours,
      this.production});
  final List<Employee?> employees;
  final List<Labour?> labours;
  final Production? production;

  @override
  State<ProductionFormScreen> createState() => _ProductionFormScreenState();
}

class _ProductionFormScreenState extends State<ProductionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _rateController;
  late TextEditingController _dateController;

  String labourId = '';
  String employeeId = '';

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _rateController = TextEditingController();
    _dateController = TextEditingController();

    if (widget.production != null) {
      _weightController.text = widget.production!.weight.toString();
      _rateController.text = widget.production!.rate.toString();
      _dateController.text = widget.production!.date;
      employeeId = widget.production!.employeeId;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _rateController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _handleDateSelection(BuildContext context) async {
    // Disable future dates
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.production != null
          ? DateTime.parse(widget.production!.date)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await saveProduction();
    Navigator.pop(context); // Close loading indicator

    // Show response message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: response.success ? Colors.green : Colors.red,
        content: Text(response.message),
      ),
    );

    if (response.success) {
      Navigator.pop(context); // Close the form
    }
  }

  Future<APIResponse> saveProduction() async {
    return await APIService().saveProductionData(
      id: widget.production?.id,
      employeeId: employeeId,
      rate: double.tryParse(_rateController.text),
      weight: double.parse(_weightController.text),
      date: _dateController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: Text(
            widget.production == null ? 'Add Production' : 'Edit Production'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<Employee?>(
                decoration: const InputDecoration(labelText: 'Employee'),
                value: widget.production == null
                    ? null
                    : widget.employees.firstWhere(
                        (emp) => emp!.id == widget.production!.employeeId),
                items: widget.employees
                    .map((emp) => DropdownMenuItem<Employee?>(
                          value: emp,
                          child: Text(emp!.name),
                        ))
                    .toList(),
                validator: (value) =>
                    value == null ? 'Employee is required' : null,
                onChanged: (value) {
                  employeeId = value!.id;
                },
              ),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(labelText: 'Rate (Optional)'),
                validator: (value) => value != null &&
                        value.isNotEmpty &&
                        (double.tryParse(value) == null ||
                            double.tryParse(value)! <= 0.0)
                    ? 'Please enter valid rate'
                    : null,
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kgs)'),
                validator: (value) => value == null ||
                        value.isEmpty ||
                        double.tryParse(value) == null ||
                        double.parse(value) <= 0.0
                    ? 'Please enter valid weight'
                    : null,
              ),
              GestureDetector(
                onTap: () => _handleDateSelection(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Date is required'
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(widget.production == null ? 'Add' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
