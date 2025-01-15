// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teafarm_pro/screens/forms/labour.dart';
import 'package:teafarm_pro/utils/api.dart';
import 'package:teafarm_pro/utils/data_provider.dart';

class LabourScreen extends StatelessWidget {
  const LabourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final labourProvider = Provider.of<DataProvider>(context);

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
                  builder: (context) => const LabourFormScreen(),
                ),
              ).then((_) => labourProvider.fetchLabours());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: labourProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : labourProvider.labours.isEmpty
                ? Center(
                    child: Text(
                      labourProvider.errorMessage.isNotEmpty
                          ? labourProvider.errorMessage
                          : 'No labour types found',
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 4,
                      border: TableBorder.all(),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      columns: const [
                        DataColumn(
                          label: Text('Labour Type'),
                        ),
                        DataColumn(
                          label: Text('Details'),
                        ),
                        DataColumn(
                          label: Text('Rate'),
                        ),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: labourProvider.labours
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
                                            labourProvider.fetchLabours();
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
                              DataCell(Text(labour.rate.toString())),
                              DataCell(
                                ActionChip(
                                  backgroundColor: Colors.green.shade200,
                                  label: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LabourFormScreen(
                                          labour: labour,
                                        ),
                                      ),
                                    ).then((_) {
                                      labourProvider.fetchLabours();
                                    });
                                  },
                                ),
                              ),
                            ]),
                          )
                          .toList(),
                    ),
                  ),
      ),
    );
  }
}
