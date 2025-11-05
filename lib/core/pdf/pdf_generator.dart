import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:collection/collection.dart';

import '../hive_model/company_model.dart';
import 'drive_upload.dart';


//mm
class PdfGenerator {
Future<Uint8List> generateRestaurantPdf(
  Restaurant restaurant, {
  Map<String, dynamic>? serviceAccountJson,
  String? driveFolderId,
  bool uploadToDrive = false,
  Map<String, dynamic>? currentUserData,
}) async {
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

  pw.Widget sectionHeader(String label, int count, PdfColor color, {required String category}) {
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

pw.Widget employeeTable(List<Employee> employees, String itemName, PdfColor color) {
    // Gather all unique measurement fields for this item from all employees
    final Set<String> measurementFields = {};
    for (final e in employees) {
      final config = e.uniformConfig.firstWhereOrNull(
        (c) => c.itemName == itemName && c.isNeeded,
      );
      if (config != null && config.measurements.isNotEmpty) {
        measurementFields.addAll(config.measurements.keys);
      }
    }
    
    // Determine if this is a cap/hat/net or apron
    final lowerItem = itemName.toLowerCase();
    final isCap = lowerItem.contains('cap') || lowerItem.contains('hat') || lowerItem.contains('net');
    final isApron = lowerItem.contains('apron');
    // Dynamic column for type
    String? typeHeader;
    if (isCap) {
      typeHeader = 'Cap Type';
    } else if (isApron) {
      typeHeader = 'Apron Type';
    } else {
      typeHeader = 'Type';
    }
    // Fixed columns
    List<String> fixedHeaders;
    if (isCap || isApron) {
      fixedHeaders = ['Sl', 'Name', 'Qnt', typeHeader, 'Size', 'Material', 'Gender'];
    } else {
      fixedHeaders = ['Sl', 'Name', 'Qnt', 'Type', 'Size', 'Material', 'Gender'];
    }
    // Dynamic measurement columns
       // Dynamic measurement columns
    final measurementHeaders = measurementFields.toList();
    // All headers combined, Note at the end
    final allHeaders = [...fixedHeaders, ...measurementHeaders, 'Status', 'Note'];

    // Helpers for status color
    PdfColor statusBgColor(String status) {
      final s = status.toLowerCase().trim();
      if (s.contains('delivered')) return PdfColors.green500;
      if (s.contains('stitching completed') || s.contains('stitching complated')) return PdfColors.orange400;
      if (s.contains('material collected') || s.contains('taking material') || s.contains('material')) return PdfColors.yellow500;
      if (s.contains('stitching started') || s.contains('stitching')) return PdfColors.blue500;
      // default: pending
      return PdfColors.red400;
    }

    PdfColor statusTextColor(PdfColor bg) {
      // Choose contrast: dark text on light backgrounds, white on darker
      final darkBg = [PdfColors.green500, PdfColors.orange400, PdfColors.blue500, PdfColors.red400];
      return darkBg.contains(bg) ? PdfColors.white : PdfColors.black;
    }
    // Create column widths map
    final Map<int, pw.TableColumnWidth> columnWidths = {};
    for (int i = 0; i < allHeaders.length; i++) {
      switch (i) {
        case 0: // Sl
          columnWidths[i] = const pw.FixedColumnWidth(25);
          break;
        case 1: // Name
          columnWidths[i] = const pw.FlexColumnWidth(2.5);
          break;
        case 2: // Qnt
          columnWidths[i] = const pw.FixedColumnWidth(30);
          break;
        case 3: // Type/Cap Type/Apron Type
          columnWidths[i] = const pw.FixedColumnWidth(60);
          break;
        case 4: // Size
          columnWidths[i] = const pw.FixedColumnWidth(45);
          break;
        case 5: // Material
          columnWidths[i] = const pw.FlexColumnWidth(2.5);
          break;
        case 6: // Gender
          columnWidths[i] = const pw.FixedColumnWidth(45);
          break;
        default:
          columnWidths[i] = const pw.FixedColumnWidth(55);
          break;
      }
    }
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: color),
          children: allHeaders.map((h) => pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                right: pw.BorderSide(color: PdfColors.white, width: 1),
                left: pw.BorderSide(color: PdfColors.white, width: 1),
                top: pw.BorderSide(color: PdfColors.white, width: 1),
                bottom: pw.BorderSide(color: PdfColors.white, width: 1),
              ),
            ),
            child: pw.Text(
              h, 
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, 
                fontSize: 10,
                color: PdfColors.black,
              ),
              textAlign: pw.TextAlign.center,
            ),
          )).toList(),
        ),
        // Data rows
        ...employees.asMap().entries.map((entry) {
        final i = entry.key + 1;
        final e = entry.value;
          final config = e.uniformConfig.firstWhereOrNull(
            (c) => c.itemName == itemName && c.isNeeded,
          );
          // Alternate row colors - light version of the header color and white
          final rowColor = i % 2 == 0 ? PdfColors.white : color.shade(0.1);
          final List<pw.Widget> rowCells = [];
          // Fixed columns data
          rowCells.addAll([
            // Sl
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
          i.toString(),
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),
            // Name
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
          e.name,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            // Qnt
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
                (e.counts != null && e.counts.trim().isNotEmpty) ? e.counts : '1',
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),
            // Type/Cap Type/Apron Type
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
                isCap
                  ? (config?.capStyle ?? '')
                  : isApron
                    ? (config?.capStyle ?? '')
                    : (config != null ? (config.isReadyMade ? 'Ready Made' : 'Fabric Only') : ''),
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),
            // Size
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
                config?.selectedSize ?? '',
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),
            // Material
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
                config?.materialType ?? '', 
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
            // Gender
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
                e.gender, 
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ]);
          // Measurement columns data
          rowCells.addAll(measurementHeaders.map((field) => 
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
                config?.measurements[field] ?? '',
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ));
          // Status

                    // Status
          final bg = statusBgColor(e.currentStatus);
          final fg = statusTextColor(bg);
          rowCells.add(
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
              decoration: pw.BoxDecoration(
                color: bg,
                border: pw.Border.all(color: PdfColors.white, width: 1),
                borderRadius: pw.BorderRadius.circular(2),
              ),
              child: pw.Text(
                e.currentStatus,
                style: pw.TextStyle(fontSize: 9, color: fg, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
          );
          // Note (last column)
          rowCells.add(
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.white, width: 1),
              ),
              child: pw.Text(
                e.feedBack ?? '',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),
          );
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: rowColor),
            children: rowCells,
          );
        }),
      ],
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
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Left: Restaurant details
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text('Customer Name:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 8),
                    pw.Text(restaurant.name, style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text('Location:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 8),
                    pw.Text(restaurant.address ?? 'N/A', style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text('Deadline:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 8),
                    pw.Text(restaurant.date ?? '', style: pw.TextStyle(fontSize: 14, color: PdfColors.red)),
                  ],
                ),
                 pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text('Contact:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 8),
                    pw.Text('${restaurant.mobile}', style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text('Total Person:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 8),
                    pw.Text('${restaurant.employees.length}', style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            // Right: User details
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  children: [
                    pw.Text('Generated:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      () {
                        final uaeNow = DateTime.now().toUtc().add(const Duration(hours: 4));
                        return '${uaeNow.day.toString().padLeft(2, '0')}/${uaeNow.month.toString().padLeft(2, '0')}/${uaeNow.year} '
                            '${uaeNow.hour.toString().padLeft(2, '0')}:${uaeNow.minute.toString().padLeft(2, '0')}';
                      }(),
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.blueGrey800),
                    ),
                  ],
                ),
                if (currentUserData != null && (currentUserData['username'] != null || currentUserData['employeeId'] != null || currentUserData['email'] != null || currentUserData['phonenumber'] != null)) ...[
                  pw.SizedBox(height: 2),
                  if (currentUserData['username'] != null)
                    pw.Text('Emp Name: ${currentUserData['username']}', style: pw.TextStyle(fontSize: 12)),
                  if (currentUserData['employeeId'] != null)
                    pw.Text('Emp ID: ${currentUserData['employeeId']}', style: pw.TextStyle(fontSize: 12)),
                  if (currentUserData['email'] != null)
                    pw.Text('Email: ${currentUserData['email']}', style: pw.TextStyle(fontSize: 12)),
                  if (currentUserData['phoneNumber'] != null)
                    pw.Text(
                      'Contact: ' +
                        (() {
                          final phone = currentUserData['phoneNumber'].toString();
                          if (phone.startsWith('+971')) {
                            return phone;
                          } else if (phone.startsWith('0')) {
                            return '+971' + phone.substring(1);
                          } else {
                            return '+971$phone';
                          }
                        })(),
                      style: pw.TextStyle(fontSize: 12),
                    ),
                ],
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 12),

        // Group by position: For each position, show chips and tables for items needed by employees in that position
        ...(() {
          // 1. Collect all unique positions
          final positions = restaurant.employees.map((e) => e.position).toSet().toList();
          positions.sort();
          final List<PdfColor> palette = [
            shirtColor,
            pantColor,
            topColor,
            ladiesPantColor,
            PdfColors.blue100,
            PdfColors.green100,
            PdfColors.pink100,
            PdfColors.amber100,
            PdfColors.cyan100,
            PdfColors.deepOrange100,
          ];
          ///
          final List<pw.Widget> positionSections = [];
          for (final position in positions) {
            // Employees for this position
            final positionEmployees = restaurant.employees.where((e) => e.position == position).toList();
            // Map of item -> employees for this position
            final Map<String, List<Employee>> itemEmployees = {};
            for (final employee in positionEmployees) {
              for (final config in employee.uniformConfig) {
                if (config.isNeeded) {
                  itemEmployees.putIfAbsent(config.itemName, () => []);
                  itemEmployees[config.itemName]!.add(employee);
                }
              }
            }
            // Chips for this position
            int colorIndex = 0;
            final chips = <pw.Widget>[];
            // Use fixed item order for chips
            final List<String> itemOrder = () {
              switch (restaurant.category.toLowerCase()) {
                case 'restaurant':
                  return ['Shirt', 'Pant', 'Top', 'Ladies Pant'];
                case 'hotel':
                  return ['Formal Shirt', 'Blazer', 'Formal Pants', 'Name Tag', 'Formal Blouse', 'Formal Skirt/Pants'];
                case 'hospital':
                  return ['Lab Coat', 'Scrubs', 'Stethoscope', 'Nursing Uniform', 'Nursing Cap', 'Watch'];
                case 'school':
                  return ['Formal Shirt', 'Formal Pants', 'Blazer (Optional)', 'Formal Blouse', 'Formal Skirt/Pants', 'Name Tag'];
                case 'office':
                  return ['Formal Shirt', 'Suit Jacket', 'Formal Pants', 'Tie', 'Formal Blouse', 'Suit Jacket', 'Formal Skirt/Pants', 'Scarf/Neckpiece', 'Company Polo Shirt', 'Casual Pants', 'Casual Skirt/Pants'];
                default:
                  return itemEmployees.keys.toList();
              }
            }();
            for (final item in itemOrder) {
              final employees = itemEmployees[item];
              if (employees != null && employees.isNotEmpty) {
                final color = palette[colorIndex % palette.length];
                colorIndex++;
                final count = employees.fold<int>(0, (sum, e) => sum + (int.tryParse((e.counts != null && e.counts.trim().isNotEmpty) ? e.counts : '1') ?? 1));
                chips.add(categoryChip(item, count, color));
              }
            }
            // Tables for this position
            colorIndex = 0;
            final List<pw.Widget> tables = [];
            for (final item in itemOrder) {
              final employees = itemEmployees[item];
              if (employees != null && employees.isNotEmpty) {
                final color = palette[colorIndex % palette.length];
                colorIndex++;
                final count = employees.fold<int>(0, (sum, e) => sum + (int.tryParse((e.counts != null && e.counts.trim().isNotEmpty) ? e.counts : '1') ?? 1));
                tables.add(
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      sectionHeader(item, count, color, category: restaurant.category),
                      employeeTable(employees, item, color),
                      pw.SizedBox(height: 16),
                    ],
                  ),
                );
              }
            }
            // Add position header, chips, and tables to the PDF
            positionSections.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
                  pw.Container(
                    width: double.infinity,
                    color: PdfColors.grey200,
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: pw.Text(position ?? 'No Position', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
                  ),
                  pw.SizedBox(height: 8),
                  if (chips.isNotEmpty)
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips,
                    ),
                  pw.SizedBox(height: 12),
                  ...tables,
                ],
              ),
            );
          }
          return positionSections;
        })(),

        // // Example: Shirt Section
        // sectionHeader('Shirt', 800, shirtColor),
        // employeeTable(restaurant.employees), // Filter for shirt if needed

        // // Example: Pant Section
        // sectionHeader('Pant', 40, pantColor),
        // employeeTable(restaurant.employees), // Filter for pant if needed

        // Add more sections as needed...
      ],
    ),
  );

    final pdfBytes = await pdf.save();

  if (uploadToDrive && serviceAccountJson != null && driveFolderId != null && driveFolderId.isNotEmpty) {
    final clientName = restaurant.name.replaceAll(' ', '_');
    final dateStr = restaurant.date.replaceAll('/', '-');
    final fileName = '${clientName}_report_${dateStr}.pdf';

    await uploadPdfToDriveOrUpdate(
      pdfBytes: pdfBytes,
      fileName: fileName,
      folderId: driveFolderId,
      serviceAccountJson: serviceAccountJson,
    );
  }

  return pdfBytes;
} }