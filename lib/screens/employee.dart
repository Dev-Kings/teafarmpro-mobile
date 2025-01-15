// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teafarm_pro/screens/forms/employee.dart';
import 'package:teafarm_pro/utils/api.dart';
import 'package:teafarm_pro/utils/data_provider.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text('Employees'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeFormScreen(
                    labours: dataProvider.labours,
                  ),
                ),
              ).then((_) {
                dataProvider.fetchEmployees();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: dataProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : dataProvider.employees.isEmpty
                ? Center(
                    child: Text(
                      dataProvider.errorMessage.isNotEmpty
                          ? dataProvider.errorMessage
                          : 'No employees found',
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
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Phone Number')),
                        DataColumn(label: Text('Labour Type')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: dataProvider.employees
                          .map(
                            (employee) => DataRow(cells: [
                              DataCell(
                                Text(
                                  employee.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onLongPress: () => showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Employee'),
                                    content: const Text(
                                        'Are you sure you want to delete this employee?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final APIResponse response =
                                              await APIService()
                                                  .deleteEmployee(employee.id);

                                          if (response.success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.green,
                                                content: Text(response.message),
                                              ),
                                            );
                                            dataProvider.fetchEmployees();
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
                              DataCell(Text(
                                employee.phoneNumber,
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(Text(
                                employee.getLabourType(dataProvider.labours) ??
                                    '',
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(
                                ActionChip(
                                  backgroundColor: Colors.green.shade200,
                                  label: Icon(
                                    Icons.edit,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EmployeeFormScreen(
                                          employee: employee,
                                          labours: dataProvider.labours,
                                        ),
                                      ),
                                    ).then((_) {
                                      dataProvider.fetchEmployees();
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
