import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mairie_ipad/models/projet.dart';
import 'dart:io';
import 'package:path/path.dart';

class ProjetService {
  Future<List<Projet>> getAllProjects() async {
    final response =
        await http.get(Uri.parse('http://10.10.30.135:3333/projets'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((projet) => Projet.fromJson(projet)).toList();
    } else {
      throw Exception('Failed to load projets');
    }
  }

  Future<Projet> getProjectById(int projectId) async {
    final response =
        await http.get(Uri.parse('http://10.10.30.135:3333/projet/$projectId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.isNotEmpty) {
        Map<String, dynamic> projetMap = jsonResponse.first;
        Projet projet = Projet.fromJson(projetMap);
        return projet;
      } else {
        throw Exception('Projet not found');
      }
    } else {
      throw Exception('Failed to load projet');
    }
  }

  Future<void> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.10.30.135:3333/upload/image'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: basename(imageFile.path),
      ),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> uploadPdf(File pdfFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.10.30.135:3333/upload/pdf'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        pdfFile.path,
        filename: basename(pdfFile.path),
      ),
    );

    var response = await request.send();
    if (response.statusCode == 200) {
      print('PDF uploaded successfully');
    } else {
      throw Exception('Failed to upload PDF');
    }
  }
}
