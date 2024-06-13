import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class AnnotationsPDF extends StatefulWidget {
  final File pdfFile;

  const AnnotationsPDF({Key? key, required this.pdfFile}) : super(key: key);

  @override
  _AnnotationsPDFState createState() => _AnnotationsPDFState();
}

class _AnnotationsPDFState extends State<AnnotationsPDF> {
  late PDFViewController _pdfViewController;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String? _tempFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Annotations PDF'),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfFile.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            onRender: (pages) {
              setState(() {
                _totalPages = pages!;
                _isReady = true;
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
          if (!_isReady)
            Center(
              child: CircularProgressIndicator(),
            ),
          GestureDetector(
            onTapUp: (details) {
              _showAnnotationDialog(context, details.localPosition);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for button action if needed
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  void _showAnnotationDialog(BuildContext context, Offset position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une annotation'),
          content:
              Text('Voulez-vous ajouter une annotation à cette position ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _annoterPDF(context, position);
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _annoterPDF(BuildContext context, Offset position) async {
    try {
      PdfDocument document =
          PdfDocument(inputBytes: widget.pdfFile.readAsBytesSync());
      PdfPage page = document.pages[_currentPage];

      double x = position.dx;
      double y = page.size.height - position.dy;

      PdfRectangleAnnotation rectangleAnnotation = PdfRectangleAnnotation(
        Rect.fromLTWH(x, y, 80, 80),
        'Rectangle Annotation',
        author: 'Syncfusion',
        color: PdfColor(255, 0, 0),
        border: PdfAnnotationBorder(5),
        modifiedDate: DateTime.now(),
      );

      page.annotations.add(rectangleAnnotation);

      await widget.pdfFile.writeAsBytes(await document.save());
      document.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annotation ajoutée au PDF')),
      );

      // Rafraîchir la vue PDF après l'ajout d'annotation
      //_refreshPdfView();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'annotation du PDF: $e')),
      );
    }
  }

  void _refreshPdfView() {
    // Trigger a rebuild of the PDFView by changing the key
    setState(() {
      _tempFilePath = widget.pdfFile.path +
          '?refresh=${DateTime.now().millisecondsSinceEpoch}';
    });
  }
}
