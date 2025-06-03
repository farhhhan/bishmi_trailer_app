import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:flutter/material.dart';

class UniformItem {
  final String name;
  bool isNeeded;
  bool isReadyMade;
  String? selectedSize;
  Map<String, String> measurements;

  UniformItem({
    required this.name,
    this.isNeeded = false,
    this.isReadyMade = true,
    this.selectedSize,
    Map<String, String>? measurements,
  }) : measurements = measurements ?? {};
}

class WorkerPosition {
  final String title;
  List<UniformItem> uniformItems;

  WorkerPosition({
    required this.title,
    required this.uniformItems,
  });
}

class AddWorkerPositionScreen extends StatefulWidget {
  final String category;
  final String name;
  final Employee? employee; // Add this for editing

  const AddWorkerPositionScreen({
    Key? key,
    required this.category,
    required this.name,
    this.employee, // Make it optional
  }) : super(key: key);

  @override
  _AddWorkerPositionScreenState createState() =>
      _AddWorkerPositionScreenState();
}

class _AddWorkerPositionScreenState extends State<AddWorkerPositionScreen> {
  WorkerPosition? selectedPosition;
  TextEditingController _nameController = TextEditingController();
  final Map<String, List<WorkerPosition>> _positionsByCategory = {
    'Restaurant': [
      WorkerPosition(
        title: 'Executive Chef / Head Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: 'Chef Hat or Cap'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
        ],
      ),
      WorkerPosition(
        title: 'Sous Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: 'Skull Cap or Chef Hat'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
        ],
      ),
      WorkerPosition(
        title: 'Line Cook / Commis Chef',
        uniformItems: [
          UniformItem(name: 'Short-sleeved Chef Jacket'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Skull Cap or Bandana'),
          UniformItem(name: 'Chef Pants'),
        ],
      ),
      WorkerPosition(
        title: 'Pastry Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: "Baker's Hat or Cap"),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
        ],
      ),
      WorkerPosition(
        title: 'Kitchen Helper / Steward',
        uniformItems: [
          UniformItem(name: 'T-shirt or Kitchen Coat'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Cap or Hairnet'),
        ],
      ),
    ],
    // Add other categories here as needed
  };
  @override
  void initState() {
    super.initState();

    // Pre-fill data if editing an existing employee
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;

      // Find the matching position
      final positions = _positionsByCategory[widget.category] ?? [];
      selectedPosition = positions.firstWhere(
        (p) => p.title == widget.employee!.position,
        orElse: () => positions.first,
      );

      // Update uniform items based on saved config
      for (final config in widget.employee!.uniformConfig) {
        final item = selectedPosition!.uniformItems.firstWhere(
          (i) => i.name == config.itemName,
          orElse: () => UniformItem(name: config.itemName),
        );

        item.isNeeded = config.isNeeded;
        item.isReadyMade = config.isReadyMade;
        item.selectedSize = config.selectedSize;
        item.measurements = config.measurements;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final positions = _positionsByCategory[widget.category] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Text(
          widget.employee != null
              ? "Edit Worker"
              : "Add Workers", // Update title
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "Employee Name",
              style: TextStyle(color: Colors.black),
            ),
          ),
          CustomTextField(
            label: "Enter Employee Name",
            controller: _nameController,
          ),
          const SizedBox(height: 20),
          PositionDropdown(
            positions: positions,
            selectedPosition: selectedPosition,
            onChanged: (position) {
              setState(() {
                selectedPosition = position;
              });
            },
          ),
          if (selectedPosition != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Uniform Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...selectedPosition!.uniformItems.map((item) {
              return UniformItemCard(
                item: item,
                onChanged: () => setState(() {}),
              );
            }).toList(),
            const SizedBox(height: 24),
            SaveButton(onPressed: _saveEmployeeData),
          ],
        ],
      ),
    );
  }

  void _saveEmployeeData() {
    final employee = Employee(
      name: _nameController.text,
      position: selectedPosition!.title,
      uniformConfig: selectedPosition!.uniformItems
          .where((item) => item.isNeeded)
          .map((item) => UniformItemConfig(
                itemName: item.name,
                isNeeded: item.isNeeded,
                isReadyMade: item.isReadyMade,
                selectedSize: item.selectedSize,
                measurements: item.measurements,
              ))
          .toList(),
    );
    Navigator.pop(context, employee);
  }
}

// Custom Text Field Widget
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.inputType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 184, 180, 180)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
    );
  }
}

// Position Dropdown Widget
class PositionDropdown extends StatelessWidget {
  final List<WorkerPosition> positions;
  final WorkerPosition? selectedPosition;
  final ValueChanged<WorkerPosition?> onChanged;

