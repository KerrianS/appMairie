class SousProjet {
  final int id;
  final String nom;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final int numeroProjet;
  final String incident;
  final String tacheTodo;

  SousProjet({
    required this.id,
    required this.nom,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.numeroProjet,
    required this.incident,
    required this.tacheTodo,
  });

  factory SousProjet.fromJson(Map<String, dynamic> json) {
    return SousProjet(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      numeroProjet: json['numeroProjet'],
      incident: json['incident'],
      tacheTodo: json['tache_todo'],
    );
  }
}
