class Chantier {
  String id;
  String nom;
  String essenceBois;
  String vitrage;
  String finition;
  double epaisseurBois;
  List<Chassis> chassis;
  DateTime dateCreation;
  DateTime derniereModification;
  String creePar;

  Chantier({
    required this.id,
    required this.nom,
    required this.essenceBois,
    required this.vitrage,
    required this.finition,
    required this.epaisseurBois,
    required this.creePar,
    List<Chassis>? chassis,
    DateTime? dateCreation,
    DateTime? derniereModification,
  })  : chassis = chassis ?? [],
        dateCreation = dateCreation ?? DateTime.now(),
        derniereModification = derniereModification ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'essenceBois': essenceBois,
        'vitrage': vitrage,
        'finition': finition,
        'epaisseurBois': epaisseurBois,
        'chassis': chassis.map((c) => c.toJson()).toList(),
        'dateCreation': dateCreation.toIso8601String(),
        'derniereModification': derniereModification.toIso8601String(),
        'creePar': creePar,
      };

  factory Chantier.fromJson(Map<String, dynamic> json) {
    return Chantier(
      id: json['id'],
      nom: json['nom'],
      essenceBois: json['essenceBois'],
      vitrage: json['vitrage'],
      finition: json['finition'],
      epaisseurBois: json['epaisseurBois'],
      creePar: json['creePar'],
      chassis: (json['chassis'] as List).map((c) => Chassis.fromJson(c)).toList(),
      dateCreation: DateTime.parse(json['dateCreation']),
      derniereModification: DateTime.parse(json['derniereModification']),
    );
  }
}

class Chassis {
  String id;
  String nom;
  int quantite;
  double largeur;
  double hauteur;
  String? vitrageOverride;
  String? finitionOverride;
  List<ElementMenuiserie> elements;

  Chassis({
    required this.id,
    required this.nom,
    required this.quantite,
    required this.largeur,
    required this.hauteur,
    this.vitrageOverride,
    this.finitionOverride,
    List<ElementMenuiserie>? elements,
  }) : elements = elements ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'quantite': quantite,
        'largeur': largeur,
        'hauteur': hauteur,
        'vitrageOverride': vitrageOverride,
        'finitionOverride': finitionOverride,
        'elements': elements.map((e) => e.toJson()).toList(),
      };

  factory Chassis.fromJson(Map<String, dynamic> json) {
    return Chassis(
      id: json['id'],
      nom: json['nom'],
      quantite: json['quantite'],
      largeur: json['largeur'],
      hauteur: json['hauteur'],
      vitrageOverride: json['vitrageOverride'],
      finitionOverride: json['finitionOverride'],
      elements: (json['elements'] as List).map((e) => ElementMenuiserie.fromJson(e)).toList(),
    );
  }
}

class ElementMenuiserie {
  String id;
  String type; // 'montant', 'traverse', 'dormant', 'ouvrant', etc.
  double x;
  double y;
  double largeur;
  double hauteur;

  ElementMenuiserie({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.largeur,
    required this.hauteur,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'x': x,
        'y': y,
        'largeur': largeur,
        'hauteur': hauteur,
      };

  factory ElementMenuiserie.fromJson(Map<String, dynamic> json) {
    return ElementMenuiserie(
      id: json['id'],
      type: json['type'],
      x: json['x'],
      y: json['y'],
      largeur: json['largeur'],
      hauteur: json['hauteur'],
    );
  }
}
