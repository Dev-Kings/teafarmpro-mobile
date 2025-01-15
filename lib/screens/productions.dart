// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teafarm_pro/screens/forms/production.dart';
import 'package:teafarm_pro/utils/api.dart';
import 'package:teafarm_pro/utils/data_provider.dart';

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: const Text('Productions'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductionFormScreen(
                    employees: dataProvider.employees,
                    labours: dataProvider.labours,
                  ),
                ),
              ).then((_) {
                dataProvider.fetchProductions();
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
            : dataProvider.productions.isEmpty
                ? Center(
                    child: Text(
                      dataProvider.errorMessage.isNotEmpty
                          ? dataProvider.errorMessage
                          : 'No productions found',
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
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Employee')),
                        DataColumn(label: Text('Labour')),
                        DataColumn(label: Text('Weight\n(kgs)')),
                        DataColumn(label: Text('Rate')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: dataProvider.productions
                          .map(
                            (production) => DataRow(
                              cells: [
                                DataCell(Text(production.date)),
                                DataCell(
                                  Text(
                                    production.getEmployeeName(
                                            dataProvider.employees),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    production.getLabourType(
                                            dataProvider.employees,
                                            dataProvider.labours) ??
                                        '',
                                  ),
                                ),
                                DataCell(Text(production.weight.toString())),
                                DataCell(Text(production.rate.toString())),
                                DataCell(
                                    Text(production.amountPaid.toString())),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductionFormScreen(
                                                production: production,
                                                employees:
                                                    dataProvider.employees,
                                                labours: dataProvider.labours,
                                              ),
                                            ),
                                          ).then((_) {
                                            dataProvider.fetchProductions();
                                          });
                                        },
                                        icon: const Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Delete'),
                                                content: const Text(
                                                    'Are you sure you want to delete this production?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      final response =
                                                          await APIService()
                                                              .deleteProduction(
                                                                  production
                                                                      .id);
                                                      if (response.success) {
                                                        dataProvider
                                                            .fetchProductions();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                response
                                                                    .message),
                                                          ),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                response
                                                                    .message),
                                                          ),
                                                        );
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Yes'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
      ),
    );
  }
}
