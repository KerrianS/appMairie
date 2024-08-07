import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mairie_ipad/components/header.dart';
import 'package:mairie_ipad/view/project/project_details.dart';
import 'package:mairie_ipad/models/projet.dart';
import 'package:mairie_ipad/services/projet_service.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Projet>> projets;
  final ProjetService projetService = ProjetService();
  TextEditingController searchController = TextEditingController();
  List<Projet> filteredProjets = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    projets = projetService.getAllProjects();
    searchController.addListener(() {
      filterProjects();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterProjects() {
    String searchTerm = searchController.text.toLowerCase();
    if (searchTerm.isEmpty) {
      setState(() {
        filteredProjets = [];
        isSearching = false;
      });
      return;
    }

    List<Projet> filteredList = [];

    projets.then((projetsList) {
      filteredList = projetsList
          .where((projet) =>
              projet.numero.toString().toLowerCase().contains(searchTerm) ||
              projet.nom.toLowerCase().contains(searchTerm))
          .toList();

      setState(() {
        filteredProjets = filteredList;
        isSearching = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: Header(),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 15.0,
                            ),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              Expanded(
                child: isSearching ? buildSearchResults() : buildAllProjects(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearchResults() {
    return FutureBuilder<List<Projet>>(
      future: projets,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: filteredProjets.length,
            itemBuilder: (context, index) {
              final projet = filteredProjets[index];
              return buildProjetItem(projet);
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildAllProjects() {
    return FutureBuilder<List<Projet>>(
      future: projets,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Projet> projets = snapshot.data!;
          return ListView.builder(
            itemCount: projets.length,
            itemBuilder: (context, index) {
              final projet = projets[index];
              return buildProjetItem(projet);
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildProjetItem(Projet projet) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return ListTile(
      title: Text(projet.nom),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("N°: ${projet.numero}"),
          Text("Description: ${projet.description}"),
          Text("Date Début: ${formatter.format(projet.dateDebut)}"),
          Text("Date Fin: ${formatter.format(projet.dateFin)}"),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FutureBuilder<Projet>(
              future: projetService.getProjectById(projet.numero),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return ProjectDetailsScreen(projet: snapshot.data!);
                } else {
                  return Text('Aucune donnée trouvée');
                }
              },
            ),
          ),
        );
      },
    );
  }
}
