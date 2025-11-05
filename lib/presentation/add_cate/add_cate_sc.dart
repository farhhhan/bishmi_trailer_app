
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
      'measurementFields':
          measurementFields.map((field) => field.toMap()).toList(),
    };
  }

  factory FirebaseUniformItem.fromMap(Map<String, dynamic> map) {
    return FirebaseUniformItem(
      name: map['name'],
      isRequired: map['isRequired'] ?? true,
      measurementFields: List<MeasurementField>.from(
        (map['measurementFields'] as List?)
                ?.map((x) => MeasurementField.fromMap(x)) ??
            [],
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

  Future<void> updatePosition(
      String category, FirebasePosition position) async {
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
class AddCategoryScreen extends StatefulWidget {
  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isClicked = false;
  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1AB6BB), Color(0xFF1983A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: const Text(
            'Add New Category',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Full background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDF6E3), Color(0xFFE3F6F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Centered card
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Category Name',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Enter category name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: isClicked
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Icon(Icons.save),
                          label: const Text('Save Category'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1AB6BB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: isClicked
                              ? null
                              : () async {
                                  setState(() {
                                    isClicked = true;
                                  });
                                  if (_controller.text.isNotEmpty) {
                                    await firebaseService
                                        .addCategory(_controller.text);
                                    Navigator.pop(context, _controller.text);
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ViewCategoriesScreen extends StatefulWidget {
  @override
  State<ViewCategoriesScreen> createState() => _ViewCategoriesScreenState();
}

class _ViewCategoriesScreenState extends State<ViewCategoriesScreen> {
  List<String>? _categories;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    final cats = await firebaseService.getCategories();
    setState(() {
      _categories = cats;
      _loading = false;
    });
  }

  void _deleteCategory(String category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Do you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _categories?.remove(category);
      });
      final firebaseService =
          Provider.of<FirebaseService>(context, listen: false);
      await firebaseService.deleteCategory(category);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1AB6BB), Color(0xFF1983A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: const Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF6E3), Color(0xFFE3F6F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_categories == null || _categories!.isEmpty)
                ? const Center(child: Text('No categories found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _categories!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final category = _categories![index];
                      return Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.category,
                              color: Color(0xFF1AB6BB)),
                          title: Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1983A3),
                            ),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PositionListScreen(category: category),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(category),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class PositionListScreen extends StatefulWidget {
  final String category;

  const PositionListScreen({required this.category});

  @override
  State<PositionListScreen> createState() => _PositionListScreenState();
}

class _PositionListScreenState extends State<PositionListScreen> {
  List<FirebasePosition>? _positions;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPositions();
  }

  Future<void> _fetchPositions() async {
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    final pos = await firebaseService.getPositionsByCategory(widget.category);
    setState(() {
      _positions = pos;
      _loading = false;
    });
  }

  void _deletePosition(FirebasePosition position) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${position.title}'),
        content: Text('Do you want to delete this ${position.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _positions?.remove(position);
      });
      final firebaseService =
          Provider.of<FirebaseService>(context, listen: false);
      await firebaseService.deletePosition(widget.category, position.title);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position deleted')),
      );
    }
  }

  void _navigateToAddPosition() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPositionScreen(category: widget.category),
      ),
    );
    _fetchPositions();
  }

  void _navigateToEditPosition(FirebasePosition position) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPositionScreen(
          category: widget.category,
          position: position,
        ),
      ),
    );
    _fetchPositions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1AB6BB), Color(0xFF1983A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: Text(
            widget.category,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Full background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDF6E3), Color(0xFFE3F6F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Centered content
          _loading
              ? const Center(child: CircularProgressIndicator())
              : (_positions == null || _positions!.isEmpty)
                  ? const Center(child: Text('No positions found'))
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _positions!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final position = _positions![index];
                            return Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.work_outline,
                                    color: Color(0xFF1AB6BB)),
                                title: Text(
                                  position.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF1983A3),
                                  ),
                                ),
                                subtitle: Text(
                                  'Items: ${position.uniformItemsByGender.values.expand((x) => x).length}',
                                  style:
                                      const TextStyle(color: Color(0xFF1983A3)),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PositionDetailScreen(
                                      category: widget.category,
                                      position: position,
                                      isaddbutton: false,
                                    ),
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Color(0xFF1AB6BB)),
                                      onPressed: () =>
                                          _navigateToEditPosition(position),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deletePosition(position),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1AB6BB),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _navigateToAddPosition,
      ),
    );
  }
}

