import 'package:intl/intl.dart';
import 'package:losser_bar/Pages/Model/reserve_table_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfTableGenerator {
  final ReserveTableHistory table;
  final pdf = pw.Document();

  PdfTableGenerator(this.table);
  Future<void> generatePdf() async {
    final image = await _loadImage('images/logo.png');
    String formattedPaymentTime =
        DateFormat('yyyy-MM-dd – kk:mm').format(table.paymentTime);

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
        bytes: await pdf.save(), filename: 'table_${table.paymentTime}.pdf');
  }

  Future<pw.ImageProvider> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    return pw.MemoryImage(data.buffer.asUint8List());
  }

  pw.Widget _buildDivider() {
    return pw.Container(
        margin: pw.EdgeInsets.symmetric(
            vertical: 5), // Optional: adjust spacing before and after the line
        decoration: pw.BoxDecoration(
            border: pw.Border(
                bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColors
                        .grey800)))); // Adjust color and width as needed
  }

  pw.Widget _buildHeader(pw.ImageProvider image) {
    final String formattedBillingTime =
        DateFormat('yyyyMMddHHmmss').format(table.paymentTime);

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

          // Use the image here
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
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 10),
          pw.Text(
            'Payment by: ${table.nicknameUser}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            'Payment Time: ${table.paymentTime}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "table detail",
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
    final double price = double.tryParse(table.totalPrices.toString()) ?? 0.0;
    return pw.Padding(
      padding: pw.EdgeInsets.only(left: 8, right: 8, bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Text(
                '${table.selectedTableLabel}, ${table.selectedSeats} seats'),
          ),
          pw.Text('${price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  pw.Widget _buildTotal() {
    final double amountBeforeVat = table.totalPrices / 1.07;
    final double vatAmount = table.totalPrices - amountBeforeVat;

    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Total Seats: ${table.selectedSeats.toStringAsFixed(0)}',
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
              pw.Text(
                  'Total Price: ${table.totalPrices.toStringAsFixed(2)} THB',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
