import 'package:flutter/material.dart';
import 'package:teafarm_pro/models/labour.dart';
import 'package:teafarm_pro/screens/forms/labour.dart';
import 'package:teafarm_pro/utils/api.dart';

class LabourScreen extends StatefulWidget {
  const LabourScreen({super.key});

  @override
  State<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends State<LabourScreen> {
  final List<Labour> labourTypes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchLabour();
  }

  Future<void> fetchLabour() async {
    final DataResponse response = await APIService().getLabours();

    if (response.success) {
      setState(() {
        labourTypes.clear();
        labourTypes.addAll(response.data as List<Labour>);

        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = response.message;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(response.message),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text('Labour Types'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to Create Labour Form
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateLabourScreen(),
                ),
              ).then((_) {
                fetchLabour();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text('No labour types available.'),
                  )
                : DataTable(
                    columnSpacing: 12,
                    border: TableBorder.all(),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    columns: const [
                      DataColumn(label: Text('Labour Type')),
                      DataColumn(label: Text('Details')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: labourTypes
                        .map(
                          (labour) => DataRow(cells: [
                            DataCell(
                              Text(labour.name ?? ''),
                              onLongPress: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Labour'),
                                  content: const Text(
                                      'Are you sure you want to delete this labour type?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final APIResponse response =
                                            await APIService()
                                                .deleteLabour(labour.id);

                                        if (response.success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(response.message),
                                            ),
                                          );
                                          fetchLabour();
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(response.message),
                                            ),
                                          );
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(Text(labour.details ?? '')),
                            DataCell(
                              ActionChip(
                                label: const Text('Edit'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateLabourScreen(
                                        labour: labour,
                                      ),
                                    ),
                                  ).then((_) {
                                    fetchLabour();
                                  });
                                },
                              ),
                            ),
                          ]),
                        )
                        .toList(),
                  ),
      ),
    );
  }
}
