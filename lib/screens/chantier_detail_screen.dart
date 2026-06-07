import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chantier_provider.dart';
import 'chassis_form_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'dart:typed_data';
import 'chassis_builder_screen.dart';
import '../services/pdf_export_service.dart';
import '../services/dxf_export_service.dart';
import '../widgets/chassis_miniature.dart';

class ChantierDetailScreen extends StatelessWidget {
  const ChantierDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ChantierProvider>(
          builder: (context, provider, child) {
            return Text('Chantier: ${provider.chantierActuel?.nom ?? ''}');
          },
        ),
        backgroundColor: Colors.green.shade50,
      ),
      body: Consumer<ChantierProvider>(
        builder: (context, provider, child) {
          final chantier = provider.chantierActuel;

          if (chantier == null) {
            return const Center(child: Text('Aucun chantier sélectionné.'));
          }

          return Row(
            children: [
              // Colonne des infos du chantier
              Container(
                width: 300,
                color: Colors.grey.shade100,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                    const SizedBox(height: 16),
                    _InfoRow(icon: Icons.park, label: 'Essence', value: chantier.essenceBois),
                    _InfoRow(icon: Icons.window, label: 'Vitrage', value: chantier.vitrage),
                    _InfoRow(icon: Icons.format_paint, label: 'Finition', value: chantier.finition),
                    _InfoRow(icon: Icons.straighten, label: 'Épaisseur', value: '${chantier.epaisseurBois} mm'),
                    const SizedBox(height: 24),
                    const Divider(),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await PdfExportService.genererPdfProduction(chantier);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PDF de production généré avec succès!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur génération PDF: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Lancer la prod'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            String jsonString = jsonEncode(chantier.toJson());
                            Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

                            final FileSaveLocation? saveLocation = await getSaveLocation(
                              suggestedName: 'Chantier_${chantier.nom}_${DateTime.now().millisecondsSinceEpoch}.json',
                            );

                            if (saveLocation != null) {
                              final XFile xFile = XFile.fromData(bytes, mimeType: 'application/json');
                              await xFile.saveTo(saveLocation.path);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Chantier sauvegardé avec succès')),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur de sauvegarde: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Sauvegarder'),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              // Liste des châssis
              Expanded(
                child: chantier.chassis.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.window_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text('Aucun châssis dans ce chantier.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChassisFormScreen()));
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un châssis'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: chantier.chassis.length,
                        itemBuilder: (context, index) {
                          final chassis = chantier.chassis[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              leading: SizedBox(
                                width: 60,
                                height: 60,
                                child: Center(child: ChassisMiniature(chassis: chassis)),
                              ),
                              title: Text(chassis.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${chassis.quantite}x  -  ${chassis.largeur} x ${chassis.hauteur} mm'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_document),
                                    tooltip: 'Construire la fenêtre',
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => ChassisBuilderScreen(chassis: chassis),
                                      ));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.file_download),
                                    tooltip: 'Exporter DXF',
                                    onPressed: () async {
                                      try {
                                        await DxfExportService.genererDxfChassis(chassis);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('DXF généré avec succès!')),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Erreur export DXF: $e')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChassisFormScreen()));
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
