// Core Service - Platform-specific File Storage
// Handles file export/import for Web, Mobile, and Desktop

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

/// Abstract interface for file storage operations
abstract class IFileStorageService {
  /// Saves export file (platform-specific behavior)
  /// - Web: Downloads file to browser
  /// - Mobile: Shows share dialog
  /// - Desktop: Shows save file dialog
  Future<void> saveExportFile(String content, String filename);

  /// Picks import file and returns content as string
  /// Returns null if user cancelled
  Future<String?> pickImportFile();
}

/// Implementation of file storage service with platform detection
class FileStorageService implements IFileStorageService {
  @override
  Future<void> saveExportFile(String content, String filename) async {
    if (kIsWeb) {
      await _downloadFileWeb(content, filename);
    } else if (Platform.isAndroid || Platform.isIOS) {
      await _shareFileMobile(content, filename);
    } else {
      // Desktop (Windows, macOS, Linux)
      await _saveFileDesktop(content, filename);
    }
  }

  @override
  Future<String?> pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: kIsWeb, // Web needs bytes, desktop/mobile use path
    );

    if (result == null || result.files.isEmpty) {
      return null; // User cancelled
    }

    final file = result.files.first;

    if (kIsWeb) {
      // Web: Read from bytes
      if (file.bytes == null) return null;
      return utf8.decode(file.bytes!);
    } else {
      // Mobile/Desktop: Read from file path
      if (file.path == null) return null;
      final ioFile = File(file.path!);
      return await ioFile.readAsString();
    }
  }

  /// Web: Download file via Blob and anchor element
  Future<void> _downloadFileWeb(String content, String filename) async {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  /// Mobile: Save to temp directory and share via share_plus
  Future<void> _shareFileMobile(String content, String filename) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Matzo Backup - $filename',
    );
  }

  /// Desktop: Show native save dialog
  Future<void> _saveFileDesktop(String content, String filename) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Backup speichern',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (path != null) {
      final file = File(path);
      await file.writeAsString(content);
    }
  }
}
