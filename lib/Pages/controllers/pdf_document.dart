import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/payorder_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PdfGenerator {
  final PayOrder order;
  final pdf = pw.Document();

  PdfGenerator(this.order);

  Future<void> generatePdf() async {
    final image = await _loadImage('images/logo.png');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(image),
            _buildDivider(),
            _buildTitle(),
            _buildDivider(),
            pw.SizedBox(height: 20),
            _buildInvoice(),
            pw.SizedBox(height: 20),
            _buildDivider(),
            pw.SizedBox(height: 15),
            _buildTotal(),
          ],
        ),
      ),
    );

    // Save or share the PDF
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'order_${order.id}.pdf');
  }

  Future<pw.ImageProvider> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  pw.Widget _buildDivider() {
    return pw.Container(
        margin: pw.EdgeInsets.symmetric(vertical: 5),
        decoration: pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(width: 1, color: PdfColors.grey800))));
  }

  pw.Widget _buildHeader(pw.ImageProvider image) {
    final String formattedBillingTime =
        DateFormat('yyyyMMddHHmmss').format(order.billingTime);

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(image, height: 60, width: 60),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Losser Bar',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Chaingmai, Thailand', style: pw.TextStyle(fontSize: 14)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Tax invoice(ABB)/Receipt',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('ABB No.$formattedBillingTime',
                  style: pw.TextStyle(fontSize: 16)),
            ],
          ),
          pw.SizedBox(height: 20),
        ],
      ),
    );
  }

  pw.Widget _buildTitle() {
    final paymentTime =
        order.paymentsBy.isNotEmpty ? order.paymentsBy[0]['paymentTime'] : null;
    final formattedPaymentTime = paymentTime != null
        ? DateFormat('yyyy-MM-dd – kk:mm').format(paymentTime)
        : 'N/A';

    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 10),
          pw.Text(
            'Table No: ${order.tableNo}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Round No: ${order.roundtable}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.Text('Payment Method: ${order.paymentMethod}',
              style: pw.TextStyle(fontSize: 12)),
          // pw.Text(
          //   'Payment Time: $formattedPaymentTime',
          //   style: pw.TextStyle(fontSize: 12),
          // ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "order detail",
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                "quantity/price",
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInvoice() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: order.orders.map((item) {
        final double price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final double quantity = (item['quantity'] as num?)?.toDouble() ?? 0.0;
        final double totalPrice = price * quantity;

        return pw.Padding(
          padding: pw.EdgeInsets.only(left: 8, right: 8, bottom: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child:
                    pw.Text('${item['name']}, ${item['item']} ${item['unit']}'),
              ),
              pw.Text('${item['quantity']} x ${price.toStringAsFixed(2)}'),
              pw.Text(' = ${totalPrice.toStringAsFixed(2)}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _buildTotal() {
    final double amountBeforeVat = order.totalPrice / 1.07;
    final double vatAmount = order.totalPrice - amountBeforeVat;

    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
              'Total totalQuantity: ${order.totalQuantity.toStringAsFixed(0)} THB',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                  'Amount before VAT: ${amountBeforeVat.toStringAsFixed(2)} THB',
                  style: pw.TextStyle(fontSize: 14)),
              pw.Text('VAT 7%: ${vatAmount.toStringAsFixed(2)} THB',
                  style: pw.TextStyle(fontSize: 14)),
              _buildDivider(),
              pw.Text('Total Price: ${order.totalPrice.toStringAsFixed(2)} THB',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
