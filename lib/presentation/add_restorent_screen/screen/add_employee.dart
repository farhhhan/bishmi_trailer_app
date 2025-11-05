import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../core/hive_model/company_model.dart';
import '../../add_cate/add_cate_sc.dart';

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
  FirebasePosition? selectedPosition;
  String? _selectedGender;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _employeeNote = TextEditingController();
  TextEditingController _counts = TextEditingController();

  List<FirebasePosition> _positions = [];
  bool _isLoading = true;
  List<UniformItem>? _currentUniformItems;

  @override
  void initState() {
    super.initState();
    _loadPositions();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _selectedGender = widget.employee!.gender;
      _employeeNote.text = widget.employee!.feedBack;
      _currentUniformItems = widget.employee!.uniformConfig.map((config) {
        return UniformItem(
          name: config.itemName,
          isNeeded: config.isNeeded,
          isReadyMade: config.isReadyMade,
          selectedSize: config.selectedSize,
          measurements: Map.from(config.measurements),
          sleeveType: config.sleeveType,
          tshirtStyle: config.tshirtStyle,
          materialType: config.materialType ?? 'Cotton', // Default value
          capStyle: config.capStyle,
        );
      }).toList();
    }
  }

  Future<void> _loadPositions() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final positionsSnapshot = await firestore
          .collection('categories')
          .doc(widget.category)
          .collection('positions')
          .get();

      final positions = positionsSnapshot.docs
          .map((doc) => FirebasePosition.fromMap(doc.data()))
          .toList();

      setState(() {
        _positions = positions;
        _isLoading = false;

        if (widget.employee != null && positions.isNotEmpty) {
          selectedPosition = _positions.firstWhere(
            (p) => p.title == widget.employee!.position,
            orElse: () => _positions.first,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load positions: $e')),
      );
    }
  }

  void _updateUniformItems() {
    if (selectedPosition != null && _selectedGender != null) {
      final genderItems =
          selectedPosition!.uniformItemsByGender[_selectedGender!] ?? [];
      setState(() {
        _currentUniformItems = genderItems.map((firebaseItem) {
          final existingItem = widget.employee?.uniformConfig.firstWhere(
            (config) => config.itemName == firebaseItem.name,
            orElse: () => UniformItemConfig(
              itemName: firebaseItem.name,
              isNeeded: firebaseItem.isRequired,
              isReadyMade: false,
              selectedSize: '',
              measurements: {},
              sleeveType: '',
              tshirtStyle: '',
              materialType: 'Cotton',
              capStyle: '',
            ),
          );

          return UniformItem(
            name: firebaseItem.name,
            isNeeded: existingItem?.isNeeded ?? firebaseItem.isRequired,
            isReadyMade: existingItem?.isReadyMade ?? false,
            selectedSize: existingItem?.selectedSize ?? '',
            measurements: Map.from(existingItem?.measurements ?? {}),
            sleeveType: existingItem?.sleeveType ?? '',
            tshirtStyle: existingItem?.tshirtStyle ?? '',
            materialType: existingItem?.materialType ?? 'Cotton',
            capStyle: existingItem?.capStyle ?? '',
          );
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
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
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Gender",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Male'),
                        value: 'Male',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _updateUniformItems();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Female'),
                        value: 'Female',
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                            _updateUniformItems();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PositionDropdown(
                  positions: _positions,
                  selectedPosition: selectedPosition,
                  onChanged: (position) {
                    setState(() {
                      selectedPosition = position;
                      if (_selectedGender != null) {
                        _updateUniformItems();
                      }
                    });
                  },
                ),
                if (selectedPosition != null &&
                    _selectedGender != null &&
                    _currentUniformItems != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Uniform Items:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._currentUniformItems!.map((item) {
                    final firebaseItem = selectedPosition!
                        .uniformItemsByGender[_selectedGender]!
                        .firstWhere((i) => i.name == item.name);
                    return UniformItemCard(
                      item: item,
                      measurementFields: firebaseItem.measurementFields,
                      onChanged: () => setState(() {}),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Quandity",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  CustomTextField(
                    label: "Enter Count",
                    controller: _counts,
                    maxLine: 1,
                  ),
                  SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Employee Note",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  CustomTextField(
                    label: "Enter Employee Note",
                    controller: _employeeNote,
                    maxLine: 3,
                  ),
                  SizedBox(height: 20),
                  SaveButton(onPressed: _saveEmployeeData),
                ],
              ],
            ),
    );
  }

  void _saveEmployeeData() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return;
    }

    if (selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select position')),
      );
      return;
    }

    final employee = Employee(
      feedBack: _employeeNote.text,
      name: _nameController.text,
      position: selectedPosition!.title,
      counts: _counts.text,
      uniformConfig: _currentUniformItems!
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
      gender: _selectedGender!,
    );
    Navigator.pop(context, employee);
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;
  final int maxLine;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.inputType = TextInputType.text,
    this.maxLine = 1,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLine,
      minLines: 1,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Color.fromARGB(255, 184, 180, 180),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLine > 1 ? 16 : 0,
        ),
      ),
      validator: validator ??
          (value) =>
              value == null || value.isEmpty ? 'This field is required' : null,
    );
  }
}