  const PositionDropdown({
    Key? key,
    required this.positions,
    required this.selectedPosition,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<WorkerPosition>(
      decoration: InputDecoration(
        labelText: "Select Worker Position",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      value: selectedPosition,
      items: positions
          .map((position) => DropdownMenuItem(
                value: position,
                child: Text(position.title),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a position' : null,
    );
  }
}

// Uniform Item Card Widget
class UniformItemCard extends StatefulWidget {
  final UniformItem item;
  final VoidCallback onChanged;

  const UniformItemCard({
    Key? key,
    required this.item,
    required this.onChanged,
  }) : super(key: key);

  @override
  _UniformItemCardState createState() => _UniformItemCardState();
}

class _UniformItemCardState extends State<UniformItemCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: widget.item.isNeeded,
                  onChanged: (value) {
                    setState(() {
                      widget.item.isNeeded = value ?? false;
                    });
                    widget.onChanged();
                  },
                ),
                Text(
                  widget.item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (widget.item.isNeeded) ...[
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Ready Made',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      leading: SizedBox(
                        width: 10,
                        child: Radio<bool>(
                          value: true,
                          groupValue: widget.item.isReadyMade,
                          onChanged: (value) {
                            setState(() {
                              widget.item.isReadyMade = value!;
                            });
                            widget.onChanged();
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'measurement',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      leading: SizedBox(
                        width: 9,
                        child: Radio<bool>(
                          value: false,
                          groupValue: widget.item.isReadyMade,
                          onChanged: (value) {
                            setState(() {
                              widget.item.isReadyMade = value!;
                            });
                            widget.onChanged();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.item.isReadyMade) ...[
                const SizedBox(height: 10),
                SizeDropdown(item: widget.item),
              ] else ...[
                const SizedBox(height: 10),
                MeasurementsFields(item: widget.item),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// Size Dropdown Widget
class SizeDropdown extends StatefulWidget {
  final UniformItem item;

  const SizeDropdown({Key? key, required this.item}) : super(key: key);

  @override
  _SizeDropdownState createState() => _SizeDropdownState();
}

class _SizeDropdownState extends State<SizeDropdown> {
  late List<String> sizes;

  @override
  void initState() {
    super.initState();
    sizes = ['S', 'M', 'L', 'XL', 'XXL'];

    if (widget.item.name.toLowerCase().contains('shoe')) {
      sizes = ['6', '7', '8', '9', '10', '11', '12'];
    } else if (widget.item.name.toLowerCase().contains('hat') ||
        widget.item.name.toLowerCase().contains('cap')) {
      sizes = ['Small', 'Medium', 'Large'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Select Size",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      value: widget.item.selectedSize,
      items: sizes
          .map((size) => DropdownMenuItem(
                value: size,
                child: Text(size),
              ))
          .toList(),
      onChanged: (size) {
        setState(() {
          widget.item.selectedSize = size;
        });
      },
      validator: (value) => value == null ? 'Please select a size' : null,
    );
  }
}

// Measurements Fields Widget
class MeasurementsFields extends StatefulWidget {
  final UniformItem item;

  const MeasurementsFields({Key? key, required this.item}) : super(key: key);

  @override
  _MeasurementsFieldsState createState() => _MeasurementsFieldsState();
}

class _MeasurementsFieldsState extends State<MeasurementsFields> {
  late Map<String, String> measurementFields;
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    measurementFields = {
      'Chest': 'inches',
      'Waist': 'inches',
      'Hip': 'inches',
      'Length': 'inches',
      'Shoulder': 'inches',
      'Sleeve Length': 'inches',
      'Inseam': 'inches',
      'Outseam': 'inches',
      'Thigh': 'inches',
      'Neck': 'inches',
      'Foot Length': 'cm',
      'Foot Width': 'cm',
    };

    if (widget.item.name.toLowerCase().contains('pant')) {
      measurementFields = {
        'Waist': 'inches',
        'Hip': 'inches',
        'Inseam': 'inches',
        'Outseam': 'inches',
        'Thigh': 'inches',
      };
    } else if (widget.item.name.toLowerCase().contains('shoe')) {
      measurementFields = {
        'Foot Length': 'cm',
        'Foot Width': 'cm',
      };
    } else if (widget.item.name.toLowerCase().contains('hat') ||
        widget.item.name.toLowerCase().contains('cap')) {
      measurementFields = {
        'Head Circumference': 'inches',
      };
    }

    _controllers = {};
    for (var key in measurementFields.keys) {
      _controllers[key] = TextEditingController(
        text: widget.item.measurements[key] ?? '',
      );
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Measurements:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...measurementFields.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: _controllers[entry.key],
              decoration: InputDecoration(
                labelText: '${entry.key} (${entry.value})',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.item.measurements[entry.key] = value;
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Save Button Widget
class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF0B623),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          "Save",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
