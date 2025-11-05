import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:order_tracker/order_tracker.dart';
import 'package:order_tracker/order_tracker.dart' as order_tracker show TextDto;

import '../../../core/hive_model/company_model.dart';

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
              Text("Uniform Count :${employee.counts ?? 0}"),
              // Uniform items table
              _buildUniformConfigurationSection(),
              const SizedBox(height: 24),
              // Feedback section
              if (employee.feedBack != null && employee.feedBack!.isNotEmpty)
                _buildFeedbackSection(),
              SizedBox(
                height: 20,
              ),
              TailorOrderTracker(
                employee: employee,
              )
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
        ));
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

enum TailorStatus {
  pending,
  takingMaterial,
  stitchingStarted,
  stitchingCompleted,
  outForDelivery,
  delivered,
}

extension TailorStatusExtension on TailorStatus {
  String get label {
    switch (this) {
      case TailorStatus.pending:
        return "Pending";
      case TailorStatus.takingMaterial:
        return "Taking Material";
      case TailorStatus.stitchingStarted:
        return "Stitching Started";
      case TailorStatus.stitchingCompleted:
        return "Stitching Completed";
      case TailorStatus.outForDelivery:
        return "Out for Delivery";
      case TailorStatus.delivered:
        return "Delivered";
    }
  }
}

class TailorOrderTracker extends StatefulWidget {
  final Employee employee;

  const TailorOrderTracker({super.key, required this.employee});

  @override
  State<TailorOrderTracker> createState() => _TailorOrderTrackerState();
}

