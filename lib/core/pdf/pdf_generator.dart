import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:bishmi_app/core/hive_model/company_model.dart';
class PdfGenerator {
Future<Uint8List> generateRestaurantPdf(Restaurant restaurant) async {
  final pdf = pw.Document();

  // Colors
  final gold = PdfColor.fromInt(0xFFF2C166);
  final shirtColor = PdfColor.fromInt(0xFFFDF3E3);
  final pantColor = PdfColor.fromInt(0xFFE6F6EC);
  final topColor = PdfColor.fromInt(0xFFEDEBFA);
  final ladiesPantColor = PdfColor.fromInt(0xFFF5E6F6);

  pw.Widget categoryChip(String label, int count, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const pw.EdgeInsets.only(right: 8),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Text('$label  $count', style: pw.TextStyle(fontSize: 12)),
    );
  }

  pw.Widget sectionHeader(String label, int count, PdfColor color) {
    return pw.Container(
      width: double.infinity,
      color: color,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: pw.Row(
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Spacer(),
          pw.Text(count.toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget employeeTable(List<Employee> employees) {
    return pw.Table.fromTextArray(
      headers: ['Id', 'Name', 'Qnt', 'Length', 'Shoulder', 'Sleeve', 'Bicep'],
      data: employees.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final e = entry.value;
        return [
          i.toString(),
          e.name,
          '1', // Quantity placeholder
          e.position ?? '',
          e.gender ?? '',
          e.name ?? '',
          e.uniformConfig ?? '',
        ];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      border: null,
    );
  }

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(24),
      build: (context) => [
        // Header
        pw.Container(
          width: double.infinity,
          color: gold,
          padding: const pw.EdgeInsets.symmetric(vertical: 12),
          child: pw.Center(
            child: pw.Text('REPORT', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
        ),
        pw.SizedBox(height: 16),

        // Restaurant Info
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Restaurant Name :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(restaurant.name, style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 4),
                  pw.Text('Location :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(restaurant.address ?? 'N/A', style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 4),
                  pw.Text('Date :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(restaurant.date, style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 4),
                  pw.Text('Deadline :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(restaurant.date ?? '', style: pw.TextStyle(fontSize: 14, color: PdfColors.red)),
                  pw.SizedBox(height: 4),
                  pw.Text('Total person :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${restaurant.employees.length}', style: pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),

        // Categories
        pw.Row(
          children: [
            categoryChip('Shirt', 800, shirtColor),
            categoryChip('Pant', 40, pantColor),
            categoryChip('Top', 300, topColor),
            categoryChip('Ladies pant', 300, ladiesPantColor),
          ],
        ),
        pw.SizedBox(height: 16),

        // Example: Shirt Section
        sectionHeader('Shirt', 800, shirtColor),
        employeeTable(restaurant.employees), // Filter for shirt if needed

        // Example: Pant Section
        sectionHeader('Pant', 40, pantColor),
        employeeTable(restaurant.employees), // Filter for pant if needed

        // Add more sections as needed...
      ],
    ),
  );

  return pdf.save();
} }