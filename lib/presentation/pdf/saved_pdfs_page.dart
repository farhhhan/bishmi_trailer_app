import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SavedPdfsPage extends StatefulWidget {
  const SavedPdfsPage({Key? key}) : super(key: key);

  @override
  State<SavedPdfsPage> createState() => _SavedPdfsPageState();
}

class _SavedPdfsPageState extends State<SavedPdfsPage> {
  late Box pdfBox;
  List<String> pdfKeys = [];
  final TextEditingController _searchController = TextEditingController();
  bool _last7Days=false;
  DateTimeRange ? _dateRange;
  List<String> _filteredKeys = [];
  bool _filtersAppliedOnce = false;
  DateTime? _singleDate;

  DateTime? _parseDateFromFileName(String name) {
    final lower = name.toLowerCase();
    final ddmmyy = RegExp(r'(?:_|\b)(\d{1,2})-(\d{1,2})-(\d{2,4})(?:_|\b|\.)');
    final m1 = ddmmyy.firstMatch(lower);
    if (m1 != null) {
      final d = int.tryParse(m1.group(1)!);
      final m = int.tryParse(m1.group(2)!);
      final yRaw = int.tryParse(m1.group(3)!);
      if (d != null && m != null && yRaw != null) {
        final y = yRaw < 100 ? 2000 + yRaw : yRaw;
        return DateTime.tryParse('${y.toString().padLeft(4,'0')}-${m.toString().padLeft(2,'0')}-${d.toString().padLeft(2,'0')}');
      }
    }
    final yyyymmdd = RegExp(r'(?:_|\b)(\d{4})-(\d{1,2})-(\d{1,2})(?:_|\b|\.)');
    final m2 = yyyymmdd.firstMatch(lower);
    if (m2 != null) {
      final y = int.tryParse(m2.group(1)!);
      final m = int.tryParse(m2.group(2)!);
      final d = int.tryParse(m2.group(3)!);
      if (d != null && m != null && y != null) {
        return DateTime.tryParse('${y.toString().padLeft(4,'0')}-${m.toString().padLeft(2,'0')}-${d.toString().padLeft(2,'0')}');
      }
    }
    return null;
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7Start = today.subtract(const Duration(days: 6));

    List<String> keys = List<String>.from(pdfKeys);
    if (query.isNotEmpty) {
      keys = keys.where((k) => k.toLowerCase().contains(query)).toList();
    }
    if (_last7Days || _dateRange != null || _singleDate != null) {
      keys = keys.where((k) {
        final dt = _parseDateFromFileName(k);
        if (dt == null) return false;
        final day = DateTime(dt.year, dt.month, dt.day);
        if (_singleDate != null) {
          final sd = DateTime(_singleDate!.year, _singleDate!.month, _singleDate!.day);
          if (day != sd) return false;
        }
        if (_dateRange != null) {
          final s = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
          final e = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);
          if (day.isBefore(s) || day.isAfter(e)) return false;
        }
        if (_last7Days) {
          if (day.isBefore(last7Start) || day.isAfter(today)) return false;
        }
        return true;
      }).toList();
    }
    setState(() {
      _filteredKeys = keys..sort();
      _filtersAppliedOnce = true;
    });
  }

  Future<void> _pickDateRange() async {
    final initialRange = _dateRange ?? DateTimeRange(start: DateTime.now().subtract(const Duration(days: 6)), end: DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDateRange: initialRange,
    );
    if (picked != null) {
      setState(() { _dateRange = picked; });
      // Clear single date if range picked
      if (_singleDate != null) _singleDate = null;
      _applyFilters();
    }
  }

  Future<void> _pickSingleDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _singleDate ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) {
      setState(() { _singleDate = picked; _dateRange = null; });
      _applyFilters();
    }
  }

  @override
  void initState() {
    super.initState();
    pdfBox = Hive.box('pdfs');
    pdfKeys = pdfBox.keys.cast<String>().toList();
    _filteredKeys=List<String>.from(pdfKeys);
    _searchController.addListener(_applyFilters);
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF2C166);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Saved PDFs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: pdfKeys.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color.fromARGB(255, 234, 192, 134),width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 64,
                      color: gold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'No saved PDFs found.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your locally saved PDFs will appear here.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by customer name',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAEAEA), width: 1)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAEAEA), width: 1)),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFFF2C166), width: 2),
                      ),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SizedBox(
                    height: 40,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            selected: _last7Days,
                            showCheckmark: false,
                            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            label: const Text('Last 7 days'),
                            side: BorderSide(color: _last7Days ? const Color(0xFFF2C166) : const Color(0xFFEAEAEA), width: 1.2),
                            selectedColor: const Color(0xFFFFF3D6),
                            onSelected: (sel) {
                              setState(() { _last7Days = sel; });
                              _applyFilters();
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          const SizedBox(width: 8),
                          InputChip(
                            avatar: const Icon(Icons.event, size: 18, color: Colors.black87),
                            label: Text(
                              _singleDate == null
                                  ? 'Single date'
                                  : '${_singleDate!.day}-${_singleDate!.month}-${_singleDate!.year}'
                            ),
                            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            selected: _singleDate != null,
                            selectedColor: const Color(0xFFFFF3D6),
                            showCheckmark: false,
                            side: BorderSide(color: (_singleDate != null) ? const Color(0xFFF2C166) : const Color(0xFFEAEAEA), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onPressed: _pickSingleDate,
                            onDeleted: _singleDate != null ? () { setState(() { _singleDate = null; }); _applyFilters(); } : null,
                          ),
                          const SizedBox(width: 8),
                          InputChip(
                            avatar: const Icon(Icons.date_range, size: 18, color: Colors.black87),
                            label: Text(
                              _dateRange == null
                                  ? 'Date range'
                                  : '${_dateRange!.start.day}-${_dateRange!.start.month}-${_dateRange!.start.year}  to  ${_dateRange!.end.day}-${_dateRange!.end.month}-${_dateRange!.end.year}'
                            ),
                            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            selected: _dateRange != null,
                            selectedColor: const Color(0xFFFFF3D6),
                            showCheckmark: false,
                            side: BorderSide(color: (_dateRange != null) ? const Color(0xFFF2C166) : const Color(0xFFEAEAEA), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onPressed: _pickDateRange,
                            onDeleted: _dateRange != null ? () { setState(() { _dateRange = null; }); _applyFilters(); } : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final visibleKeys = (_filtersAppliedOnce ? _filteredKeys : pdfKeys);
                      if (visibleKeys.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 56, color: Color(0xFFE0E0E0)),
                              const SizedBox(height: 12),
                              const Text(
                                'No PDFs found',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _filtersAppliedOnce ? 'Try changing your search or date filters.' : 'Your locally saved PDFs will appear here.',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        itemCount: visibleKeys.length,
                        itemBuilder: (context, index) {
                          final fileName = visibleKeys[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 40)),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 6,
                    color: Colors.white,
                    shadowColor: Colors.black12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Color(0xFFEAC086), width: 1.2),
                      ),
                      constraints: const BoxConstraints(minHeight: 92, minWidth: double.infinity),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: gold,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (_) {
                                    final dt = _parseDateFromFileName(fileName);
                                    return Text(
                                      dt == null ? 'Unknown date' : '${dt.day.toString().padLeft(2,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.year}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.white, size: 20),
                            tooltip: 'Preview',
                            onPressed: () async {
                              final pdfBytes = pdfBox.get(fileName) as List<int>?;
                              if (pdfBytes != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PdfViewOnlyPage(
                                      pdfBytes: Uint8List.fromList(pdfBytes),
                                      fileName: fileName,
                                    ),
                                  ),
                                );
                              }
                            },
                            splashRadius: 24,
                            color: Colors.white,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xFFF2C166)),
                              shape: MaterialStateProperty.all(CircleBorder()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEAC086)),
                            tooltip: 'Delete',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete PDF'),
                                  content: Text('Are you sure you want to delete "$fileName"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete', style: TextStyle(color: Color(0xFFEAC086))),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await pdfBox.delete(fileName);
                                setState(() {
                                  pdfKeys.remove(fileName);
                                  _filteredKeys.remove(fileName);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class PdfViewOnlyPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfViewOnlyPage({required this.pdfBytes, required this.fileName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
} 