class _TailorOrderTrackerState extends State<TailorOrderTracker> {
  late TailorStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    // Initialize status based on employee's currentStatus
    _currentStatus = _getStatusFromString(widget.employee.currentStatus);
  }

  TailorStatus _getStatusFromString(String status) {
    switch (status) {
      case "Taking Material":
        return TailorStatus.takingMaterial;
      case "Stitching Started":
        return TailorStatus.stitchingStarted;
      case "Stitching Completed":
        return TailorStatus.stitchingCompleted;
      case "Out for Delivery":
        return TailorStatus.outForDelivery;
      case "Delivered":
        return TailorStatus.delivered;
      default:
        return TailorStatus.pending;
    }
  }

  String _getStringFromStatus(TailorStatus status) {
    switch (status) {
      case TailorStatus.takingMaterial:
        return "Taking Material";
      case TailorStatus.stitchingStarted:
        return "Stitching Started";
      case TailorStatus.stitchingCompleted:
        return "Stitching Completed";
      case TailorStatus.outForDelivery:
        return "Out for Delivery";
      case TailorStatus.delivered:
        return "Delivered";
      default:
        return "Pending";
    }
  }

  Future<void> _updateStatus(TailorStatus newStatus) async {
    try {
      final newStatusString = _getStringFromStatus(newStatus);
      widget.employee.currentStatus = newStatusString;

      // Ensure Hive box is open
      if (!Hive.isBoxOpen('restaurants')) {
        await Hive.openBox<Restaurant>('restaurants');
      }

      final restaurantBox = Hive.box<Restaurant>('restaurants');

      // Find the restaurant that contains this employee
      int? restaurantKey;
      int? employeeIndex;
      Restaurant? foundRestaurant;

      for (int i = 0; i < restaurantBox.length; i++) {
        final restaurant = restaurantBox.getAt(i);
        if (restaurant != null) {
          final idx = restaurant.employees.indexWhere((emp) =>
              emp.name == widget.employee.name &&
              emp.position == widget.employee.position &&
              emp.gender == widget.employee.gender);

          if (idx != -1) {
            foundRestaurant = restaurant;
            restaurantKey = i;
            employeeIndex = idx;
            break;
          }
        }
      }

      if (foundRestaurant != null &&
          restaurantKey != null &&
          employeeIndex != null) {
        // Replace only that one employee, no duplicates
        final updatedEmployees = List<Employee>.from(foundRestaurant.employees);
        updatedEmployees[employeeIndex] = widget.employee;

        final updatedRestaurant =
            foundRestaurant.copyWith(employees: updatedEmployees);

        // ✅ Always overwrite instead of adding new
        await restaurantBox.putAt(restaurantKey, updatedRestaurant);

        setState(() {
          _currentStatus = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatusString')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee not found in any restaurant')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Steps for tailor app
    List<TextDto> pendingList = [
      TextDto("Your tailoring request has been placed", ""),
    ];

    List<TextDto> takingMaterialList = [
      TextDto("Material has been collected", ""),
    ];

    List<TextDto> stitchingStartedList = [
      TextDto("Stitching process has started", ""),
    ];

    List<TextDto> stitchingCompletedList = [
      TextDto("Stitching completed successfully", ""),
    ];

    List<TextDto> outForDeliveryList = [
      TextDto("Your order is out for delivery", ""),
    ];

    List<TextDto> deliveredList = [
      TextDto("Your tailored dress has been delivered", ""),
    ];

    return Column(
      children: [
        // Status selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<TailorStatus>(
            value: _currentStatus,
            items: const [
              DropdownMenuItem(
                  value: TailorStatus.pending, child: Text('Pending')),
              DropdownMenuItem(
                  value: TailorStatus.takingMaterial,
                  child: Text('Material Collected')),
              DropdownMenuItem(
                  value: TailorStatus.stitchingStarted,
                  child: Text('Stitching Started')),
              DropdownMenuItem(
                  value: TailorStatus.stitchingCompleted,
                  child: Text('Stitching Completed')),
              DropdownMenuItem(
                  value: TailorStatus.outForDelivery,
                  child: Text('Out for Delivery')),
              DropdownMenuItem(
                  value: TailorStatus.delivered, child: Text('Delivered')),
            ],
            onChanged: (TailorStatus? newValue) {
              if (newValue != null) {
                _updateStatus(newValue);
              }
            },
            decoration: const InputDecoration(
              labelText: 'Current Status',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        // Order tracker using the order_tracker package
        OrderTracker(
          status: _mapToOrderTrackerStatus(_currentStatus),
          activeColor: Colors.green,
          inActiveColor: Colors.grey[300]!,
          orderTitleAndDateList: _convertToOrderTrackerDto(pendingList),
          shippedTitleAndDateList:
              _convertToOrderTrackerDto(takingMaterialList),
          outOfDeliveryTitleAndDateList: _getOutForDeliveryList(
            stitchingStartedList,
            stitchingCompletedList,
            outForDeliveryList,
          ),
          deliveredTitleAndDateList: _convertToOrderTrackerDto(deliveredList),
        ),
      ],
    );
  }

  // Helper method to map our TailorStatus to the order_tracker package's Status
  Status _mapToOrderTrackerStatus(TailorStatus status) {
    switch (status) {
      case TailorStatus.pending:
        return Status.pending;
      case TailorStatus.takingMaterial:
        return Status.shipped;
      case TailorStatus.stitchingStarted:
        return Status.outOfDelivery;
      case TailorStatus.stitchingCompleted:
        return Status.outOfDelivery;
      case TailorStatus.outForDelivery:
        return Status.outOfDelivery;
      case TailorStatus.delivered:
        return Status.delivered;
    }
  }

  // Helper method to convert our TextDto to the order_tracker package's TextDto
  List<order_tracker.TextDto> _convertToOrderTrackerDto(List<TextDto> list) {
    return list
        .map((dto) => order_tracker.TextDto(dto.text, dto.date))
        .toList();
  }

  // Helper method to get the appropriate list for outOfDelivery based on current status
  List<order_tracker.TextDto> _getOutForDeliveryList(
    List<TextDto> stitchingStarted,
    List<TextDto> stitchingCompleted,
    List<TextDto> outForDelivery,
  ) {
    if (_currentStatus.index >= TailorStatus.outForDelivery.index) {
      return _convertToOrderTrackerDto([
        ...stitchingStarted,
        ...stitchingCompleted,
        ...outForDelivery,
      ]);
    } else if (_currentStatus.index >= TailorStatus.stitchingCompleted.index) {
      return _convertToOrderTrackerDto([
        ...stitchingStarted,
        ...stitchingCompleted,
      ]);
    } else if (_currentStatus.index >= TailorStatus.stitchingStarted.index) {
      return _convertToOrderTrackerDto(stitchingStarted);
    } else {
      return _convertToOrderTrackerDto([]);
    }
  }
}

class EmployeeStatusEditor extends StatelessWidget {
  final Employee employee;
  final Function(String) onStatusChanged;

  EmployeeStatusEditor(
      {super.key, required this.employee, required this.onStatusChanged});

  final List<String> statusOptions = [
    "Pending",
    "Taking Material",
    "Stitching Started",
    "Stitching Completed",
    "Out for Delivery",
    "Delivered",
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: employee.currentStatus,
              items: statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onStatusChanged(newValue);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Current Status',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextDto {
  final String text;
  final String date;

  TextDto(this.text, this.date);
}
