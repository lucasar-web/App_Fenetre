import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/chantier.dart';
import '../providers/chantier_provider.dart';
import '../services/user_service.dart';
import 'chantier_detail_screen.dart';

class ChantierFormScreen extends StatefulWidget {
  const ChantierFormScreen({super.key});

  @override
  State<ChantierFormScreen> createState() => _ChantierFormScreenState();
}

class _ChantierFormScreenState extends State<ChantierFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _essenceController = TextEditingController();
  final _vitrageController = TextEditingController();
  final _finitionController = TextEditingController();
  final _epaisseurController = TextEditingController();

  final _userService = UserService();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nomController.dispose();
    _essenceController.dispose();
    _vitrageController.dispose();
    _finitionController.dispose();
    _epaisseurController.dispose();
    super.dispose();
  }

  Future<void> _creerChantier() async {
    if (_formKey.currentState!.validate()) {
      final userName = await _userService.getUserName() ?? 'Inconnu';

      final nouveauChantier = Chantier(
        id: _uuid.v4(),
        nom: _nomController.text.trim(),
        essenceBois: _essenceController.text.trim(),
        vitrage: _vitrageController.text.trim(),
        finition: _finitionController.text.trim(),
        epaisseurBois: double.tryParse(_epaisseurController.text.replaceAll(',', '.')) ?? 0.0,
        creePar: userName,
      );

      if (mounted) {
        context.read<ChantierProvider>().setChantier(nouveauChantier);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChantierDetailScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Chantier'),
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
                      Text(
                        'Informations de base',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du chantier',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _essenceController,
                        decoration: const InputDecoration(
                          labelText: 'Essence de bois',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.park),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _vitrageController,
                        decoration: const InputDecoration(
                          labelText: 'Vitrage standard',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.window),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _finitionController,
                        decoration: const InputDecoration(
                          labelText: 'Finition',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.format_paint),
                        ),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _epaisseurController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Épaisseur des bois (mm)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.straighten),
                        ),
                        validator: (v) {
                          if (v!.isEmpty) return 'Requis';
                          if (double.tryParse(v.replaceAll(',', '.')) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _creerChantier,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Créer le chantier', style: TextStyle(fontSize: 16)),
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
