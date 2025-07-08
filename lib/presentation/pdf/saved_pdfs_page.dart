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

  @override
  void initState() {
    super.initState();
    pdfBox = Hive.box('pdfs');
    pdfKeys = pdfBox.keys.cast<String>().toList();
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
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              itemCount: pdfKeys.length,
              itemBuilder: (context, index) {
                final fileName = pdfKeys[index];
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
                        border: Border.all(color: Color(0xFFEAC086), width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: gold,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                                  pdfKeys.removeAt(index);
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