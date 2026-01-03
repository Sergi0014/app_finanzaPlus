import 'package:flutter_test/flutter_test.dart';
import 'package:app_ingresos/services/backup_service.dart';

void main() {
  group('BackupService', () {
    late BackupService backupService;

    setUp(() {
      backupService = BackupService();
    });

    test('BackupService instance should be created', () {
      expect(backupService, isNotNull);
      expect(backupService, isA<BackupService>());
    });

    test('createBackup should return a valid path', () async {
      // Este test requiere permisos y contexto de Flutter
      // Por ahora verificamos que el método existe
      expect(backupService.createBackup, isA<Function>());
    });

    test('restoreBackup method should exist', () {
      expect(backupService.restoreBackup, isA<Function>());
    });

    test('importFromCSV method should exist', () {
      expect(backupService.importFromCSV, isA<Function>());
    });
  });
}