class PositionDetailScreen extends StatelessWidget {
  final String category;
  final FirebasePosition position;
  final bool isaddbutton;

  const PositionDetailScreen({
    required this.category,
    required this.position,
    required this.isaddbutton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1AB6BB), Color(0xFF1983A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: Text(
            position.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      floatingActionButton: isaddbutton
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF1AB6BB),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddItemsToPositionScreen(
                    category: category,
                    position: position,
                  ),
                ),
              ).then((_) {
                Provider.of<FirebaseService>(context, listen: false)
                    .getPositionsByCategory(category);
              }),
            )
          : null,
      body: Stack(
        children: [
          // Full background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDF6E3), Color(0xFFE3F6F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    child: DefaultTabController(
                      length: position.uniformItemsByGender.keys.length,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TabBar(
                            labelColor: const Color(0xFF1AB6BB),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: const Color(0xFF1AB6BB),
                            tabs: position.uniformItemsByGender.keys
                                .map((gender) => Tab(text: gender))
                                .toList(),
                          ),
                          SizedBox(
                            height: 400, // Ensures enough space for TabBarView
                            child: TabBarView(
                              children: position.uniformItemsByGender.entries
                                  .map(
                                      (entry) => _buildGenderItems(entry.value))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderItems(List<FirebaseUniformItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No items for this gender'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color:
                            item.isRequired ? Color(0xFF1AB6BB) : Colors.grey,
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1983A3)),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.isRequired
                            ? const Color(0xFF1AB6BB).withOpacity(0.1)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.isRequired ? 'Required' : 'Optional',
                        style: TextStyle(
                          color: item.isRequired
                              ? const Color(0xFF1AB6BB)
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (item.measurementFields.isNotEmpty) ...[
                  const Text('Measurement Fields:',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  ...item.measurementFields.map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.straighten,
                                size: 16, color: Color(0xFF1AB6BB)),
                            const SizedBox(width: 6),
                            Text(
                              field.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${field.unit})',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
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

  bool isClicked = false;
  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1AB6BB), Color(0xFF1983A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: const Text(
            'Add Item',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFDF6E3), Color(0xFFE3F6F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Position Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                            const SizedBox(height: 24),
                            const Text('Select Gender:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio<String>(
                                  value: 'Male',
                                  groupValue: _selectedGender,
                                  onChanged: (value) =>
                                      setState(() => _selectedGender = value),
                                ),
                                const Text('Male'),
                                const SizedBox(width: 20),
                                Radio<String>(
                                  value: 'Female',
                                  groupValue: _selectedGender,
                                  onChanged: (value) =>
                                      setState(() => _selectedGender = value),
                                ),
                                const Text('Female'),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: isClicked
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Icon(Icons.save),
                                label: const Text('Save Position'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1AB6BB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: isClicked
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate() &&
                                            _selectedGender != null) {
                                          setState(() {
                                            isClicked = true;
                                          });
                                          final newPosition = FirebasePosition(
                                            title: _titleController.text,
                                            uniformItemsByGender: {
                                              _selectedGender!: []
                                            },
                                          );
                                          await firebaseService.addPosition(
                                            widget.category,
                                            newPosition,
                                          );
                                          // Navigator.pushReplacement(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (_) => PositionDetailScreen(
                                          //       category: widget.category,
                                          //       position: newPosition,
                                          //       isaddbutton: true,
                                          //     ),
                                          //   ),
                                          // );
                                          Navigator.pop(context);
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
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
  _AddItemsToPositionScreenState createState() =>
      _AddItemsToPositionScreenState();
}

class _AddItemsToPositionScreenState extends State<AddItemsToPositionScreen> {
  final TextEditingController _genderController = TextEditingController();
  final List<FirebaseUniformItem> _newItems = [];

  @override
  void initState() {
    super.initState();
    _genderController.text = widget.position.uniformItemsByGender.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final genders = widget.position.uniformItemsByGender.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Items to ${widget.position.title}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _genderController.text,
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
                  subtitle: Text(
                      '${item.measurementFields.length} measurement fields'),
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
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PositionListScreen(
                            category: widget.category,
                          ),
                        ),
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                      );
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

    // Create a copy of the current position
    final updatedPosition = FirebasePosition(
      title: widget.position.title,
      uniformItemsByGender: Map.from(widget.position.uniformItemsByGender),
    );

    // Add the new items to the selected gender
    if (updatedPosition.uniformItemsByGender
        .containsKey(_genderController.text)) {
      updatedPosition.uniformItemsByGender[_genderController.text]!
          .addAll(_newItems);
    } else {
      updatedPosition.uniformItemsByGender[_genderController.text] = _newItems;
    }

    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1AB6BB), Color(0xFF1983A3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          title: const Text(
            'Edit Position',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
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
                    const SnackBar(content: Text('Position updated')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Full background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDF6E3), Color(0xFFE3F6F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Position Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                hintText: 'Enter position name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._editedPosition.uniformItemsByGender.entries
                        .map((entry) {
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key} Uniform Items:',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1983A3)),
                              ),
                              const SizedBox(height: 10),
                              ...entry.value.map((item) {
                                return Card(
                                  elevation: 1,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    leading: const Icon(Icons.check_box,
                                        color: Color(0xFF1AB6BB)),
                                    title: Text(
                                      item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1983A3)),
                                    ),
                                    subtitle: Text(
                                      '${item.measurementFields.length} measurement fields',
                                      style: const TextStyle(
                                          color: Color(0xFF1983A3)),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _editedPosition
                                              .uniformItemsByGender[entry.key]!
                                              .remove(item);
                                        });
                                      },
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddMeasurementFieldsScreen(
                                          item: item,
                                          onSave: (updatedItem) {
                                            setState(() {
                                              final idx = _editedPosition
                                                  .uniformItemsByGender[
                                                      entry.key]!
                                                  .indexOf(item);
                                              _editedPosition
                                                          .uniformItemsByGender[
                                                      entry.key]![idx] =
                                                  updatedItem;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                label: Text('Add Items to ${entry.key}'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1AB6BB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => AddUniformItemsScreen(
                                  //       category: widget.category,
                                  //       positionTitle: _editedPosition.title,
                                  //       gender: entry.key,
                                  //       existingItems: _editedPosition
                                  //           .uniformItemsByGender[entry.key]!,
                                  //     ),
                                  //   ),
                                  // ).then((newItems) {
                                  //   if (newItems != null) {
                                  //     setState(() {
                                  //       _editedPosition.uniformItemsByGender[
                                  //           entry.key] = newItems;
                                  //     });
                                  //   }
                                  // });
                                  _addNewItem(context, entry.key);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewItem(BuildContext context, String genderKey) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded edges
          ),
          title: Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                'Add New Item',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Item Name',
              labelStyle: TextStyle(color: Colors.deepPurple),
              prefixIcon:
                  Icon(Icons.shopping_bag_outlined, color: Colors.deepPurple),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.deepPurple.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.deepPurple, width: 2),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close, color: Colors.grey),
              label: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, controller.text);
                }
              },
              icon: Icon(Icons.check_circle, color: Colors.white),
              label: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final newItem = FirebaseUniformItem(name: result);
      setState(() {
        _editedPosition.uniformItemsByGender[genderKey]!.add(newItem);
      });
    }
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
      appBar: AppBar(
        title: Text('Manage Uniform Items'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                      '${item.measurementFields.length} measurement fields'),
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
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  _AddMeasurementFieldsScreenState createState() =>
      _AddMeasurementFieldsScreenState();
}

class _AddMeasurementFieldsScreenState
    extends State<AddMeasurementFieldsScreen> {
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

  void _addField() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Measurement Fields",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Color(0xFF1AB6BB)),
            onPressed: () {
              widget.onSave(_currentItem);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fieldNameController,
                        decoration: InputDecoration(
                          labelText: "Field Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: InputDecoration(
                          labelText: "Unit (e.g., inches)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Color(0xFF1AB6BB),
                      child: IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: _addField,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _currentItem.measurementFields.isEmpty
                  ? Center(
                      child: Text(
                        "No fields added yet",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _currentItem.measurementFields.map((field) {
                        return Chip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          label: Text(
                            "${field.name} (${field.unit})",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color(0xFF1AB6BB),
                          deleteIcon: Icon(Icons.close, color: Colors.black),
                          onDeleted: () {
                            setState(() {
                              _currentItem.measurementFields.remove(field);
                            });
                          },
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
