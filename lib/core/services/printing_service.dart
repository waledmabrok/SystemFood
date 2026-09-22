import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/order.dart';
import '../constants/app_strings.dart';

class PrintingService {
  PrintingService._();
  static final PrintingService instance = PrintingService._();

  pw.Font? _arabicFont;
  pw.Font? _arabicFontBold;

  // نفس عرض ورق تقرير الديون (70مم) بدل roll80 (80مم)
  static const double _receiptWidthMm = 70;

  Future<void> _initFonts() async {
    if (_arabicFont == null) {
      _arabicFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Amiri-Regular.ttf'),
      );
    }
    if (_arabicFontBold == null) {
      _arabicFontBold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Amiri-Bold.ttf'),
      );
    }
  }

  String _formatDate(DateTime date) {
    int h = date.hour;
    final ampm = h >= 12 ? 'م' : 'ص';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${h.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $ampm';
  }

  /// طباعة فاتورة العميل
  Future<void> printCustomerReceipt(Order order) async {
    await _initFonts();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          _receiptWidthMm * PdfPageFormat.mm,
          double.infinity,
        ),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // رأس الفاتورة
                pw.Center(
                  child: pw.Text(
                    AppStrings.appName,
                    style: pw.TextStyle(font: _arabicFontBold, fontSize: 18),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'فاتورة ضريبية مبسطة',
                    style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 8),

                // بيانات الفاتورة
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'رقم الطلب:',
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                    pw.Text(
                      '#${order.orderNumber}',
                      style: pw.TextStyle(font: _arabicFontBold, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'التاريخ:',
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                    pw.Text(
                      _formatDate(order.createdAt),
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'الكاشير:',
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                    pw.Text(
                      order.userName ?? 'غير محدد',
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 8),

                // الأصناف
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'الصنف',
                        style: pw.TextStyle(
                          font: _arabicFontBold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'الكمية',
                        style: pw.TextStyle(
                          font: _arabicFontBold,
                          fontSize: 11,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'السعر',
                        style: pw.TextStyle(
                          font: _arabicFontBold,
                          fontSize: 11,
                        ),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),

                ...order.items.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(
                              font: _arabicFont,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            item.quantity.toInt().toString(),
                            style: pw.TextStyle(
                              font: _arabicFont,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            item.totalPrice.toStringAsFixed(2),
                            style: pw.TextStyle(
                              font: _arabicFont,
                              fontSize: 11,
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 8),

                // الإجماليات
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'المجموع الفرعي:',
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                    pw.Text(
                      order.subtotal.toStringAsFixed(2),
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                  ],
                ),
                if (order.discountAmount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'الخصم:',
                        style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                      ),
                      pw.Text(
                        order.discountAmount.toStringAsFixed(2),
                        style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                      ),
                    ],
                  ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'الإجمالي:',
                      style: pw.TextStyle(font: _arabicFontBold, fontSize: 14),
                    ),
                    pw.Text(
                      order.finalAmount.toStringAsFixed(2),
                      style: pw.TextStyle(font: _arabicFontBold, fontSize: 14),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 8),

                // طريقة الدفع
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'طريقة الدفع:',
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                    pw.Text(
                      order.paymentMethod.label,
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'المدفوع:',
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                    pw.Text(
                      order.paidAmount.toStringAsFixed(2),
                      style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                    ),
                  ],
                ),
                if (order.changeAmount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'الباقي:',
                        style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                      ),
                      pw.Text(
                        order.changeAmount.toStringAsFixed(2),
                        style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                      ),
                    ],
                  ),

                if (order.paymentRef != null &&
                    order.paymentRef!.isNotEmpty &&
                    order.paymentMethod != PaymentMethod.cash) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'المرجع:',
                        style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                      ),
                      pw.Text(
                        order.paymentRef!,
                        style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                      ),
                    ],
                  ),
                ],

                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'شكراً لزيارتكم!',
                    style: pw.TextStyle(font: _arabicFontBold, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${order.orderNumber}',
    );
  }

  /// طباعة ورقة المطبخ
  Future<void> printKitchenTicket(Order order) async {
    await _initFonts();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          _receiptWidthMm * PdfPageFormat.mm,
          double.infinity,
        ),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Center(
                  child: pw.Text(
                    'ورقة تجهيز - المطبخ',
                    style: pw.TextStyle(font: _arabicFontBold, fontSize: 16),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 8),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'رقم الطلب:',
                      style: pw.TextStyle(font: _arabicFontBold, fontSize: 16),
                    ),
                    pw.Text(
                      '#${order.orderNumber}',
                      style: pw.TextStyle(font: _arabicFontBold, fontSize: 18),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'الوقت: ${_formatDate(order.createdAt)}',
                  style: pw.TextStyle(font: _arabicFont, fontSize: 12),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 8),

                // الأصناف (بدون أسعار)
                ...order.items.map((item) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${item.quantity.toInt()} × ',
                          style: pw.TextStyle(
                            font: _arabicFontBold,
                            fontSize: 16,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(
                              font: _arabicFontBold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 1, borderStyle: pw.BorderStyle.dashed),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'ملاحظات:',
                    style: pw.TextStyle(font: _arabicFontBold, fontSize: 14),
                  ),
                  pw.Text(
                    order.notes!,
                    style: pw.TextStyle(font: _arabicFont, fontSize: 14),
                  ),
                ],

                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    '-- يرجى تجهيز الطلب --',
                    style: pw.TextStyle(font: _arabicFont, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Kitchen_${order.orderNumber}',
    );
  }
}
