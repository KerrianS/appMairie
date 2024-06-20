import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mairie_ipad/models/projet.dart';

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
}
