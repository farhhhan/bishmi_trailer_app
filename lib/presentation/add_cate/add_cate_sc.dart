import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// Firebase Models
class FirebaseCategory {
  final String name;
  final DateTime createdAt;

  FirebaseCategory({required this.name, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FirebaseCategory.fromMap(Map<String, dynamic> map) {
    return FirebaseCategory(
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class MeasurementField {
  final String name;
  final String unit;
  final bool isRequired;

  MeasurementField({
    required this.name,
    required this.unit,
    this.isRequired = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'unit': unit,
      'isRequired': isRequired,
    };
  }

  factory MeasurementField.fromMap(Map<String, dynamic> map) {
    return MeasurementField(
      name: map['name'],
      unit: map['unit'],
      isRequired: map['isRequired'] ?? true,
    );
  }
}

class FirebaseUniformItem {
  String name;
  bool isRequired;
  List<MeasurementField> measurementFields;
  
  FirebaseUniformItem({
    required this.name,
    this.isRequired = true,
    List<MeasurementField>? measurementFields,
  }) : measurementFields = measurementFields ?? [];

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isRequired': isRequired,
      'measurementFields': measurementFields.map((field) => field.toMap()).toList(),
    };
  }

  factory FirebaseUniformItem.fromMap(Map<String, dynamic> map) {
    return FirebaseUniformItem(
      name: map['name'],
      isRequired: map['isRequired'] ?? true,
      measurementFields: List<MeasurementField>.from(
        (map['measurementFields'] as List?)?.map((x) => MeasurementField.fromMap(x)) ?? [],
      ),
    );
  }
}

class FirebasePosition {
  final String title;
  final Map<String, List<FirebaseUniformItem>> uniformItemsByGender;

  FirebasePosition({
    required this.title,
    required this.uniformItemsByGender,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'uniformItemsByGender': uniformItemsByGender.map(
        (key, value) => MapEntry(
          key,
          value.map((item) => item.toMap()).toList(),
        ),
      ),
    };
  }

  factory FirebasePosition.fromMap(Map<String, dynamic> map) {
    return FirebasePosition(
      title: map['title'],
      uniformItemsByGender: Map<String, List<FirebaseUniformItem>>.from(
        (map['uniformItemsByGender'] as Map).map(
          (key, value) => MapEntry(
            key,
            List<FirebaseUniformItem>.from(
              (value as List).map((x) => FirebaseUniformItem.fromMap(x))),
          ),
        ),
    ));
  }
}

// Firebase Service
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCategory(String categoryName) async {
    await _firestore.collection('categories').doc(categoryName).set(
      FirebaseCategory(
        name: categoryName,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }

  Future<List<String>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> addPosition(String category, FirebasePosition position) async {
    await _firestore
        .collection('categories')
        .doc(category)
        .collection('positions')
        .doc(position.title)
        .set(position.toMap());
  }

  Future<void> updatePosition(String category, FirebasePosition position) async {
    await _firestore
        .collection('categories')
        .doc(category)
        .collection('positions')
        .doc(position.title)
        .update(position.toMap());
  }

  Future<List<FirebasePosition>> getPositionsByCategory(String category) async {
    final snapshot = await _firestore
        .collection('categories')
        .doc(category)
        .collection('positions')
        .get();
    return snapshot.docs
        .map((doc) => FirebasePosition.fromMap(doc.data()!))
        .toList();
  }

  Future<void> deleteCategory(String categoryName) async {
    await _firestore.collection('categories').doc(categoryName).delete();
  }

  Future<void> deletePosition(String category, String positionTitle) async {
    await _firestore
        .collection('categories')
        .doc(category)
        .collection('positions')
        .doc(positionTitle)
        .delete();
  }
}

// Screens
class AddCategoryScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Add New Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  await firebaseService.addCategory(_controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Save Category'),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewCategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddCategoryScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: firebaseService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No categories found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final category = snapshot.data![index];
              return ListTile(
                title: Text(category),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PositionListScreen(category: category),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await firebaseService.deleteCategory(category);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Category deleted')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PositionListScreen extends StatelessWidget {
  final String category;

  const PositionListScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPositionScreen(category: category),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<FirebasePosition>>(
        future: firebaseService.getPositionsByCategory(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No positions found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final position = snapshot.data![index];
              return ListTile(
                title: Text(position.title),
                subtitle: Text('Items: ${position.uniformItemsByGender.values.expand((x) => x).length}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PositionDetailScreen(
                      category: category,
                      position: position,
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditPositionScreen(
                            category: category,
                            position: position,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await firebaseService.deletePosition(category, position.title);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Position deleted')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PositionDetailScreen extends StatelessWidget {
  final String category;
  final FirebasePosition position;

  const PositionDetailScreen({
    required this.category,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(position.title)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddItemsToPositionScreen(
              category: category,
              position: position,
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: position.uniformItemsByGender.keys.length,
        child: Column(
          children: [
            TabBar(
              tabs: position.uniformItemsByGender.keys
                  .map((gender) => Tab(text: gender))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                children: position.uniformItemsByGender.entries
                    .map((entry) => _buildGenderItems(entry.value))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderItems(List<FirebaseUniformItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ExpansionTile(
          title: Text(item.name),
          subtitle: Text(item.isRequired ? 'Required' : 'Optional'),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Measurement Fields:', 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...item.measurementFields.map((field) => ListTile(
                    title: Text(field.name),
                    subtitle: Text(field.unit),
                  )).toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class AddPositionScreen extends StatefulWidget {
  final String category;

  const AddPositionScreen({required this.category});

  @override
  _AddPositionScreenState createState() => _AddPositionScreenState();
}

class _AddPositionScreenState extends State<AddPositionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Position')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Position Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              SizedBox(height: 20),
              Text('Select Gender:', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: _selectedGender,
                    onChanged: (value) => setState(() => _selectedGender = value),
                  ),
                  Text('Male'),
                  SizedBox(width: 20),
                  Radio<String>(
                    value: 'Female',
                    groupValue: _selectedGender,
                    onChanged: (value) => setState(() => _selectedGender = value),
                  ),
                  Text('Female'),
                ],
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedGender != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddUniformItemsScreen(
                          category: widget.category,
                          positionTitle: _titleController.text,
                          gender: _selectedGender!,
                          existingItems: [], // Initialize with empty list for new position
                        ),
                      ),
                    );
                  }
                },
                child: Text('Next: Add Uniform Items'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddItemsToPositionScreen extends StatefulWidget {
  final String category;
  final FirebasePosition position;

  const AddItemsToPositionScreen({
    required this.category,
    required this.position,
  });

  @override
  _AddItemsToPositionScreenState createState() => _AddItemsToPositionScreenState();
}

class _AddItemsToPositionScreenState extends State<AddItemsToPositionScreen> {
  final TextEditingController _genderController = TextEditingController();
  final List<FirebaseUniformItem> _newItems = [];

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final genders = ['Male', 'Female'].toList();

    return Scaffold(
      appBar: AppBar(title: Text('Add Items to ${widget.position.title}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: genders.isNotEmpty ? genders.first : null,
              items: genders.map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _genderController.text = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Gender',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _newItems.length,
              itemBuilder: (context, index) {
                final item = _newItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.measurementFields.length} measurement fields'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _newItems.removeAt(index)),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMeasurementFieldsScreen(
                        item: item,
                        onSave: (updatedItem) {
                          setState(() {
                            _newItems[index] = updatedItem;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addNewItem(context),
                    child: Text('Add New Item'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveItems,
                    child: Text('Save Items'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewItem(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add New Item'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, controller.text);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final newItem = FirebaseUniformItem(name: result);
      setState(() => _newItems.add(newItem));
    }
  }

  void _saveItems() async {
    if (_newItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    if (_genderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a gender')),
      );
      return;
    }

    // Create a copy of the current position
    final updatedPosition = FirebasePosition(
      title: widget.position.title,
      uniformItemsByGender: Map.from(widget.position.uniformItemsByGender),
    );

    // Add the new items to the selected gender
    if (updatedPosition.uniformItemsByGender.containsKey(_genderController.text)) {
      updatedPosition.uniformItemsByGender[_genderController.text]!.addAll(_newItems);
    } else {
      updatedPosition.uniformItemsByGender[_genderController.text] = _newItems;
    }

    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    await firebaseService.updatePosition(widget.category, updatedPosition);
    Navigator.pop(context);
  }
}

class EditPositionScreen extends StatefulWidget {
  final String category;
  final FirebasePosition position;

  const EditPositionScreen({
    required this.category,
    required this.position,
  });

  @override
  _EditPositionScreenState createState() => _EditPositionScreenState();
}

class _EditPositionScreenState extends State<EditPositionScreen> {
  late TextEditingController _titleController;
  late FirebasePosition _editedPosition;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.position.title);
    _editedPosition = FirebasePosition(
      title: widget.position.title,
      uniformItemsByGender: Map.from(widget.position.uniformItemsByGender),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Position'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              if (_titleController.text.isNotEmpty) {
                _editedPosition = FirebasePosition(
                  title: _titleController.text,
                  uniformItemsByGender: _editedPosition.uniformItemsByGender,
                );
                
                await firebaseService.updatePosition(
                  widget.category, 
                  _editedPosition,
                );
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Position updated')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Position Name'),
            ),
            SizedBox(height: 20),
            ..._editedPosition.uniformItemsByGender.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key} Uniform Items:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...entry.value.map((item) {
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.measurementFields.length} measurement fields'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _editedPosition.uniformItemsByGender[entry.key]!
                                .remove(item);
                          });
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddMeasurementFieldsScreen(
                            item: item,
                            onSave: (updatedItem) {
                              setState(() {
                                final index = _editedPosition
                                    .uniformItemsByGender[entry.key]!
                                    .indexOf(item);
                                _editedPosition.uniformItemsByGender[entry.key]!
                                    [index] = updatedItem;
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddUniformItemsScreen(
                            category: widget.category,
                            positionTitle: _editedPosition.title,
                            gender: entry.key,
                            existingItems: _editedPosition.uniformItemsByGender[entry.key]!,
                          ),
                        ),
                      ).then((newItems) {
                        if (newItems != null) {
                          setState(() {
                            _editedPosition.uniformItemsByGender[entry.key] = newItems;
                          });
                        }
                      });
                    },
                    child: Text('Add Items to ${entry.key}'),
                  ),
                  Divider(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class AddUniformItemsScreen extends StatefulWidget {
  final String category;
  final String positionTitle;
  final String gender;
  final List<FirebaseUniformItem> existingItems;

  const AddUniformItemsScreen({
    required this.category,
    required this.positionTitle,
    required this.gender,
    required this.existingItems,
  });

  @override
  _AddUniformItemsScreenState createState() => _AddUniformItemsScreenState();
}

class _AddUniformItemsScreenState extends State<AddUniformItemsScreen> {
  late List<FirebaseUniformItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.existingItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Uniform Items')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('${item.measurementFields.length} measurement fields'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _items.removeAt(index)),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMeasurementFieldsScreen(
                        item: item,
                        onSave: (updatedItem) {
                          setState(() {
                            _items[index] = updatedItem;
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addNewItem(context),
                    child: Text('Add New Item'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _items);
                    },
                    child: Text('Save Items'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewItem(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add New Item'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, controller.text);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final newItem = FirebaseUniformItem(name: result);
      setState(() => _items.add(newItem));
    }
  }
}

class AddMeasurementFieldsScreen extends StatefulWidget {
  final FirebaseUniformItem item;
  final Function(FirebaseUniformItem) onSave;

  const AddMeasurementFieldsScreen({
    required this.item,
    required this.onSave,
  });

  @override
  _AddMeasurementFieldsScreenState createState() => _AddMeasurementFieldsScreenState();
}

class _AddMeasurementFieldsScreenState extends State<AddMeasurementFieldsScreen> {
  late FirebaseUniformItem _currentItem;
  final TextEditingController _fieldNameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentItem = FirebaseUniformItem(
      name: widget.item.name,
      isRequired: widget.item.isRequired,
      measurementFields: List.from(widget.item.measurementFields),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Measurement Fields for ${_currentItem.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.onSave(_currentItem);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fieldNameController,
                    decoration: InputDecoration(labelText: 'Field Name'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: InputDecoration(labelText: 'Unit (e.g., inches)'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_fieldNameController.text.isNotEmpty && 
                        _unitController.text.isNotEmpty) {
                      setState(() {
                        _currentItem.measurementFields.add(
                          MeasurementField(
                            name: _fieldNameController.text,
                            unit: _unitController.text,
                          ),
                        );
                        _fieldNameController.clear();
                        _unitController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _currentItem.measurementFields.length,
              itemBuilder: (context, index) {
                final field = _currentItem.measurementFields[index];
                return ListTile(
                  title: Text(field.name),
                  subtitle: Text(field.unit),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() {
                      _currentItem.measurementFields.removeAt(index);
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
