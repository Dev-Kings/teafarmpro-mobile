import 'package:flutter/material.dart';
import 'package:teafarm_pro/models/employee.dart';
import 'package:teafarm_pro/models/labour.dart';
import 'package:teafarm_pro/screens/forms/employee.dart';
import 'package:teafarm_pro/utils/api.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final List<Employee> employees = [];
  final List<Labour> labours = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    fetchLabours();
  }

  Future<void> fetchEmployees() async {
    final DataResponse response = await APIService().getEmployees();

    if (response.success) {
      setState(() {
        employees.clear();
        employees.addAll(response.data as List<Employee>);

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

  Future<void> fetchLabours() async {
    final DataResponse response = await APIService().getLabours();

    if (response.success) {
      setState(() {
        labours.clear();
        labours.addAll(response.data as List<Labour>);
      });
    } else {
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
        title: const Text('Employees'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeFormScreen(
                    labours: labours,
                  ),
                ),
              ).then((_) {
                fetchEmployees();
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
            : errorMessage.isNotEmpty || employees.isEmpty
                ? Center(
                    child: Text('No employees available.'),
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
                      rows: employees
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
                                            fetchEmployees();
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
                                employee.getLabourType(labours) ?? '',
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(
                                ActionChip(
                                  label: const Text('Edit'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EmployeeFormScreen(
                                          employee: employee,
                                          labours: labours,
                                        ),
                                      ),
                                    ).then((_) {
                                      fetchEmployees();
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