class PositionDropdown extends StatelessWidget {
  final List<FirebasePosition> positions;
  final FirebasePosition? selectedPosition;
  final ValueChanged<FirebasePosition?> onChanged;

  const PositionDropdown({
    Key? key,
    required this.positions,
    required this.selectedPosition,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<FirebasePosition>(
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
      items: positions.map((position) {
        return DropdownMenuItem<FirebasePosition>(
          value: position,
          child: Text(position.title),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a position' : null,
    );
  }
}

class MaterialDropdown extends StatelessWidget {
  final UniformItem item;
  final List<String> materials = const [
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

  const MaterialDropdown({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: item.materialType!.isNotEmpty ? item.materialType : 'Cotton',
      decoration: InputDecoration(
        labelText: "Select Material",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: materials.map((material) {
        return DropdownMenuItem<String>(
          value: material,
          child: Text(material),
        );
      }).toList(),
      onChanged: (material) {
        item.materialType = material ?? 'Cotton';
      },
    );
  }
}

class UniformItemCard extends StatefulWidget {
  final UniformItem item;
  final List<MeasurementField> measurementFields;
  final VoidCallback onChanged;

  const UniformItemCard({
    Key? key,
    required this.item,
    required this.measurementFields,
    required this.onChanged,
  }) : super(key: key);

  @override
  _UniformItemCardState createState() => _UniformItemCardState();
}

class _UniformItemCardState extends State<UniformItemCard> {
  @override
  Widget build(BuildContext context) {
    final isCap = widget.item.name.toLowerCase().contains('cap') ||
        widget.item.name.toLowerCase().contains('hat') ||
        widget.item.name.toLowerCase().contains('net');

    final isApron = widget.item.name.toLowerCase().contains('apron');

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
              if (isApron) _buildApronOptions(),
              if (isCap) _buildCapOptions(),
              if (!isCap && !isApron) MaterialDropdown(item: widget.item),
              if (isApron) MaterialDropdown(item: widget.item),
              const SizedBox(height: 10),
              if (!isCap && !isApron) ...[
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
                                widget.item.isReadyMade = value ?? false;
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
                                widget.item.isReadyMade = value ?? false;
                              });
                              widget.onChanged();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (!isCap && !isApron) ...[
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
              ],
              if (widget.item.isReadyMade && !isCap && !isApron) ...[
                SizeDropdown(item: widget.item),
              ] else if (!isCap && !isApron) ...[
                MeasurementsFields(
                  item: widget.item,
                  measurementFields: widget.measurementFields,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApronOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: const Text(
            'Apron Type:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text(
                  'Full Apron',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: Radio<String>(
                  value: 'Full',
                  groupValue: widget.item.capStyle ?? 'Full',
                  onChanged: (value) {
                    setState(() {
                      widget.item.capStyle = value;
                    });
                    widget.onChanged();
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text(
                  'Half Apron',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: Radio<String>(
                  value: 'Half',
                  groupValue: widget.item.capStyle ?? 'Full',
                  onChanged: (value) {
                    setState(() {
                      widget.item.capStyle = value;
                    });
                    widget.onChanged();
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCapOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: const Text(
            'Cap Type:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text(
                  'Net Cap',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: Radio<String>(
                  value: 'Net',
                  groupValue: widget.item.capStyle ?? 'Net',
                  onChanged: (value) {
                    setState(() {
                      widget.item.capStyle = value;
                      widget.item.materialType = 'Cotton';
                    });
                    widget.onChanged();
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text(
                  'Cotton Cap',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                leading: Radio<String>(
                  value: 'Cotton',
                  groupValue: widget.item.capStyle ?? 'Net',
                  onChanged: (value) {
                    setState(() {
                      widget.item.capStyle = value;
                      widget.item.materialType = 'Cotton';
                    });
                    widget.onChanged();
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class MeasurementsFields extends StatefulWidget {
  final UniformItem item;
  final List<MeasurementField> measurementFields;

  const MeasurementsFields({
    Key? key,
    required this.item,
    required this.measurementFields,
  }) : super(key: key);

  @override
  _MeasurementsFieldsState createState() => _MeasurementsFieldsState();
}

class _MeasurementsFieldsState extends State<MeasurementsFields> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (var field in widget.measurementFields) {
      _controllers[field.name] = TextEditingController(
        text: widget.item.measurements[field.name] ?? '',
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
        ...widget.measurementFields.map((field) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: _controllers[field.name],
              decoration: InputDecoration(
                labelText: '${field.name} (${field.unit})',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.item.measurements[field.name] = value;
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}

class SleeveTypeRadio extends StatefulWidget {
  final UniformItem item;

  const SleeveTypeRadio({Key? key, required this.item}) : super(key: key);

  @override
  _SleeveTypeRadioState createState() => _SleeveTypeRadioState();
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
                    groupValue: widget.item.sleeveType!.isNotEmpty
                        ? widget.item.sleeveType
                        : 'Half Sleeve',
                    onChanged: (value) {
                      setState(() {
                        widget.item.sleeveType = value ?? 'Half Sleeve';
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
                    groupValue: widget.item.sleeveType!.isNotEmpty
                        ? widget.item.sleeveType
                        : 'Half Sleeve',
                    onChanged: (value) {
                      setState(() {
                        widget.item.sleeveType = value ?? 'Half Sleeve';
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

class TshirtStyleRadio extends StatefulWidget {
  final UniformItem item;

  const TshirtStyleRadio({Key? key, required this.item}) : super(key: key);

  @override
  _TshirtStyleRadioState createState() => _TshirtStyleRadioState();
}

class _TshirtStyleRadioState extends State<TshirtStyleRadio> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('T-Shirt Style:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Polo',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                leading: SizedBox(
                  width: 15,
                  child: Radio<String>(
                    value: 'Polo',
                    groupValue: widget.item.tshirtStyle!.isNotEmpty
                        ? widget.item.tshirtStyle
                        : 'Polo',
                    onChanged: (value) {
                      setState(() {
                        widget.item.tshirtStyle = value ?? 'Polo';
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('Regular',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                leading: SizedBox(
                  width: 15,
                  child: Radio<String>(
                    value: 'Regular',
                    groupValue: widget.item.tshirtStyle!.isNotEmpty
                        ? widget.item.tshirtStyle
                        : 'Polo',
                    onChanged: (value) {
                      setState(() {
                        widget.item.tshirtStyle = value ?? 'Polo';
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
      value: widget.item.selectedSize!.isNotEmpty
          ? widget.item.selectedSize
          : sizes.first,
      decoration: InputDecoration(
        labelText: "Select Size",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: sizes.map((size) {
        return DropdownMenuItem<String>(
          value: size,
          child: Text(size),
        );
      }).toList(),
      onChanged: (size) {
        setState(() {
          widget.item.selectedSize = size ?? sizes.first;
        });
      },
    );
  }
}

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
