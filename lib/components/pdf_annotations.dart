import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mairie_ipad/view/project/project_task.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:mairie_ipad/services/projet_service.dart';
import 'package:flutter/services.dart';

enum AnnotationType {
  Rectangle,
  Circle,
  Text,
  Eraser,
  Selection,
}

class Annotation {
  final Rect rect;
  final AnnotationType type;
  final String? text;

  Annotation(this.rect, this.type, {this.text});
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
  AnnotationType _currentAnnotationType = AnnotationType.Selection;
  List<Annotation> _annotations = [];
  Offset? _startOffset;
  Offset? _endOffset;
  bool _isDrawing = false;
  final ProjetService _projetService = ProjetService();

  Size? _pdfSize;
  Size? _widgetSize;
  bool _showLandscapeWarning = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitDown
    // ]);
    // super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Affiche un avertissement si l'orientation est en mode paysage
    if (isLandscape && !_showLandscapeWarning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLandscapeWarningDialog();
      });
      setState(() {
        _showLandscapeWarning = true;
      });
    } else if (!isLandscape) {
      setState(() {
        _showLandscapeWarning = false;
      });
    }

    final pdfWidth =
        isLandscape ? mediaQuery.size.height : mediaQuery.size.width;
    final pdfHeight =
        isLandscape ? mediaQuery.size.width : mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(onPressed: _clearAnnotations, icon: Icon(Icons.delete)),
          _buildAnnotationIcon(
              AnnotationType.Rectangle, Icons.crop_square, Colors.red),
          _buildAnnotationIcon(
              AnnotationType.Circle, Icons.circle, Colors.blue),
          _buildAnnotationIcon(AnnotationType.Selection,
              Icons.arrow_outward_outlined, Colors.grey),
          IconButton(
              icon: Icon(Icons.save, color: Colors.green),
              onPressed: _saveAnnotations),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _widgetSize = constraints.biggest;

          return Stack(
            children: [
              Center(
                child: Transform.rotate(
                  angle: isLandscape ? -3.14159 / 2 : 0,
                  child: Container(
                    width: pdfWidth,
                    height: pdfHeight,
                    child: SfPdfViewer.file(
                      widget.pdfFile,
                      controller: _pdfViewerController,
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        setState(() {
                          _pdfDocument = details.document;
                          _totalPages = _pdfDocument!.pages.count;
                          _isReady = true;
                          _pdfSize = Size(
                            details.document.pages[0].size.width,
                            details.document.pages[0].size.height,
                          );
                        });
                      },
                      onPageChanged: (PdfPageChangedDetails details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                    ),
                  ),
                ),
              ),
              if (_isReady && _widgetSize != null && _pdfSize != null)
                if (!isLandscape)
                  Positioned.fill(
                    child: GestureDetector(
                      onPanStart: (details) {
                        if (_currentAnnotationType ==
                                AnnotationType.Rectangle ||
                            _currentAnnotationType == AnnotationType.Circle ||
                            _currentAnnotationType == AnnotationType.Text) {
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
                        if (_isDrawing) {
                          if (_currentAnnotationType ==
                              AnnotationType.Rectangle) {
                            _addRectangleAnnotation();
                          } else if (_currentAnnotationType ==
                              AnnotationType.Circle) {
                            _addCircleAnnotation();
                          } else if (_currentAnnotationType ==
                              AnnotationType.Text) {
                            _addTextAnnotation();
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
                  )
                else
                  Center(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          'Annotations sont désactivées en mode paysage',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  void _showLandscapeWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tournez votre tablette svp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'lib/assets/images/tablet_rotation.jpg',
                width: 100.0,
                height: 100.0,
              ),
              SizedBox(height: 16.0),
              Text(
                  'Les annotations sont disponibles uniquement en mode portrait'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnnotationIcon(
      AnnotationType type, IconData iconData, Color color) {
    final isSelected = _currentAnnotationType == type;
    return Container(
      width: 50.0,
      height: 50.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Container(
              width: 45.0,
              height: 45.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow.withOpacity(0.5),
              ),
            ),
          IconButton(
            icon: Icon(iconData, size: 30.0, color: color),
            onPressed: () {
              setState(() {
                _currentAnnotationType = type;
              });
            },
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
      final Rect rect = Rect.fromPoints(_startOffset!, _endOffset!);
      _annotations.add(Annotation(rect, _currentAnnotationType));
      _addAnnotationToPdf(rect);
    }
  }

  void _addCircleAnnotation() {
    if (_pdfDocument != null &&
        _startOffset != null &&
        _endOffset != null &&
        _currentPage >= 0 &&
        _currentPage < _totalPages) {
      final Rect rect = Rect.fromPoints(_startOffset!, _endOffset!);
      _annotations.add(Annotation(rect, _currentAnnotationType));
      _addAnnotationToPdf(rect);
    }
  }

  void _addTextAnnotation() {
    if (_pdfDocument != null &&
        _startOffset != null &&
        _endOffset != null &&
        _currentPage >= 0 &&
        _currentPage < _totalPages) {
      final Rect rect = Rect.fromPoints(_startOffset!, _endOffset!);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String? text;
          return AlertDialog(
            title: Text('Add Text Annotation'),
            content: TextField(
              onChanged: (value) {
                text = value;
              },
              decoration: InputDecoration(hintText: 'Enter your text'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _annotations.add(
                      Annotation(rect, _currentAnnotationType, text: text));
                  _addAnnotationToPdf(rect, text);
                  setState(() {});
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    }
  }

  Rect convertToPdfCoordinates(Rect rect, Size pdfSize, Size widgetSize) {
    final pdfWidth = pdfSize.width;
    final pdfHeight = pdfSize.height;
    final widgetWidth = widgetSize.width;
    final widgetHeight = widgetSize.height;

    // Déterminer si le widget est en mode paysage
    final isWidgetLandscape = widgetWidth > widgetHeight;

    double left, top, right, bottom;

    if (isWidgetLandscape) {
      // Le widget est en mode paysage, le PDF est en mode portrait
      final scaleX = pdfHeight /
          widgetWidth; // La hauteur du PDF mappée à la largeur du widget
      final scaleY = pdfWidth /
          widgetHeight; // La largeur du PDF mappée à la hauteur du widget

      // Conversion des coordonnées du widget à celles du PDF
      left = rect.top * scaleX;
      top = pdfHeight - (rect.right * scaleY);
      right = rect.bottom * scaleX;
      bottom = pdfHeight - (rect.left * scaleY);
    } else {
      // Le widget est en mode portrait
      final scaleX = pdfWidth / widgetWidth;
      final scaleY = pdfHeight / widgetHeight;

      left = rect.left * scaleX;
      top = rect.top * scaleY;
      right = rect.right * scaleX;
      bottom = rect.bottom * scaleY;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  void _addAnnotationToPdf(Rect rect, [String? text]) {
    final page = _pdfDocument!.pages[_currentPage];
    final pageSize = page.size;

    final pdfRect = convertToPdfCoordinates(
      rect,
      _pdfSize!,
      _widgetSize!,
    );

    if (_currentAnnotationType == AnnotationType.Rectangle) {
      final rectangleAnnotation =
          PdfRectangleAnnotation(pdfRect, 'Erreur à corriger !',
              author: 'Mairie Alès',
              color: PdfColor(255, 0, 0), // couleur de l'annotation
              modifiedDate: DateTime.now());
      page.annotations.add(rectangleAnnotation);
    } else if (_currentAnnotationType == AnnotationType.Circle) {
      final circleAnnotation =
          PdfEllipseAnnotation(pdfRect, 'Erreur à corriger !',
              author: 'Mairie Alès',
              color: PdfColor(0, 0, 255), // couleur de l'annotation
              modifiedDate: DateTime.now());
      page.annotations.add(circleAnnotation);
    }
  }

  void _saveAnnotations() async {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation d\'envoie du PDF'),
          content:
              Text('Êtes-vous sûr de vouloir enregistrer et envoyer le PDF ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Sauvegarder'),
            ),
          ],
        );
      },
    );

    // Procéder à la sauvegarde si l'utilisateur a confirmé
    if (shouldSave ?? false) {
      if (_pdfDocument != null) {
        final List<int> bytes = await _pdfDocument!.save();
        final tempFile = File('${widget.pdfFile.path}_temp.pdf');
        await tempFile.writeAsBytes(bytes, flush: true);

        try {
          // Supposons que vous avez une méthode uploadPdf dans votre ProjetService
          await _projetService.uploadPdf(tempFile);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Document sauvegardé avec succès!')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProjectTaskScreen()),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erreur lors de la sauvegarde du document.')),
          );
        }

        // Optionnel : Supprimez le fichier temporaire si ce n'est pas nécessaire.
        await tempFile.delete();
      }
    }
  }

  void _clearAnnotations() {
    _annotations.clear();
    if (_pdfDocument != null) {
      for (int i = 0; i < _pdfDocument!.pages.count; i++) {
        final PdfPage page = _pdfDocument!.pages[i];
        for (int j = 0; j < page.annotations.count; j++) {
          final PdfAnnotation annotation = page.annotations[j];
          page.annotations.remove(annotation);
        }
      }
    }
    setState(() {});
  }

  void _zoomIn() {
    _pdfViewerController.zoomLevel =
        (_pdfViewerController.zoomLevel ?? 1.0) + 0.1;
  }

  void _zoomOut() {
    _pdfViewerController.zoomLevel =
        (_pdfViewerController.zoomLevel ?? 1.0) - 0.1;
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
    this.startOffset,
    this.endOffset,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final annotation in annotations) {
      if (annotation.type == AnnotationType.Rectangle) {
        paint.color = Colors.red;
        canvas.drawRect(annotation.rect, paint);
      } else if (annotation.type == AnnotationType.Circle) {
        paint.color = Colors.blue;
        canvas.drawOval(annotation.rect, paint);
      } else if (annotation.type == AnnotationType.Text) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: annotation.text,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, annotation.rect.topLeft);
      }
    }

    if (isDrawing) {
      if (currentAnnotationType == AnnotationType.Rectangle) {
        paint.color = Colors.red.withOpacity(0.5);
        final rect = Rect.fromPoints(startOffset!, endOffset!);
        canvas.drawRect(rect, paint);
      } else if (currentAnnotationType == AnnotationType.Circle) {
        paint.color = Colors.blue.withOpacity(0.5);
        final rect = Rect.fromPoints(startOffset!, endOffset!);
        canvas.drawOval(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
