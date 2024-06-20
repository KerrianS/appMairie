// view/project_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mairie_ipad/components/header.dart';
import 'package:mairie_ipad/view/project_details.dart';
import 'package:mairie_ipad/models/projet.dart';
import 'package:mairie_ipad/services/projet_service.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Projet>> projets;
  final ProjetService projetService = ProjetService();

  @override
  void initState() {
    super.initState();
    projets = projetService.getAllProjects();
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
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Projet>>(
                  future: projets,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Projet> projets = snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowHeight: 50,
                          columnSpacing: 50,
                          columns: [
                            DataColumn(
                              label: Text('N°',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Nom du Projet',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Description',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Date Début',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Date Fin',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                          rows: projets.map((projet) {
                            final DateFormat formatter =
                                DateFormat('DD/MM/YYYY');
                            return DataRow(
                              cells: [
                                DataCell(Text(projet.numero.toString())),
                                DataCell(Text(projet.nom)),
                                DataCell(Text(projet.description)),
                                DataCell(
                                    Text(formatter.format(projet.dateDebut))),
                                DataCell(
                                    Text(formatter.format(projet.dateFin))),
                              ],
                              onSelectChanged: (selected) {
                                if (selected != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FutureBuilder<Projet>(
                                        future: projetService
                                            .getProjectById(projet.numero),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Erreur: ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                            return ProjectDetailsScreen(
                                                projet: snapshot.data!);
                                          } else {
                                            return Text(
                                                'Aucune donnée trouvée');
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
