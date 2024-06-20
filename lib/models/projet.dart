class Projet {
  final int numero;
  final String nom;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;

  Projet({
    required this.numero,
    required this.nom,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
  });

  factory Projet.fromJson(Map<String, dynamic> json) {
    return Projet(
      numero: json['Numero'] as int,
      nom: json['nom'] as String,
      description: json['description'] as String,
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: DateTime.parse(json['date_fin'] as String),
    );
  }
}
