import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/chantier.dart';
import '../providers/chantier_provider.dart';

class ChassisBuilderScreen extends StatefulWidget {
  final Chassis chassis;

  const ChassisBuilderScreen({super.key, required this.chassis});

  @override
  State<ChassisBuilderScreen> createState() => _ChassisBuilderScreenState();
}

class _ChassisBuilderScreenState extends State<ChassisBuilderScreen> {
  late List<ElementMenuiserie> _elements;
  final _uuid = const Uuid();

  final List<String> _typesDisponibles = [
    'Montant', 'Traverse', 'Dormant', 'Ouvrant', 'Meneau', 'Petit bois', 'Panneau isolé', 'Moulure grand cadre'
  ];

  @override
  void initState() {
    super.initState();
    // Créer une copie locale de la liste pour l'édition
    _elements = List.from(widget.chassis.elements);
  }

  void _sauvegarderChassis() {
    final updatedChassis = Chassis(
      id: widget.chassis.id,
      nom: widget.chassis.nom,
      quantite: widget.chassis.quantite,
      largeur: widget.chassis.largeur,
      hauteur: widget.chassis.hauteur,
      vitrageOverride: widget.chassis.vitrageOverride,
      finitionOverride: widget.chassis.finitionOverride,
      elements: _elements,
    );

    context.read<ChantierProvider>().updateChassis(updatedChassis);
    Navigator.of(context).pop();
  }

  void _appliquerPrefabrique(String type) {
    setState(() {
      _elements.clear();
      // Simulation simple pour la démo: cadre de base (dormants)
      double l = widget.chassis.largeur;
      double h = widget.chassis.hauteur;
      double ep = context.read<ChantierProvider>().chantierActuel?.epaisseurBois ?? 50.0;

      _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Dormant', x: 0, y: 0, largeur: l, hauteur: ep)); // Haut
      _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Dormant', x: 0, y: h - ep, largeur: l, hauteur: ep)); // Bas
      _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Dormant', x: 0, y: ep, largeur: ep, hauteur: h - 2*ep)); // Gauche
      _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Dormant', x: l - ep, y: ep, largeur: ep, hauteur: h - 2*ep)); // Droite

      if (type.contains('1 battant')) {
        // Ajouter un ouvrant simple
        _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Ouvrant', x: ep, y: ep, largeur: l - 2*ep, hauteur: h - 2*ep));
      } else if (type.contains('2 battant')) {
        // Ajouter 2 ouvrants et un meneau
        _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Meneau', x: l/2 - ep/2, y: ep, largeur: ep, hauteur: h - 2*ep));
        _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Ouvrant', x: ep, y: ep, largeur: l/2 - 1.5*ep, hauteur: h - 2*ep));
        _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Ouvrant', x: l/2 + ep/2, y: ep, largeur: l/2 - 1.5*ep, hauteur: h - 2*ep));
      }

      if (type.contains('rejet bois')) {
        _elements.add(ElementMenuiserie(id: _uuid.v4(), type: 'Moulure', x: ep, y: h-ep-20, largeur: l-2*ep, hauteur: 20));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Échelle pour faire rentrer le dessin dans l'écran
    const double maxDrawingHeight = 500.0;
    double scale = widget.chassis.hauteur > 0 ? maxDrawingHeight / widget.chassis.hauteur : 1;
    if (scale * widget.chassis.largeur > 500) {
      scale = 500 / widget.chassis.largeur;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Construction : ${widget.chassis.nom} (${widget.chassis.largeur}x${widget.chassis.hauteur})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _sauvegarderChassis,
            tooltip: 'Sauvegarder',
          )
        ],
      ),
      body: Row(
        children: [
          // Panneau latéral : Éléments et Préfabriqués
          Container(
            width: 250,
            color: Colors.grey.shade200,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text('Préfabriqués', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildPrefabButton('1 battant rejet bois'),
                _buildPrefabButton('2 battant rejet bois'),
                _buildPrefabButton('1 battant rejet alu'),
                _buildPrefabButton('2 battant rejet alu'),
                _buildPrefabButton('Porte 1 battant'),
                _buildPrefabButton('Porte 2 battant'),
                _buildPrefabButton('Chassis fixe'),
                const Divider(height: 32),
                const Text('Éléments libres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Glissez ces éléments vers le châssis', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                ..._typesDisponibles.map((type) => Draggable<String>(
                  data: type,
                  feedback: Material(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.green.withOpacity(0.5),
                      child: Text(type),
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(type, style: const TextStyle(fontSize: 14)),
                      trailing: const Icon(Icons.drag_indicator, size: 16),
                    ),
                  ),
                )),
              ],
            ),
          ),

          // Zone de dessin centrale
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      // OnAccept avec DragTargetDetails permet de récupérer la position globale (offset)
                      // mais ici on simplifie en ajoutant l'élément au centre
                      setState(() {
                        double defaultWidth = 100;
                        double defaultHeight = 50;
                        if (details.data == 'Montant' || details.data == 'Dormant') {
                          defaultWidth = 50;
                          defaultHeight = widget.chassis.hauteur;
                        } else if (details.data == 'Traverse') {
                          defaultWidth = widget.chassis.largeur;
                          defaultHeight = 50;
                        }

                        _elements.add(ElementMenuiserie(
                          id: _uuid.v4(),
                          type: details.data,
                          x: widget.chassis.largeur / 2 - defaultWidth / 2,
                          y: widget.chassis.hauteur / 2 - defaultHeight / 2,
                          largeur: defaultWidth,
                          hauteur: defaultHeight,
                        ));
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: widget.chassis.largeur * scale,
                        height: widget.chassis.hauteur * scale,
                        decoration: BoxDecoration(
                          border: Border.all(color: candidateData.isNotEmpty ? Colors.green : Colors.black, width: 2),
                          color: Colors.white,
                        ),
                        child: Stack(
                          children: _elements.map((el) {
                            return Positioned(
                              left: el.x * scale,
                              top: el.y * scale,
                              width: el.largeur * scale,
                              height: el.hauteur * scale,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    el.x += details.delta.dx / scale;
                                    el.y += details.delta.dy / scale;
                                  });
                                },
                                onDoubleTap: () {
                                  setState(() {
                                    _elements.remove(el);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.brown, width: 1),
                                    color: Colors.brown.shade200.withOpacity(0.8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      el.type,
                                      style: TextStyle(fontSize: 10 * scale, color: Colors.black),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Double-cliquez sur un élément pour le supprimer.\nFaites-le glisser pour le déplacer.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefabButton(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        onPressed: () => _appliquerPrefabrique(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green.shade800,
          alignment: Alignment.centerLeft,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
