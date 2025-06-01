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

  const AddWorkerPositionScreen({Key? key, required this.category})
      : super(key: key);

  @override
  _AddWorkerPositionScreenState createState() =>
      _AddWorkerPositionScreenState();
}

class _AddWorkerPositionScreenState extends State<AddWorkerPositionScreen> {
  WorkerPosition? selectedPosition;
  TextEditingController _restaurantController = TextEditingController();
  final Map<String, List<WorkerPosition>> _positionsByCategory = {
    'Restaurant': [
      WorkerPosition(
        title: 'Executive Chef / Head Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: 'Chef Hat or Cap'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
          UniformItem(name: 'Kitchen Shoes'),
        ],
      ),
      WorkerPosition(
        title: 'Sous Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: 'Skull Cap or Chef Hat'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
          UniformItem(name: 'Kitchen Shoes'),
        ],
      ),
      WorkerPosition(
        title: 'Line Cook / Commis Chef',
        uniformItems: [
          UniformItem(name: 'Short-sleeved Chef Jacket'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Skull Cap or Bandana'),
          UniformItem(name: 'Chef Pants'),
          UniformItem(name: 'Kitchen Shoes'),
        ],
      ),
      WorkerPosition(
        title: 'Pastry Chef',
        uniformItems: [
          UniformItem(name: 'Chef Coat'),
          UniformItem(name: "Baker's Hat or Cap"),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Chef Pants'),
          UniformItem(name: 'Kitchen Shoes'),
        ],
      ),
      WorkerPosition(
        title: 'Kitchen Helper / Steward',
        uniformItems: [
          UniformItem(name: 'T-shirt or Kitchen Coat'),
          UniformItem(name: 'Apron'),
          UniformItem(name: 'Cap or Hairnet'),
          UniformItem(name: 'Kitchen Shoes'),
        ],
      ),
    ],
    // Add other categories here as needed
  };

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
          "Add Wokers",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          SizedBox(
            height: 20,
          ),
          const Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "Employe Name",
              style: TextStyle(color: Colors.black),
            ),
          ),
          _buildTextField("Enter Employee Name", _restaurantController),
          const SizedBox(height: 20),

          // Worker position dropdown
          _buildPositionDropdown(positions),

          if (selectedPosition != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Uniform Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._buildUniformItemsList(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
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

  Widget _buildPositionDropdown(List<WorkerPosition> positions) {
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
      onChanged: (position) {
        setState(() {
          selectedPosition = position;
        });
      },
      validator: (value) => value == null ? 'Please select a position' : null,
    );
  }

  List<Widget> _buildUniformItemsList() {
    return selectedPosition!.uniformItems.map((item) {
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
              // Item name and checkbox
              Row(
                children: [
                  Checkbox(
                    value: item.isNeeded,
                    onChanged: (value) {
                      setState(() {
                        item.isNeeded = value ?? false;
                      });
                    },
                  ),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              if (item.isNeeded) ...[
                const SizedBox(height: 5),
                // Ready-made vs Tailoring selection
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
                            groupValue: item.isReadyMade,
                            onChanged: (value) {
                              setState(() {
                                item.isReadyMade = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text(
                          'measurment',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        leading: SizedBox(
                          width: 9,
                          child: Radio<bool>(
                            value: false,
                            groupValue: item.isReadyMade,
                            onChanged: (value) {
                              setState(() {
                                item.isReadyMade = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Size selection or measurements
                if (item.isReadyMade) ...[
                  const SizedBox(height: 10),
                  _buildSizeDropdown(item),
                ] else ...[
                  const SizedBox(height: 10),
                  _buildMeasurementsFields(item),
                ],
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSizeDropdown(UniformItem item) {
    final sizes = ['S', 'M', 'L', 'XL', 'XXL'];

    // Special case for shoes
    if (item.name.toLowerCase().contains('shoe')) {
      sizes.clear();
      sizes.addAll(['6', '7', '8', '9', '10', '11', '12']);
    }

    // Special case for hats/caps
    if (item.name.toLowerCase().contains('hat') ||
        item.name.toLowerCase().contains('cap')) {
      sizes.clear();
      sizes.addAll(['Small', 'Medium', 'Large']);
    }

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
      value: item.selectedSize,
      items: sizes
          .map((size) => DropdownMenuItem(
                value: size,
                child: Text(size),
              ))
          .toList(),
      onChanged: (size) {
        setState(() {
          item.selectedSize = size;
        });
      },
      validator: (value) => value == null ? 'Please select a size' : null,
    );
  }

  Widget _buildMeasurementsFields(UniformItem item) {
    final Map<String, String> measurementFields = {
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

    // Customize fields based on item type
    if (item.name.toLowerCase().contains('pant')) {
      measurementFields
        ..clear()
        ..addAll({
          'Waist': 'inches',
          'Hip': 'inches',
          'Inseam': 'inches',
          'Outseam': 'inches',
          'Thigh': 'inches',
        });
    } else if (item.name.toLowerCase().contains('shoe')) {
      measurementFields
        ..clear()
        ..addAll({
          'Foot Length': 'cm',
          'Foot Width': 'cm',
        });
    } else if (item.name.toLowerCase().contains('hat') ||
        item.name.toLowerCase().contains('cap')) {
      measurementFields
        ..clear()
        ..addAll({
          'Head Circumference': 'inches',
        });
    }

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
                item.measurements[entry.key] = value;
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSaveButton() {
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
        onPressed: () {
          _saveUniformData();
          Navigator.pop(context);
        },
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

  void _saveUniformData() {
    if (selectedPosition == null) return;

    print("Saving uniform data for: ${selectedPosition!.title}");
    for (var item in selectedPosition!.uniformItems) {
      if (item.isNeeded) {
        if (item.isReadyMade) {
          print("${item.name}: Ready Made (Size: ${item.selectedSize})");
        } else {
          print("${item.name}: Tailoring (Measurements: ${item.measurements})");
        }
      }
    }
  }
}
