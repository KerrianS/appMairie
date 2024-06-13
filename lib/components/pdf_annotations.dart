import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:mairie_ipad/components/tools_bar.dart';

class AnnotationsPDF extends StatefulWidget {
  final File pdfFile;

  AnnotationsPDF({Key? key, required this.pdfFile}) : super(key: key);

  @override
  _AnnotationsPDFState createState() => _AnnotationsPDFState();
}

class _AnnotationsPDFState extends State<AnnotationsPDF> {
  late PdfViewerController _pdfViewerController;
  PdfDocument? _pdfDocument; // Use nullable PdfDocument
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualisation du PDF'),
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(
            widget.pdfFile,
            controller: _pdfViewerController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _pdfDocument = details.document;
                _totalPages = _pdfDocument!.pages.count;
                _isReady = true;
              });
            },
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              color: Colors.blue.shade900,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ToolbarPDF(
                    onAnnotationSelected: (type) {
                      // Handle annotation selection here
                      switch (type) {
                        case AnnotationType.Pen:
                          // Logic for pen annotation
                          break;
                        case AnnotationType.Text:
                          // Logic for text annotation
                          break;
                        case AnnotationType.Rectangle:
                          _addRectangleAnnotation();
                          break;
                        case AnnotationType.Circle:
                          // Logic for circle annotation
                          break;
                        case AnnotationType.Highlight:
                          // Logic for highlight annotation
                          break;
                        default:
                          // Handle other types or throw an error
                          throw ArgumentError('Unknown annotation type: $type');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addRectangleAnnotation() {
    if (_pdfDocument != null && _pdfViewerController.pageNumber != null) {
      final int pageNumber = _pdfViewerController.pageNumber!;
      final int totalPages = _pdfDocument!.pages.count;

      if (pageNumber >= 0 && pageNumber < totalPages) {
        final PdfPage page = _pdfDocument!.pages[pageNumber];
        final PdfRectangleAnnotation rectangleAnnotation =
            PdfRectangleAnnotation(
          Rect.fromLTWH(0, 30, 80, 80),
          'Rectangle Annotation',
          author: 'Syncfusion',
          color: PdfColor(255, 0, 0),
          setAppearance: true,
          modifiedDate: DateTime.now(),
        );

        // Add the annotation to the PDF page
        page.annotations.add(rectangleAnnotation);

        // Save the document with annotations
        _saveDocument(_pdfDocument!);
      }
    }
  }

  Future<void> _saveDocument(PdfDocument document) async {
    final List<int> bytes = await document.save();
    // Do something with the bytes, for example, save to a file
    // File('output.pdf').writeAsBytes(bytes);
  }
}
