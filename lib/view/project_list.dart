import 'package:flutter/material.dart';
import 'package:mairie_ipad/components/header.dart';
import 'package:mairie_ipad/view/project_details.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
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
                      height: 50, // Hauteur de la barre de recherche
                      width: MediaQuery.of(context).size.width *
                          0.2, // Ajuster la largeur du champ de recherche
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          prefixIcon: Icon(Icons.search), // Icône de recherche
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ), // Espacement entre la barre de recherche et le tableau
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    showCheckboxColumn:
                        false, // Pour enlever les cases à cocher
                    headingRowHeight: 50, // Hauteur de la ligne d'en-tête
                    columnSpacing: 50, // Espacement entre les colonnes
                    columns: [
                      DataColumn(
                          label: Text('N°',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Nom du Projet',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Description',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('TEST',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('TEST1',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('TEST2',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(Text('1')),
                          DataCell(Text('Projet travaux')),
                          DataCell(Text('Description 1')),
                          DataCell(Text('Value')),
                          DataCell(Text('Value1')),
                          DataCell(Text('Value2')),
                        ],
                        onSelectChanged: (selected) {
                          if (selected != null) {
                            // Navigation vers une autre page lorsqu'on appuie sur une ligne
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailsScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      DataRow(
                        cells: [
                          DataCell(Text('2')),
                          DataCell(Text('Projet police')),
                          DataCell(Text('Description 2')),
                          DataCell(Text('Value')),
                          DataCell(Text('Value1')),
                          DataCell(Text('Value2')),
                        ],
                        onSelectChanged: (selected) {
                          if (selected != null) {
                            // Navigation vers une autre page lorsqu'on appuie sur une ligne
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailsScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
