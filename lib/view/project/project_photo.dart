import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mairie_ipad/services/projet_service.dart';
import 'package:mairie_ipad/components/tools_bar.dart';
import 'package:mairie_ipad/components/dessin.dart';

class ProjectPhotoScreen extends StatefulWidget {
  final String nomProjet;
  final int numeroProjet;

  ProjectPhotoScreen({required this.nomProjet, required this.numeroProjet});

  @override
  _ProjectPhotoScreenState createState() => _ProjectPhotoScreenState();
}

class _ProjectPhotoScreenState extends State<ProjectPhotoScreen> {
  File? _imageFile;
  String _commentaire = '';
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
  );
  AnnotationType _selectedAnnotation = AnnotationType.Rectangle;
  Rect? _annotationRect;

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission de caméra non accordée')),
      );
    }
  }

  Future<File> _combineImageWithAnnotations(
      File imageFile, Rect annotationRect) async {
    final imageBytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(imageBytes)!;

    // Dessiner un rectangle
    img.drawRect(
      image,
      x1: annotationRect.left.toInt(),
      y1: annotationRect.top.toInt(),
      x2: annotationRect.right.toInt(),
      y2: annotationRect.bottom.toInt(),
      color: img.ColorRgb8(255, 0, 0), // Rouge
    );

    final annotatedImageBytes = Uint8List.fromList(img.encodePng(image));
    final tempDir = await getTemporaryDirectory();
    final annotatedImageFile = File('${tempDir.path}/annotated_image.png');
    await annotatedImageFile.writeAsBytes(annotatedImageBytes);
    return annotatedImageFile;
  }

  Widget _buildAnnotations() {
    if (_imageFile == null || _annotationRect == null) return Container();

    switch (_selectedAnnotation) {
      case AnnotationType.Rectangle:
        return Positioned(
          left: _annotationRect!.left,
          top: _annotationRect!.top,
          width: _annotationRect!.width,
          height: _annotationRect!.height,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
            ),
          ),
        );
      case AnnotationType.Circle:
        return Positioned(
          left: _annotationRect!.left,
          top: _annotationRect!.top,
          child: Container(
            width: _annotationRect!.width,
            height: _annotationRect!.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 2),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prendre une photo'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageFile == null) ...[
                Text(
                  'Aucune photo sélectionnée pour le moment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    await _requestPermissions();
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                    );

                    if (image != null) {
                      setState(() {
                        _imageFile = File(image.path);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Aucune photo prise pour le moment'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Appareil photo',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  ),
                ),
              ],
              if (_imageFile != null) ...[
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _annotationRect = Rect.fromLTWH(
                        details.localPosition.dx,
                        details.localPosition.dy,
                        0,
                        0,
                      );
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _annotationRect = Rect.fromPoints(
                        _annotationRect!.topLeft,
                        details.localPosition,
                      );
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    child: Stack(
                      children: [
                        Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                        _buildAnnotations(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3.5,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Entrez un commentaire...',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _commentaire = value;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_imageFile != null && _annotationRect != null) {
                      try {
                        final annotatedImageFile =
                            await _combineImageWithAnnotations(
                                _imageFile!, _annotationRect!);
                        await ProjetService().uploadImage(annotatedImageFile);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image uploaded successfully'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to upload image'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Valider', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
