import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_saver/file_saver.dart';
import '../models/chantier.dart';

class PdfExportService {
  static Future<void> genererPdfProduction(Chantier chantier) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(chantier),
            pw.SizedBox(height: 20),
            _buildChassisSummary(chantier),
            pw.SizedBox(height: 20),
            _buildListeDebit(chantier),
            pw.SizedBox(height: 20),
            _buildListeVitrage(chantier),
          ];
        },
      ),
    );

    final Uint8List bytes = await pdf.save();
    await FileSaver.instance.saveFile(
      name: 'Prod_${chantier.nom}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      bytes: bytes,
      mimeType: MimeType.pdf,
    );
  }

  static pw.Widget _buildHeader(Chantier chantier) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('LISTE DE PRODUCTION', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.Text('Chantier: ${chantier.nom}', style: const pw.TextStyle(fontSize: 18)),
        pw.Text('Généré par: ${chantier.creePar} le ${DateTime.now().toString().split('.')[0]}'),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Essence: ${chantier.essenceBois}'),
            pw.Text('Vitrage: ${chantier.vitrage}'),
            pw.Text('Finition: ${chantier.finition}'),
            pw.Text('Épaisseur: ${chantier.epaisseurBois}mm'),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildChassisSummary(Chantier chantier) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Récapitulatif des Châssis', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: ['Nom', 'Quantité', 'Largeur (mm)', 'Hauteur (mm)', 'Vitrage Spécifique'],
          data: chantier.chassis.map((c) => [
            c.nom,
            c.quantite.toString(),
            c.largeur.toString(),
            c.hauteur.toString(),
            c.vitrageOverride ?? '-',
          ]).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildListeDebit(Chantier chantier) {
    // Calcul simplifié du débit: on prend juste tous les éléments du builder
    List<List<String>> debitData = [];
    for (var chassis in chantier.chassis) {
      for (var el in chassis.elements) {
        // Quantité de cette pièce = 1 * quantité de chassis
        debitData.add([
          chassis.nom,
          el.type,
          chassis.quantite.toString(),
          el.largeur.toStringAsFixed(1),
          el.hauteur.toStringAsFixed(1),
        ]);
      }
    }

    if (debitData.isEmpty) {
      return pw.Text('Aucune pièce définie dans les châssis.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Liste de Débit (Bois)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: ['Châssis', 'Type', 'Qte totale', 'Largeur (mm)', 'Longueur (mm)'],
          data: debitData,
        ),
      ],
    );
  }

  static pw.Widget _buildListeVitrage(Chantier chantier) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Liste de Vitrage', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          context: null,
          headers: ['Châssis', 'Type de Vitrage', 'Quantité', 'Dim. approx (LxH)'],
          data: chantier.chassis.map((c) => [
            c.nom,
            c.vitrageOverride ?? chantier.vitrage,
            c.quantite.toString(),
            '${c.largeur - 100} x ${c.hauteur - 100}' // Simplification pour la démo
          ]).toList(),
        ),
      ],
    );
  }
}
