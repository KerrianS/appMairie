import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mairie_ipad/models/projet.dart';
import 'package:mairie_ipad/components/pdf_annotations.dart';
import 'package:mairie_ipad/view/project_task.dart';
import 'package:mairie_ipad/components/header.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProjectDetailsScreen extends StatefulWidget {
  final Projet projet;

  ProjectDetailsScreen({required this.projet});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Header(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Projet N°:',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.projet.numero.toString(),
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Nom du projet:',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.projet.nom,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Description:',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.projet.description,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );

                    if (result != null) {
                      File file = File(result.files.single.path!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnnotationsPDF(pdfFile: file),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Afficher le PDF',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    await _requestPermissions();
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);

                    if (image != null) {
                      setState(() {
                        _imageFile = File(image.path);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Aucune image sélectionnée')),
                      );
                    }
                  },
                  child: Text(
                    'Prendre une photo',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                ),
                SizedBox(height: 100.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_imageFile != null) {
                      await _saveImage(_imageFile!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectTaskScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Aucune image à sauvegarder')),
                      );
                    }
                  },
                  child: Text(
                    'Sauvegarder',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          if (_imageFile != null)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 350,
                  height: 350,
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // Demander la permission de stockage
      status = await Permission.storage.request();
    }
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission de stockage non accordée')),
      );
    }
  }

  Future<String> _getAppMairiePhotoPath() async {
    final directory = await getDownloadsDirectory();
    final downloadsPath = directory!.path;
    return downloadsPath;
  }

  Future<void> _saveImage(File image) async {
    try {
      // Vérifier les permissions
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
        status = await Permission.storage.status;
      }

      if (status.isGranted) {
        final photoPath = await _getAppMairiePhotoPath();
        final fileName = path.basename(image.path);
        final newImagePath = path.join(photoPath, fileName);
        await image.copy(newImagePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to $newImagePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission de stockage non accordée')),
        );
      }
    } catch (e) {
      // Afficher un message d'erreur en cas d'échec de la sauvegarde
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }
}
