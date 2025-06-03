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
              _buildEmployeeHeader(),
              const SizedBox(height: 24),

              // Uniform items table
              _buildUniformConfigurationSection(),
              const SizedBox(height: 24),

              // Feedback section
              if (employee.feedBack != null && employee.feedBack!.isNotEmpty)
                _buildFeedbackSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.amber.shade100,
            child: Text(
              employee.name[0],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  employee.position,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      employee.gender == 'Male' ? Icons.male : Icons.female,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      employee.gender,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniformConfigurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uniform Configuration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Table(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.5), // Uniform Item
              1: FlexColumnWidth(1.5), // Type & Material
              2: FlexColumnWidth(2), // Details
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
                  _buildHeaderCell('Type & Material'),
                  _buildHeaderCell('Details'),
                ],
              ),

              // Table rows for each uniform item
              ...employee.uniformConfig.where((c) => c.isNeeded).map((config) {
                return TableRow(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  children: [
                    _buildDataCell(config.itemName),
                    _buildTypeAndMaterialCell(config),
                    _buildDetailsCell(config),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Employee Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            employee.feedBack!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTypeAndMaterialCell(UniformItemConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: config.isReadyMade
                  ? Colors.blue.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: config.isReadyMade
                    ? Colors.blue.shade100
                    : Colors.green.shade100,
              ),
            ),
            child: Text(
              config.isReadyMade ? 'Ready Made' : 'Fabric Only',
              style: TextStyle(
                color: config.isReadyMade
                    ? Colors.blue.shade800
                    : Colors.green.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (config.materialType != null && config.materialType!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                config.materialType!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsCell(UniformItemConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size or measurements
          if (config.isReadyMade &&
              config.selectedSize != null &&
              config.selectedSize!.isNotEmpty)
            _buildDetailRow('Size', config.selectedSize!),

          if (!config.isReadyMade && config.measurements.isNotEmpty)
            _buildMeasurementsSection(config.measurements),

          // Additional options
          if (config.itemName.toLowerCase().contains('shirt') ||
              config.itemName.toLowerCase().contains('coat') ||
              config.itemName.toLowerCase().contains('jacket'))
            if (config.sleeveType != null && config.sleeveType!.isNotEmpty)
              _buildDetailRow('Sleeve Type', config.sleeveType!),

          if (config.itemName.toLowerCase().contains('t-shirt') ||
              config.itemName.toLowerCase().contains('tshirt'))
            if (config.tshirtStyle != null && config.tshirtStyle!.isNotEmpty)
              _buildDetailRow('T-Shirt Style', config.tshirtStyle!),

          if (config.itemName.toLowerCase().contains('cap') ||
              config.itemName.toLowerCase().contains('hat') ||
              config.itemName.toLowerCase().contains('net'))
            if (config.capStyle != null && config.capStyle!.isNotEmpty)
              _buildDetailRow('Cap Style', config.capStyle!),

          if (config.itemName.toLowerCase().contains('apron'))
            if (config.capStyle != null && config.capStyle!.isNotEmpty)
              _buildDetailRow('Apron Type', config.capStyle!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsSection(Map<String, String> measurements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Measurements:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        ...measurements.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
