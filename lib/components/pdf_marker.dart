import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFMarkerScreen extends StatefulWidget {
  final File pdfFile;

  PDFMarkerScreen({required this.pdfFile});

  @override
  _PDFMarkerScreenState createState() => _PDFMarkerScreenState();
}

class _PDFMarkerScreenState extends State<PDFMarkerScreen> {
  List<MarkerItem> markerItems = [];
  TextEditingController _textEditingController = TextEditingController();
  bool _isTextEmpty = true;
  bool _showAddOptions = false;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_updateTextState);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_updateTextState);
    _textEditingController.dispose();
    super.dispose();
  }

  void _updateTextState() {
    setState(() {
      _isTextEmpty = _textEditingController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
        actions: [
          IconButton(
            onPressed: () {
              _savePdfWithMarkers();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Builder(
        builder: (context) => Stack(
          children: [
            SfPdfViewer.file(widget.pdfFile),
            ...markerItems.map((marker) {
              return Positioned(
                left: marker.position.dx,
                top: marker.position.dy,
                child: Draggable(
                  child: marker.widget,
                  feedback: marker.widget,
                  childWhenDragging: Container(),
                  onDraggableCanceled: (_, __) {},
                  onDragEnd: (details) {
                    setState(() {
                      final box = context.findRenderObject() as RenderBox?;
                      final offset =
                          box?.globalToLocal(details.offset) ?? details.offset;
                      marker.position = offset;
                    });
                  },
                ),
              );
            }).toList(),
            if (_showAddOptions)
              Positioned(
                bottom: 80, // Adjust this value as needed
                right: 16, // Align with FloatingActionButton
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showAddOptions = false;
                          });
                          _addMarker(Offset(
                              100, 100)); // Position initiale du marqueur
                        },
                        child: Text("Marqueur"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showAddOptions = false;
                          });
                          _showAddTextDialog();
                        },
                        child: Text("Texte"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showAddOptions = !_showAddOptions;
          });
        },
        backgroundColor: Colors.blue, // Fond bleu
        child: Icon(Icons.add, color: Colors.white), // Icône blanche
      ),
    );
  }

  void _showAddTextDialog() {
    _textEditingController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Ajouter du texte"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: "Entrez votre texte",
                    ),
                    onChanged: (text) {
                      setState(() {
                        _isTextEmpty = text.isEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isTextEmpty
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _addText(
                                Offset(100, 100),
                                _textEditingController
                                    .text); // Position initiale du texte
                          },
                    child: Text("Ajouter"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addMarker(Offset position) {
    setState(() {
      markerItems.add(MarkerItem(position: position));
    });
  }

  void _addText(Offset position, String text) {
    setState(() {
      markerItems.add(MarkerItem(
        position: position,
        widget: TextWidget(text: text),
      ));
    });
  }

  void _savePdfWithMarkers() {
    // Code pour sauvegarder le PDF avec les marqueurs
    // Vous devez implémenter cette fonctionnalité
  }
}

class MarkerItem {
  Offset position;
  Widget widget;

  MarkerItem({required this.position, Widget? widget})
      : widget = widget ?? const MarkerWidget();
}

class MarkerWidget extends StatelessWidget {
  const MarkerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          "!",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  final String text;

  const TextWidget({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.blue,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
