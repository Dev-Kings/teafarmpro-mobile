import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teafarm_pro/models/employee.dart';
import 'package:teafarm_pro/models/labour.dart';
import 'package:teafarm_pro/utils/api.dart';

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key, this.employee, required this.labours});
  final Employee? employee;
  final List<Labour?> labours; // Assume labours are populated elsewhere

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String labourId = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _emailController.text = widget.employee!.email ?? '';
      _phoneController.text = widget.employee!.phoneNumber;
      labourId = widget.employee!.labourId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await saveLabour();
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

  Future<APIResponse> saveLabour() async {
    return await APIService().saveEmployee(
      id: widget.employee?.id,
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      labourId: labourId,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      validator: validator,
    );
  }

  String? validateEmail(String? value) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$');
    if (value!.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.employee == null ? 'Create Employee' : 'Edit Employee'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Employee Name',
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the employee name'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Employee Phone',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
                ],
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the employee phone'
                    : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Employee Email',
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the employee email';
                  }
                  return validateEmail(value);
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: labourId.isEmpty ? null : labourId,
                onChanged: (value) => setState(() {
                  labourId = value.toString();
                }),
                items: widget.labours
                    .map(
                      (labour) => DropdownMenuItem(
                        value: labour?.id,
                        child: Text(labour?.name ?? 'Unknown'),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Labour Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select the labour type'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
