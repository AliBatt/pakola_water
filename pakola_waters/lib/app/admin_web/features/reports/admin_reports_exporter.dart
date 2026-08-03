import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:models/models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:utilities/utilities.dart';

import '../../../../shared/orders/others_date_preset.dart';
import 'admin_reports_controller.dart';
import 'download_bytes.dart';

enum ReportExportFormat { csv, pdf }

class AdminReportsExporter {
  const AdminReportsExporter(this.controller);

  final AdminReportsController controller;

  String get _timestamp {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  String get fileBaseName => 'pakola_waters_report_$_timestamp';

  String filterSummary() {
    final parts = <String>[
      'Date: ${_dateLabel()}',
      'Basis: ${controller.dateBasis == ReportsDateBasis.created ? 'Created' : 'Delivered'}',
      'Branch: ${_branchLabel()}',
      'Payment: ${controller.paymentFilter?.label ?? 'All'}',
    ];
    return parts.join(' · ');
  }

  String _dateLabel() {
    switch (controller.datePreset) {
      case OthersDatePreset.custom:
        final range = controller.customRange;
        if (range == null) return 'Custom';
        return DateTimeFormatter.formatRange(range.start, range.end);
      default:
        return controller.datePreset.label;
    }
  }

  String _branchLabel() {
    final id = controller.branchFilter;
    if (id == null) return 'All branches';
    for (final branch in controller.branches) {
      if (branch.id == id) return branch.name;
    }
    return id;
  }

  String _money(double value) => value.toStringAsFixed(2);

  String _dur(Duration? value) => value?.shortLabel ?? '';

  Future<void> export(ReportExportFormat format) async {
    switch (format) {
      case ReportExportFormat.csv:
        downloadText(
          text: buildCsv(),
          filename: '$fileBaseName.csv',
          mimeType: 'text/csv;charset=utf-8',
        );
      case ReportExportFormat.pdf:
        final bytes = await buildPdf();
        downloadBytes(
          bytes: bytes,
          filename: '$fileBaseName.pdf',
          mimeType: 'application/pdf',
        );
    }
  }

  String buildCsv() {
    final buffer = StringBuffer();
    void section(String title) {
      buffer.writeln();
      buffer.writeln(_csvRow([title]));
    }

    void table(List<String> headers, Iterable<List<String>> rows) {
      buffer.writeln(_csvRow(headers));
      for (final row in rows) {
        buffer.writeln(_csvRow(row));
      }
    }

    buffer.writeln(_csvRow(['Pakola Waters — Business Report']));
    buffer.writeln(_csvRow(['Generated', DateTime.now().toIso8601String()]));
    buffer.writeln(_csvRow(['Filters', filterSummary()]));
    buffer.writeln();

    section('Summary');
    table(
      ['Metric', 'Value'],
      [
        ['Total revenue (delivered)', _money(controller.totalRevenue)],
        ['Total orders', '${controller.totalOrders}'],
        ['Delivered', '${controller.deliveredCount}'],
        ['Active', '${controller.activeCount}'],
        ['Failed', '${controller.failedCount}'],
        ['Cancelled', '${controller.cancelledCount}'],
        ['Avg assign time', _dur(controller.averageAssignTime)],
        ['Avg arrive time', _dur(controller.averageArriveTime)],
        ['Avg total delivery', _dur(controller.averageDeliveryTime)],
        ['Top branch', controller.topBranch?.name ?? ''],
        ['Top rider', controller.topRider?.name ?? ''],
      ],
    );

    section('Orders by status');
    table(
      ['Status', 'Count'],
      controller.statusBreakdown.entries.map(
        (e) => [e.key.label, '${e.value}'],
      ),
    );

    section('By branch');
    table(
      [
        'Branch',
        'Orders',
        'Delivered',
        'Failed',
        'Revenue',
        'Avg assign',
        'Avg arrive',
        'Avg delivery',
      ],
      controller.branchStats.map(
        (s) => [
          s.name,
          '${s.orderCount}',
          '${s.deliveredCount}',
          '${s.failedCount}',
          _money(s.revenue),
          _dur(s.avgAssignDuration),
          _dur(s.avgArriveDuration),
          _dur(s.avgDeliveryDuration),
        ],
      ),
    );

    section('By rider');
    table(
      [
        'Rider',
        'Orders',
        'Deliveries',
        'Failed',
        'Revenue',
        'Avg arrive',
        'Avg delivery',
      ],
      controller.riderStats.map(
        (s) => [
          s.name,
          '${s.orderCount}',
          '${s.deliveredCount}',
          '${s.failedCount}',
          _money(s.revenue),
          _dur(s.avgArriveDuration),
          _dur(s.avgDeliveryDuration),
        ],
      ),
    );

    section('By customer');
    table(
      [
        'Customer',
        'Customer ID',
        'Orders',
        'Delivered',
        'Failed',
        'Revenue',
      ],
      controller.customerStats.map(
        (s) => [
          s.name,
          s.id,
          '${s.orderCount}',
          '${s.deliveredCount}',
          '${s.failedCount}',
          _money(s.revenue),
        ],
      ),
    );

    section('By supervisor');
    table(
      [
        'Supervisor',
        'Assigned',
        'Delivered',
        'Failed',
        'Revenue',
        'Avg assign',
      ],
      controller.supervisorStats.map(
        (s) => [
          s.name,
          '${s.orderCount}',
          '${s.deliveredCount}',
          '${s.failedCount}',
          _money(s.revenue),
          _dur(s.avgAssignDuration),
        ],
      ),
    );

    section('Revenue trend (delivered)');
    table(
      ['Day', 'Revenue', 'Orders'],
      controller.revenueTrend.map(
        (p) => [
          DateTimeFormatter.formatIsoDate(p.day),
          _money(p.revenue),
          '${p.orders}',
        ],
      ),
    );

    section('All orders');
    final orders = [...controller.filteredOrders]
      ..sort((a, b) {
        final aDate = a.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    table(
      [
        'Order ID',
        'Created',
        'Status',
        'Customer',
        'Customer phone',
        'Branch',
        'Product',
        'Qty',
        'Unit price',
        'Line total',
        'Payment method',
        'Payment status',
        'Supervisor',
        'Rider',
        'Delivery address',
        'Assigned at',
        'Out for delivery',
        'Rider arrived',
        'Delivered at',
        'Failed at',
        'Failure reason',
        'Admin notes',
        'Note',
      ],
      orders.map(_orderCsvRow),
    );

    return buffer.toString();
  }

  List<String> _orderCsvRow(DeliveryOrder order) {
    return [
      order.id,
      DateTimeFormatter.formatLong(order.createdAt),
      order.status.label,
      order.customerName,
      order.customerPhone ?? '',
      order.branchName ?? order.branchId,
      order.productName,
      '${order.quantity}',
      _money(order.unitPrice),
      _money(order.lineTotal),
      order.paymentMethod.label,
      order.effectivePaymentStatus.label,
      controller.supervisorNameFor(order),
      controller.riderNameFor(order),
      order.deliveryAddressLabel == '—'
          ? ''
          : order.deliveryAddressLabel,
      DateTimeFormatter.formatLong(order.assignedAt),
      DateTimeFormatter.formatLong(order.outForDeliveryAt),
      DateTimeFormatter.formatLong(order.riderArrivedAt),
      DateTimeFormatter.formatLong(order.deliveredAt),
      DateTimeFormatter.formatLong(order.failedAt),
      order.failureReason ?? '',
      order.adminNotes ?? '',
      order.note ?? '',
    ];
  }

  Future<Uint8List> buildPdf() async {
    final doc = pw.Document();
    final orders = [...controller.filteredOrders]
      ..sort((a, b) {
        final aDate = a.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAtDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Pakola Waters — Business Report',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              filterSummary(),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Text(
              'Generated ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          _pdfHeading('Summary'),
          _pdfKeyValueTable([
            ['Total revenue (delivered)', 'Rs ${_money(controller.totalRevenue)}'],
            ['Total orders', '${controller.totalOrders}'],
            ['Delivered', '${controller.deliveredCount}'],
            ['Active / Failed / Cancelled',
              '${controller.activeCount} / ${controller.failedCount} / ${controller.cancelledCount}'],
            ['Avg assign / arrive / delivery',
              '${_dur(controller.averageAssignTime)} / ${_dur(controller.averageArriveTime)} / ${_dur(controller.averageDeliveryTime)}'],
            ['Top branch', controller.topBranch?.name ?? '—'],
            ['Top rider', controller.topRider?.name ?? '—'],
          ]),
          pw.SizedBox(height: 14),
          _pdfHeading('Orders by status'),
          _pdfTable(
            headers: const ['Status', 'Count'],
            rows: controller.statusBreakdown.entries
                .map((e) => [e.key.label, '${e.value}'])
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('By branch'),
          _pdfTable(
            headers: const [
              'Branch',
              'Orders',
              'Delivered',
              'Failed',
              'Revenue',
              'Avg assign',
              'Avg arrive',
            ],
            rows: controller.branchStats
                .map(
                  (s) => [
                    s.name,
                    '${s.orderCount}',
                    '${s.deliveredCount}',
                    '${s.failedCount}',
                    _money(s.revenue),
                    _dur(s.avgAssignDuration),
                    _dur(s.avgArriveDuration),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('By rider'),
          _pdfTable(
            headers: const [
              'Rider',
              'Orders',
              'Deliveries',
              'Failed',
              'Revenue',
              'Avg arrive',
            ],
            rows: controller.riderStats
                .map(
                  (s) => [
                    s.name,
                    '${s.orderCount}',
                    '${s.deliveredCount}',
                    '${s.failedCount}',
                    _money(s.revenue),
                    _dur(s.avgArriveDuration),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('By customer'),
          _pdfTable(
            headers: const [
              'Customer',
              'Orders',
              'Delivered',
              'Failed',
              'Revenue',
            ],
            rows: controller.customerStats
                .map(
                  (s) => [
                    s.name,
                    '${s.orderCount}',
                    '${s.deliveredCount}',
                    '${s.failedCount}',
                    _money(s.revenue),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('By supervisor'),
          _pdfTable(
            headers: const [
              'Supervisor',
              'Assigned',
              'Delivered',
              'Failed',
              'Revenue',
              'Avg assign',
            ],
            rows: controller.supervisorStats
                .map(
                  (s) => [
                    s.name,
                    '${s.orderCount}',
                    '${s.deliveredCount}',
                    '${s.failedCount}',
                    _money(s.revenue),
                    _dur(s.avgAssignDuration),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 14),
          _pdfHeading('All orders (${orders.length})'),
          _pdfTable(
            headers: const [
              'Order',
              'Created',
              'Status',
              'Customer',
              'Branch',
              'Product',
              'Qty',
              'Total',
              'Pay',
              'Rider',
              'Supervisor',
            ],
            rows: orders
                .map(
                  (o) => [
                    o.id.length > 8 ? o.id.substring(0, 8) : o.id,
                    DateTimeFormatter.format(o.createdAt),
                    o.status.label,
                    o.customerName,
                    o.branchName ?? o.branchId,
                    o.productName,
                    '${o.quantity}',
                    _money(o.lineTotal),
                    o.paymentMethod.label,
                    controller.riderNameFor(o),
                    controller.supervisorNameFor(o),
                  ],
                )
                .toList(),
            fontSize: 7,
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _pdfHeading(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _pdfKeyValueTable(List<List<String>> rows) {
    return pw.TableHelper.fromTextArray(
      headers: const ['Metric', 'Value'],
      data: rows,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
    );
  }

  pw.Widget _pdfTable({
    required List<String> headers,
    required List<List<String>> rows,
    double fontSize = 8,
  }) {
    if (rows.isEmpty) {
      return pw.Text(
        'No data for current filters.',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      );
    }
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: fontSize,
      ),
      cellStyle: pw.TextStyle(fontSize: fontSize),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.3),
    );
  }

  String _csvRow(List<String> cells) {
    return cells.map(_escapeCsv).join(',');
  }

  String _escapeCsv(String value) {
    final needsQuotes = value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    final escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }
}
