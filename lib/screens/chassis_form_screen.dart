import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/chantier.dart';
import '../providers/chantier_provider.dart';

class ChassisFormScreen extends StatefulWidget {
  const ChassisFormScreen({super.key});

  @override
  State<ChassisFormScreen> createState() => _ChassisFormScreenState();
}

class _ChassisFormScreenState extends State<ChassisFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _quantiteController = TextEditingController(text: '1');
  final _largeurController = TextEditingController();
  final _hauteurController = TextEditingController();
  final _vitrageController = TextEditingController();
  final _finitionController = TextEditingController();

  final _uuid = const Uuid();

  @override
  void dispose() {
    _nomController.dispose();
    _quantiteController.dispose();
    _largeurController.dispose();
    _hauteurController.dispose();
    _vitrageController.dispose();
    _finitionController.dispose();
    super.dispose();
  }

  void _ajouterChassis() {
    if (_formKey.currentState!.validate()) {
      final String? vitrageOverride = _vitrageController.text.trim().isEmpty ? null : _vitrageController.text.trim();
      final String? finitionOverride = _finitionController.text.trim().isEmpty ? null : _finitionController.text.trim();

      final nouveauChassis = Chassis(
        id: _uuid.v4(),
        nom: _nomController.text.trim(),
        quantite: int.parse(_quantiteController.text),
        largeur: double.parse(_largeurController.text.replaceAll(',', '.')),
        hauteur: double.parse(_hauteurController.text.replaceAll(',', '.')),
        vitrageOverride: vitrageOverride,
        finitionOverride: finitionOverride,
      );

      context.read<ChantierProvider>().addChassis(nouveauChassis);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chantier = context.read<ChantierProvider>().chantierActuel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Châssis'),
        backgroundColor: Colors.green.shade50,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chantier != null) ...[
                        Text(
                          'Rappel du chantier : ${chantier.nom}',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                        Text(
                          'Base: ${chantier.vitrage} | ${chantier.finition}',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du châssis',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantiteController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantité',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Requis';
                                if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Invalide';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _largeurController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Largeur (mm)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Requis';
                                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Invalide';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _hauteurController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Hauteur (mm)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Requis';
                                if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Invalide';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Exceptions (laisser vide pour utiliser les valeurs par défaut du chantier)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _vitrageController,
                        decoration: const InputDecoration(
                          labelText: 'Vitrage spécifique (optionnel)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _finitionController,
                        decoration: const InputDecoration(
                          labelText: 'Finition spécifique (optionnel)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _ajouterChassis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Créer et configurer le châssis', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
