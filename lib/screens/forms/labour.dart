import 'package:flutter/material.dart';
import 'package:teafarm_pro/models/labour.dart';
import 'package:teafarm_pro/utils/api.dart';

class CreateLabourScreen extends StatefulWidget {
  const CreateLabourScreen({super.key, this.labour});
  final Labour? labour;

  @override
  State<CreateLabourScreen> createState() => _CreateLabourScreenState();
}

class _CreateLabourScreenState extends State<CreateLabourScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labourNameController;
  late TextEditingController _labourDetailsController;

  @override
  void initState() {
    super.initState();
    _labourNameController = TextEditingController();
    _labourDetailsController = TextEditingController();

    if (widget.labour != null) {
      _labourNameController.text = widget.labour!.name ?? '';
      _labourDetailsController.text = widget.labour!.details ?? '';
    }
  }

  @override
  void dispose() {
    _labourNameController.dispose();
    _labourDetailsController.dispose();
    super.dispose();
  }

  Future<APIResponse> saveLabour() async {
    if (widget.labour != null) {
      // Update existing labour
      return await APIService().saveLabour(
        id: widget.labour!.id,
        labourType: _labourNameController.text.trim(),
        description: _labourDetailsController.text.trim(),
      );
    } else {
      // Create new labour
      return await APIService().saveLabour(
        labourType: _labourNameController.text.trim(),
        description: _labourDetailsController.text.trim(),
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
