import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

enum AnnotationType {
  Rectangle,
  Circle,
}

class Annotation {
  final Rect rect;
  final AnnotationType type;

  Annotation(this.rect, this.type);
}

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
  AnnotationType _currentAnnotationType = AnnotationType.Rectangle;
  List<Annotation> _annotations = [];
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
        actions: [
          IconButton(
            onPressed: _saveAnnotations,
            icon: Icon(Icons.save),
          ),
        ],
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
            Listener(
              onPointerDown: (details) {
                if (_currentAnnotationType == AnnotationType.Rectangle ||
                    _currentAnnotationType == AnnotationType.Circle) {
                  setState(() {
                    _isDrawing = true;
                    _startOffset = details.localPosition;
                  });
                }
              },
              onPointerMove: (details) {
                if (_isDrawing) {
                  setState(() {
                    _endOffset = details.localPosition;
                  });
                }
              },
              onPointerUp: (details) {
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
                  annotations: _annotations,
                  currentAnnotationType: _currentAnnotationType,
                  startOffset: _startOffset,
                  endOffset: _endOffset,
                  isDrawing: _isDrawing,
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
                        _currentAnnotationType = type!;
                      });
                    },
                    onSavePressed:
                        _saveAnnotations, // Passer la fonction de sauvegarde
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
      _annotations.add(Annotation(rect, _currentAnnotationType));
      _updateAnnotations();
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
      _annotations.add(Annotation(rect, _currentAnnotationType));
      _updateAnnotations();
    }
  }

  void _updateAnnotations() {
    _refreshViewer();
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

  void _saveAnnotations() {
    if (_pdfDocument != null) {
      _saveDocument(_pdfDocument!);
    }
  }

  Future<void> _saveDocument(PdfDocument document) async {
    final List<int> bytes = await document.save();
    final file = File(widget.pdfFile.path);
    await file.writeAsBytes(bytes, flush: true);
  }
}

class AnnotationPainter extends CustomPainter {
  final List<Annotation> annotations;
  final AnnotationType currentAnnotationType;
  final Offset? startOffset;
  final Offset? endOffset;
  final bool isDrawing;

  AnnotationPainter({
    required this.annotations,
    required this.currentAnnotationType,
    required this.startOffset,
    required this.endOffset,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var annotation in annotations) {
      final paint = Paint()
        ..color = annotation.type == AnnotationType.Rectangle
            ? Colors.red
            : Colors.blue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      if (annotation.type == AnnotationType.Rectangle) {
        canvas.drawRect(annotation.rect, paint);
      } else if (annotation.type == AnnotationType.Circle) {
        canvas.drawOval(annotation.rect, paint);
      }
    }

    // Dessiner en temps réel si en train de dessiner
    if (isDrawing) {
      final paint = Paint()
        ..color = currentAnnotationType == AnnotationType.Rectangle
            ? Colors.red
            : Colors.blue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      if (currentAnnotationType == AnnotationType.Rectangle) {
        if (startOffset != null && endOffset != null) {
          canvas.drawRect(Rect.fromPoints(startOffset!, endOffset!), paint);
        }
      } else if (currentAnnotationType == AnnotationType.Circle) {
        if (startOffset != null && endOffset != null) {
          canvas.drawOval(Rect.fromPoints(startOffset!, endOffset!), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ToolbarPDF extends StatefulWidget {
  final Function(AnnotationType)? onAnnotationSelected;
  final VoidCallback? onSavePressed; // Ajout de la fonction pour la sauvegarde

  const ToolbarPDF({
    Key? key,
    this.onAnnotationSelected,
    this.onSavePressed, // Ajout de la fonction pour la sauvegarde
  }) : super(key: key);

  @override
  _ToolbarPDFState createState() => _ToolbarPDFState();
}

class _ToolbarPDFState extends State<ToolbarPDF> {
  AnnotationType _selectedType = AnnotationType.Rectangle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.0,
      color: Colors.blue.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconButton(AnnotationType.Rectangle, Icons.crop_square),
          _buildIconButton(AnnotationType.Circle, Icons.circle),
          _buildIconButtonForSave(), // Ajout de l'icône Save
        ],
      ),
    );
  }

  Widget _buildIconButtonForSave() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Ink(
        decoration: ShapeDecoration(
          shape: CircleBorder(),
          color: Colors.transparent,
        ),
        child: IconButton(
          onPressed: () {
            if (widget.onSavePressed != null) {
              widget.onSavePressed!(); // Appel de la fonction de sauvegarde
            }
          },
          icon: Icon(
            Icons.save,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(AnnotationType type, IconData iconData) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 103, 179, 210),
              ),
            ),
          Ink(
            decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.transparent,
            ),
            child: IconButton(
              onPressed: () {
                _selectAnnotation(type);
              },
              icon: Icon(
                iconData,
                color: isSelected ? Colors.yellow : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnnotation(AnnotationType type) {
    setState(() {
      _selectedType = type;
    });

    if (widget.onAnnotationSelected != null) {
      widget.onAnnotationSelected!(type);
    }
  }
}
