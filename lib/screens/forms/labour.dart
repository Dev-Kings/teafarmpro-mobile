import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teafarm_pro/models/labour.dart';
import 'package:teafarm_pro/utils/api.dart';

class LabourFormScreen extends StatefulWidget {
  const LabourFormScreen({super.key, this.labour});
  final Labour? labour;

  @override
  State<LabourFormScreen> createState() => _LabourFormScreenState();
}

class _LabourFormScreenState extends State<LabourFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labourNameController;
  late TextEditingController _labourDetailsController;
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _labourNameController = TextEditingController();
    _labourDetailsController = TextEditingController();
    _rateController = TextEditingController();
    if (widget.labour != null) {
      _labourNameController.text = widget.labour!.name ?? '';
      _labourDetailsController.text = widget.labour!.details ?? '';
      _rateController.text = widget.labour!.rate.toString();
    }
  }

  @override
  void dispose() {
    _labourNameController.dispose();
    _labourDetailsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<APIResponse> saveLabour() async {
    if (widget.labour != null) {
      // Update existing labour
      return await APIService().saveLabour(
        id: widget.labour!.id,
        labourType: _labourNameController.text.trim(),
        description: _labourDetailsController.text.trim(),
        rate: double.parse(_rateController.text.trim()),
      );
    } else {
      // Create new labour
      return await APIService().saveLabour(
        labourType: _labourNameController.text.trim(),
        description: _labourDetailsController.text.trim(),
        rate: double.parse(_rateController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.labour == null ? 'Create Labour' : 'Edit Labour',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _labourNameController,
                decoration: const InputDecoration(
                  labelText: 'Labour Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the labour name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _labourDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Labour Details',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the labour details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _rateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // show loading indicator
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                    final response = await saveLabour();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            response.success ? Colors.green : Colors.red,
                        content: Text(response.message),
                      ),
                    );
                    if (response.success) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
