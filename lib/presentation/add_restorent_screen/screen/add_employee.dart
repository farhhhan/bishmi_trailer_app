import 'package:bishmi_app/core/hive_model/company_model.dart';
import 'package:flutter/material.dart';

class UniformItem {
  final String name;
  bool isNeeded;
  bool isReadyMade;
  String? selectedSize;
  Map<String, String> measurements;
  String? sleeveType; // 'Half Sleeve' or 'Full Sleeve'
  String? tshirtStyle; // 'Polo' or 'Regular'
  String? materialType; // Material type for all items
  String? capStyle; // 'Cap' or 'Net'

  UniformItem({
    required this.name,
    this.isNeeded = false,
    this.isReadyMade = true,
    this.selectedSize,
    Map<String, String>? measurements,
    this.sleeveType,
    this.tshirtStyle,
    this.materialType,
    this.capStyle,
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
  final Employee? employee;

  const AddWorkerPositionScreen({
    Key? key,
    required this.category,
    required this.name,
    this.employee,
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
  };

  @override
  void initState() {
    super.initState();

    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;

      final positions = _positionsByCategory[widget.category] ?? [];
      selectedPosition = positions.firstWhere(
        (p) => p.title == widget.employee!.position,
        orElse: () => positions.first,
      );

      for (final config in widget.employee!.uniformConfig) {
        final item = selectedPosition!.uniformItems.firstWhere(
          (i) => i.name == config.itemName,
          orElse: () => UniformItem(name: config.itemName),
        );

        item.isNeeded = config.isNeeded;
        item.isReadyMade = config.isReadyMade;
        item.selectedSize = config.selectedSize;
        item.measurements = config.measurements;
        item.sleeveType = config.sleeveType;
        item.tshirtStyle = config.tshirtStyle;
        item.materialType = config.materialType;
        item.capStyle = config.capStyle;
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
          widget.employee != null ? "Edit Worker" : "Add Workers",
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
                sleeveType: item.sleeveType,
                tshirtStyle: item.tshirtStyle,
                materialType: item.materialType,
                capStyle: item.capStyle,
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

              // Material selection for all items
              MaterialDropdown(item: widget.item),
              const SizedBox(height: 10),

              // Ready-made vs Fabric selection
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Ready-Made',
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
                        'Fabric Only',
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

              // Additional features based on item type
              if (widget.item.name.toLowerCase().contains('shirt') ||
                  widget.item.name.toLowerCase().contains('coat') ||
                  widget.item.name.toLowerCase().contains('jacket')) ...[
                SleeveTypeRadio(item: widget.item),
                const SizedBox(height: 10),
              ],

              if (widget.item.name.toLowerCase().contains('t-shirt') ||
                  widget.item.name.toLowerCase().contains('tshirt')) ...[
                TshirtStyleRadio(item: widget.item),
                const SizedBox(height: 10),
              ],

              if (widget.item.name.toLowerCase().contains('cap') ||
                  widget.item.name.toLowerCase().contains('hat') ||
                  widget.item.name.toLowerCase().contains('net')) ...[
                CapStyleRadio(item: widget.item),
                const SizedBox(height: 10),
              ],

              if (widget.item.isReadyMade) ...[
                SizeDropdown(item: widget.item),
              ] else ...[
                MeasurementsFields(item: widget.item),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// Material Dropdown Widget
class MaterialDropdown extends StatelessWidget {
  final UniformItem item;

  const MaterialDropdown({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final materials = [
      'Cotton',
      'Polyester',
      'Nylon',
      'Wool',
      'Linen',
      'Denim',
      'Silk',
      'Leather',
      'Blend'
    ];

    return DropdownButtonFormField<String>(
      value: item.materialType,
      decoration: InputDecoration(
        labelText: "Select Material",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: materials
          .map((material) => DropdownMenuItem(
                value: material,
                child: Text(material),
              ))
          .toList(),
      onChanged: (material) {
        item.materialType = material;
      },
    );
  }
}

// Sleeve Type Radio Widget
class SleeveTypeRadio extends StatefulWidget {
  final UniformItem item;

  const SleeveTypeRadio({Key? key, required this.item}) : super(key: key);

  @override
  State<SleeveTypeRadio> createState() => _SleeveTypeRadioState();
}

class _SleeveTypeRadioState extends State<SleeveTypeRadio> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sleeve Type:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text(
                  'Half Sleeve',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: SizedBox(
                  width: 15,
                  child: Radio<String>(
                    value: 'Half Sleeve',
                    groupValue: widget.item.sleeveType,
                    onChanged: (value) {
                      setState(() {
                        widget.item.sleeveType = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text(
                  'Full Sleeve',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: SizedBox(
                  width: 15,
                  child: Radio<String>(
                    value: 'Full Sleeve',
                    groupValue: widget.item.sleeveType,
                    onChanged: (value) {
                      setState(() {
                        widget.item.sleeveType = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// T-Shirt Style Radio Widget
class TshirtStyleRadio extends StatefulWidget {
  final UniformItem item;

  const TshirtStyleRadio({Key? key, required this.item}) : super(key: key);

  @override
  State<TshirtStyleRadio> createState() => _TshirtStyleRadioState();
}

class _TshirtStyleRadioState extends State<TshirtStyleRadio> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'T-Shirt Style:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text(
                  'Polo',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: SizedBox(
                  width: 15,
                  child: Radio<String>(
                    value: 'Polo',
                    groupValue: widget.item.tshirtStyle,
                    onChanged: (value) {
                      setState(() {
                        widget.item.tshirtStyle = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text(
                  'Regular',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: SizedBox(
                  width: 15,
                  child: Radio<String>(
                    value: 'Regular',
                    groupValue: widget.item.tshirtStyle,
                    onChanged: (value) {
                      setState(() {
                        widget.item.tshirtStyle = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Cap Style Radio Widget
class CapStyleRadio extends StatefulWidget {
  final UniformItem item;

  const CapStyleRadio({Key? key, required this.item}) : super(key: key);

  @override
  State<CapStyleRadio> createState() => _CapStyleRadioState();
}

class _CapStyleRadioState extends State<CapStyleRadio> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Style:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text(
                  'Non Net',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: SizedBox(
                  width: 15,
                  child: Radio<String>(
                    value: 'Non',
                    groupValue: widget.item.capStyle,
                    onChanged: (value) {
                      setState(() {
                        widget.item.capStyle = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text(
                  'Net',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: SizedBox(
                  width: 15,
                  child: Radio<String>(
                    value: 'Net',
                    groupValue: widget.item.capStyle,
                    onChanged: (value) {
                      setState(() {
                        widget.item.capStyle = value;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
        widget.item.name.toLowerCase().contains('cap') ||
        widget.item.name.toLowerCase().contains('net')) {
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
        widget.item.name.toLowerCase().contains('cap') ||
        widget.item.name.toLowerCase().contains('net')) {
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
