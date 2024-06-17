import 'package:flutter/material.dart';

enum AnnotationType {
  Rectangle,
  Circle,
}

class ToolbarPDF extends StatefulWidget {
  final Function(AnnotationType)? onAnnotationSelected;
  final VoidCallback? onSave;

  const ToolbarPDF({
    Key? key,
    this.onAnnotationSelected,
    this.onSave,
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
          IconButton(
            onPressed: widget.onSave,
            icon: Icon(Icons.save, color: Colors.white),
          ),
        ],
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
