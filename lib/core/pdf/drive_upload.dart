import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

Future<void> uploadPdfToDrive({
  required File pdfFile,
  required Map<String, dynamic> serviceAccountJson,
  String? folderId, // Optional: Google Drive folder ID
}) async {
  // Use the provided service account JSON map
  final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

  // Define the required scopes
  final scopes = [drive.DriveApi.driveFileScope];

  // Obtain an authenticated HTTP client
  final client = await clientViaServiceAccount(accountCredentials, scopes);

  try {
    final driveApi = drive.DriveApi(client);

    // Prepare the file to upload
    var media = drive.Media(pdfFile.openRead(), pdfFile.lengthSync());
    var driveFile = drive.File()
      ..name = pdfFile.uri.pathSegments.last
      ..parents = folderId != null ? [folderId] : null;

    // Upload the file
    await driveApi.files.create(driveFile, uploadMedia: media);
    print('PDF uploaded to Google Drive!');
  } finally {
    client.close();
  }
} 