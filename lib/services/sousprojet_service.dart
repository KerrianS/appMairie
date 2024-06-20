// services/projet_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mairie_ipad/models/sous_projet.dart';

class SousProjetService {
  Future<List<SousProjet>> getAllSubProjects() async {
    final response =
        await http.get(Uri.parse('http://10.10.30.135:3333/sous_projets'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((projet) => SousProjet.fromJson(projet)).toList();
    } else {
      throw Exception('Failed to load projets');
    }
  }

  Future<List<SousProjet>> getSubProjectsById(int numeroProjet) async {
    final response = await http.get(
      Uri.parse('http://10.10.30.135:3333/sous_projet/$numeroProjet'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((projet) => SousProjet.fromJson(projet)).toList();
    } else {
      throw Exception('Failed to load sous projets');
    }
  }
}
