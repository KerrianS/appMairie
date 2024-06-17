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
  PdfDocument? _pdfDocument;
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  AnnotationType? _currentAnnotationType;
  Offset? _startOffset;
  Offset? _endOffset;
  bool _isDrawing = false;

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
          if (_isReady)
            GestureDetector(
              onPanStart: (details) {
                print("ON PAN START !");
                if (_currentAnnotationType == AnnotationType.Rectangle ||
                    _currentAnnotationType == AnnotationType.Circle) {
                  setState(() {
                    _isDrawing = true;
                    _startOffset = details.localPosition;
                  });
                }
              },
              onPanUpdate: (details) {
                if (_isDrawing) {
                  setState(() {
                    _endOffset = details.localPosition;
                  });
                }
              },
              onPanEnd: (details) {
                print("ON PAN END !");
                if (_isDrawing) {
                  if (_currentAnnotationType == AnnotationType.Rectangle) {
                    _addRectangleAnnotation();
                  } else if (_currentAnnotationType == AnnotationType.Circle) {
                    _addCircleAnnotation();
                  }
                  setState(() {
                    _isDrawing = false;
                    _startOffset = null;
                    _endOffset = null;
                  });
                }
              },
              child: CustomPaint(
                painter: AnnotationPainter(
                  start: _startOffset,
                  end: _endOffset,
                  annotationType: _currentAnnotationType,
                  currentPage: _currentPage,
                  pdfDocument: _pdfDocument,
                ),
                child: SizedBox.expand(),
              ),
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
                      setState(() {
                        _currentAnnotationType = type;
                      });
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
    if (_pdfDocument != null &&
        _startOffset != null &&
        _endOffset != null &&
        _currentPage >= 0 &&
        _currentPage < _totalPages) {
      final PdfPage page = _pdfDocument!.pages[_currentPage];
      final Rect rect = Rect.fromPoints(_startOffset!, _endOffset!);
      final PdfRectangleAnnotation rectangleAnnotation = PdfRectangleAnnotation(
        rect,
        'Rectangle Annotation',
        author: 'Syncfusion',
        color: PdfColor(255, 0, 0),
      );

      page.annotations.add(rectangleAnnotation);
      _saveDocument(_pdfDocument!);
      _refreshViewer();
    }
  }

  void _addCircleAnnotation() {
    if (_pdfDocument != null &&
        _startOffset != null &&
        _endOffset != null &&
        _currentPage >= 0 &&
        _currentPage < _totalPages) {
      final PdfPage page = _pdfDocument!.pages[_currentPage];
      final Rect rect = Rect.fromPoints(_startOffset!, _endOffset!);
      final PdfEllipseAnnotation circleAnnotation = PdfEllipseAnnotation(
        rect,
        'Circle Annotation',
        author: 'Syncfusion',
        color: PdfColor(0, 0, 255),
      );

      page.annotations.add(circleAnnotation);
      _saveDocument(_pdfDocument!);
      _refreshViewer();
    }
  }

  Future<void> _saveDocument(PdfDocument document) async {
    final List<int> bytes = await document.save();
    final file = File(widget.pdfFile.path);
    await file.writeAsBytes(bytes, flush: true);
  }

  void _refreshViewer() {
    setState(() {
      _isReady = false;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isReady = true;
      });
    });
  }
}

class AnnotationPainter extends CustomPainter {
  final Offset? start;
  final Offset? end;
  final AnnotationType? annotationType;
  final int currentPage;
  final PdfDocument? pdfDocument;

  AnnotationPainter({
    required this.start,
    required this.end,
    required this.annotationType,
    required this.currentPage,
    required this.pdfDocument,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (start == null || end == null || annotationType == null) return;

    final paint = Paint()
      ..color =
          annotationType == AnnotationType.Rectangle ? Colors.red : Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (annotationType == AnnotationType.Rectangle) {
      canvas.drawRect(Rect.fromPoints(start!, end!), paint);
    } else if (annotationType == AnnotationType.Circle) {
      canvas.drawOval(Rect.fromPoints(start!, end!), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
