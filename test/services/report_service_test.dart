import 'package:flutter_test/flutter_test.dart';
import 'package:app_ingresos/services/report_service.dart';

void main() {
  group('ReportService', () {
    late ReportService reportService;

    setUp(() {
      reportService = ReportService();
    });

    test('ReportService instance should be created', () {
      expect(reportService, isNotNull);
      expect(reportService, isA<ReportService>());
    });

    test('generateWeeklyReport method should exist', () {
      expect(reportService.generateWeeklyReport, isA<Function>());
    });
  });
}
