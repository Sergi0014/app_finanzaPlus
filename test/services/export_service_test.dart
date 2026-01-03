import 'package:flutter_test/flutter_test.dart';
import 'package:app_ingresos/services/export_service.dart';

void main() {
  group('ExportService', () {
    late ExportService exportService;

    setUp(() {
      exportService = ExportService();
    });

    test('ExportService instance should be created', () {
      expect(exportService, isNotNull);
      expect(exportService, isA<ExportService>());
    });

    test('exportWeeklyReportToCSV method should exist', () {
      expect(exportService.exportWeeklyReportToCSV, isA<Function>());
    });

    test('exportWeeklyReportToJSON method should exist', () {
      expect(exportService.exportWeeklyReportToJSON, isA<Function>());
    });
  });
}
