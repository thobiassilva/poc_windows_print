// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> main() async {
  runApp(const MyApp('Printing Demo'));
}

class MyApp extends StatefulWidget {
  const MyApp(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        // body: PdfPreview(
        //   build: (format) => _generatePdf(format, title),
        // ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Digite o texto que deseja imprimir',
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () async {
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async =>
                          await _generatePdf(format, _textController.text),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text(
                    'Imprimir PDF',
                  ),
                ),
                const SizedBox(height: 20),
                Builder(builder: (context) {
                  return FilledButton.icon(
                    onPressed: () async {
                      final printers = await Printing.listPrinters();
                      // final List<Printer> printers = [];
                      showBottomSheet(
                        context: context,
                        builder: (context) {
                          return ListView.builder(
                            itemCount: printers.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(printers[index].name),
                                onTap: () async {
                                  await Printing.directPrintPdf(
                                    printer: printers[index],
                                    onLayout: (PdfPageFormat format) async =>
                                        await _generatePdf(
                                      format,
                                      _textController.text,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text(
                      'Imprimir Direto',
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String text) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              children: [
                pw.Text(
                  text,
                  style: const pw.TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
