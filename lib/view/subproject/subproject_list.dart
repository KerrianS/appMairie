import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mairie_ipad/components/header.dart';
import 'package:mairie_ipad/view/project_details.dart';
import 'package:mairie_ipad/models/sous_projet.dart';
import 'package:mairie_ipad/services/sousprojet_service.dart';

class SubProjectListScreen extends StatefulWidget {
  @override
  _SubProjectListScreenState createState() => _SubProjectListScreenState();
}

class _SubProjectListScreenState extends State<SubProjectListScreen> {
  late Future<List<SousProjet>> sousProjets;
  final SousProjetService projetService = SousProjetService();

  @override
  void initState() {
    super.initState();
    sousProjets = projetService.getAllSubProjects();
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
                child: FutureBuilder<List<SousProjet>>(
                  future: sousProjets,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<SousProjet> sousProjets = snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowHeight: 50,
                          columnSpacing: 50,
                          columns: [
                            DataColumn(
                                label: Text('N°',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Nom du Sous-Projet',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Description',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Date Début',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Date Fin',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: sousProjets.map((sousProjet) {
                            final DateFormat formatter =
                                DateFormat('yyyy-MM-dd');
                            return DataRow(
                              cells: [
                                DataCell(Text(sousProjet.id.toString())),
                                DataCell(Text(sousProjet.nom)),
                                DataCell(Text(sousProjet.description)),
                                DataCell(Text(
                                    formatter.format(sousProjet.dateDebut))),
                                DataCell(
                                    Text(formatter.format(sousProjet.dateFin))),
                              ],
                              onSelectChanged: (selected) {
                                if (selected != null) {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         //ProjectDetailsScreen(),
                                  //   ),
                                  // );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return CircularProgressIndicator();
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
