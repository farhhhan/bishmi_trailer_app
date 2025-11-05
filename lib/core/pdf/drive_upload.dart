// lib/core/pdf/drive_upload.dart
import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:googleapis_auth/auth_io.dart' as auth show clientViaServiceAccount;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:hive/hive.dart';

Future<String> uploadPdfToDriveOrUpdate({
  required Uint8List pdfBytes,
  required String fileName,
  required String folderId,
  required Map<String, dynamic> serviceAccountJson,
  String? existingFileId, // if present, update directly
}) async {
  final scopes = [gdrive.DriveApi.driveFileScope, gdrive.DriveApi.driveScope];
  final creds = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
  final client = await auth.clientViaServiceAccount(creds, scopes);
  try {
    final drive = gdrive.DriveApi(client);

    final media = gdrive.Media(Stream<List<int>>.fromIterable([pdfBytes]), pdfBytes.length);
    final fileMeta = gdrive.File()
      ..name = fileName
      ..mimeType = 'application/pdf';

    // 1) Update by ID if we already know it
    if (existingFileId != null && existingFileId.isNotEmpty) {
      final updated = await drive.files.update(fileMeta, existingFileId, uploadMedia: media);
      return updated.id!;
    }

    // 2) Otherwise, search by name within the folder and update if found
    final safeName = fileName.replaceAll("'", r"\'");
    final q = "name = '$safeName' and '$folderId' in parents and trashed = false";
    final list = await drive.files.list(q: q, spaces: 'drive', $fields: 'files(id,name)');

    if (list.files != null && list.files!.isNotEmpty) {
      final existingId = list.files!.first.id!;
      final updated = await drive.files.update(fileMeta, existingId, uploadMedia: media);
      return updated.id!;
    }

    // 3) Otherwise, create
    fileMeta.parents = [folderId];
    final created = await drive.files.create(fileMeta, uploadMedia: media);
    return created.id!;
  } finally {
    client.close();
  }
}