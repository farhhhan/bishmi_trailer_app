import 'package:flutter/material.dart';
import 'package:bishmi_app/core/hive_model/company_model.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailsScreen({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.amber.shade100,
                      child: Text(employee.name[0]),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          employee.position,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Uniform items table
              const Text(
                'Uniform Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Table view
              Table(
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                },
                children: [
                  // Table header
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    children: [
                      _buildHeaderCell('Uniform Item'),
                      _buildHeaderCell('Type'),
                      _buildHeaderCell('Details'),
                    ],
                  ),

                  // Table rows for each uniform item
                  ...employee.uniformConfig
                      .where((c) => c.isNeeded)
                      .map((config) {
                    return TableRow(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      children: [
                        _buildDataCell(config.itemName),
                        _buildDataCell(
                            config.isReadyMade ? 'Ready Made' : 'Tailored'),
                        _buildDataCell(config.isReadyMade
                            ? 'Size: ${config.selectedSize ?? 'N/A'}'
                            : _buildMeasurementsText(config.measurements)),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget buildDataCell(Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: widget,
    );
  }

  String _buildMeasurementsText(Map<String, String> measurements) {
    if (measurements.isEmpty) return 'No measurements';

    return measurements.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
